;[]-----------------------------------------------------------------[]
;|                                                                   |
;|                 -- Turbo Re-Booter V 2.0b --                      |
;|                                                                   |
;|      An example of how to hook INT-8 and INT-9 in a               |
;|                  100% Assembly written TSR                        |
;|                                                                   |
;|      Copyright (c) 1991 by Borland International Inc.             |
;|                    All Rights Reserved.                           |
;[]-----------------------------------------------------------------[]

; by Jeff Peters


JUMPS

bell       EQU 07
cr         EQU 13
lf         EQU 10
eos        EQU 00h         ; end of string character

scancode   EQU 54h         ; <SysReq>
shiftmask  EQU 0Ch         ; 12 = <Ctrl> <Alt>



; interrupt routine's data segment.  All this stuff stays resident
idseg segment word 'IDATA'
old_9            dd ?   ; old vector
old_8            dd ?   ; old vector
flag             dw 0
invoke_msg       db cr, lf, 'Turbo-ReBoot: (Version 2.0b) ...', eos

idseg ends

iseg segment para 'INTERRUPT'
          assume cs:iseg, ds:idseg, es:nothing, ss:nothing
;----------------------------------------------------------------------------
new_8     proc far          ; Hardware Timer Handler
          push bp
          mov bp, sp
          push ax
          push ds

          mov ax, seg idseg                  ; set up data seg
          mov ds, ax

          mov ax, [flag]                     ; test the flag
          cmp ax, 0
          je done_old                        ; if not, exit


; Else, patch the return value on the stack with the new address
; for out re-boot function.

          push cs                            ; ax <- cs
          pop ax
          mov [bp + 4], ax                   ; store segment of func.
          mov ax, offset end_clean
          mov [bp + 2], ax                   ; store offset of func.
          jmp short done_reg                 ; now exit when we exit,
                                             ; we go to the new function.


far_ptr   dd ?          ; data pointer in the code segment

done_old:

; Here we load far_ptr with the old vector's address so we can
; jump to it thus chaining the old routine.

          mov ax, word ptr [old_8]            ; offset of old vect
          mov word ptr cs:[far_ptr], ax
          mov ax, word ptr [old_8 + 2]        ; segment of old vect
          mov word ptr cs:[far_ptr + 2], ax

          pop ds
          pop ax
          pop bp

          jmp dword ptr cs:[far_ptr]          ; goto (*far_ptr)

done_reg:
          pop ds
          pop ax
          pop bp

; Note: when we IRET, we return to the address that is currently on
; the stack: our re-boot routine that we have patched the stack.

; Also note, that we don't reset the PIC , as we do with the INT_9
; handler, because we realize that death is growing very near with
; the fatal re-boot function just on the horizion!

          iret
new_8     endp

;----------------------------------------------------------------------------
new_9     proc far              ; Keyboard handler
          push bp
          mov bp, sp
          push ax                             ; save some reg's
          push bx
          push dx
          push ds
          push es

          mov ax, seg idseg                   ; load data seg
          mov ds, ax

          mov dx, 60h                         ; get scancode in from
          in al, dx                           ; PIC (port 60h)

          cmp al, scancode                    ; is it ours?
          jne end_old                         ; no? chain to old vect

                                              ; yes? still need to test
                                              ; the shift keys.

          mov ax, 0040h                       ; shiftkey status -> 40:17
          mov es, ax
          mov bx, 0017h
          mov al, byte ptr es:[bx]
          and al, shiftmask                   ; AND it with mask
          cmp al, shiftmask                   ; now test...
          jne end_old                         ; no? chain old vect

                                              ; yes? ...
                                              ; reset PIC
          mov dx, 61
          in al, dx
          xchg ah, al
          or al, 80h
          out dx, al
          xchg al, ah
          mov al, 20h
          mov dl, al
          xor dh, dh
          out dx, al

          mov ax, 1
          mov [flag], ax                      ; set the flag

          jmp short end_reg

end_old:
          pushf                               ; so the IRET won't kill us
          call dword ptr [old_9]              ; call old vect

end_reg:
          pop es                              ; pop reg's
          pop ds
          pop dx
          pop bx
          pop ax
          pop bp

          iret
new_9     endp

;----------------------------------------------------------------------------
puts      proc far  ; String Display Function

; This function takes a pointer to a string in DS:SI and displayes it on
; the screen with the Undocumented DOS Fast screen output function: INT_29
; The string is terminated with (eos), the end of string character.
; NOTE: INT_29, is a direct route to ANSI.SYS and won't work without it.

puts_load:
          lodsb
          cmp al, eos
          je puts_end
          int 29h
          jmp short puts_load

puts_end:
          retf
puts      endp

;----------------------------------------------------------------------------
end_clean proc far  ; This is our Re-boot function

          mov ax, seg idseg
          mov ds, ax

          mov si, offset invoke_msg           ; display msg
          call far ptr puts

          mov ax, 0FFFFh                      ; segment
          push ax
          xor ax, ax                          ; offset (0000h)
          push ax
          retf                                ; re-boot!

end_clean endp


iseg      ends

;----------------------------------------------------------------------------
last_seg segment para 'LAST'
       ; Dummy segment for resident size calculation
last_seg ends


; This stuff is only present during initialization.
; It gets released before we go resident
dseg segment para 'DATA'        ; initial data segment
_psp             dw ?
tsr_size         dw ?


title_msg        db cr, lf, 'Turbo-ReBooter Version 2.0b Copyright (c) 1991 Borland International', cr, lf, lf
                 db 'Now Microsoft Windows 3.0 compatible...', cr, lf ; NOTE: no eos.
kcombo           db 'Press <Ctrl><Alt><SysReq> to do a cold boot.', cr, lf, lf, eos

errmsg_env       db bell, cr, lf, 'Error freeing Env. Block', cr, lf, eos

dseg ends          

sseg segment word stack 'STACK'
stk dw 100 dup (0)
sseg ends



cseg segment para 'CODE'
          assume cs:cseg, ds:dseg, es:nothing, ss:sseg
;----------------------------------------------------------------------------
start:
          mov ax, seg dseg
          mov ds, ax
          mov [_psp], es

          mov si, offset title_msg    ; display banner bar.
          call far ptr puts

          call cmd_parse              ; es -> psp -- parse cmd line
          jnc reg                     ; no carry, no cmd line parameters



reg:

; We now get the segment of the environment block from PSP:002Ch and
; free it.

          mov bx, [_psp]
          mov es, bx
          mov bx, word ptr es:[02ch]  ; get segment of the env. MCB from psp
          mov es, bx
          mov ah, 049h                ; DOS release memory block
          int 21h
          jc err_env

memcalc:

          mov bx, seg last_seg
          sub bx, [_psp]              ; ax = size for our program
          inc bx                      ; safety paragragh
          mov [tsr_size], bx

          call load_vects

          mov dx, [tsr_size]
          mov ax, 3100h
          int 21h                     ; go resident


          jmp short done              ; never gets here.

err_env:
          mov si, offset errmsg_env
          jmp short error

error:    call far ptr puts

          mov ax, 4c01h
          int 21h


done:
      mov ax, 4c00h
      int 21h

;---------------------------------------------------------------------------
load_vects proc near  ; Interrupt vector initialization routine

          assume ds:idseg
          push ds
          mov ax, seg idseg           ; set up data seg
          mov ds, ax

          push ds                     ; push new data segment

          mov ah, 35h                 ; get old INT_9 vector
          mov al, 09h
          int 21h                     ; ES:BX --> int 9 vect.

          mov word ptr [old_9], bx           ; off
          mov word ptr [old_9 + 2], es       ; seg

          mov ax, seg new_9           ; set new INT_9 vector
          mov ds, ax
          mov dx, offset new_9
          mov ah, 25h
          mov al, 09h
          int 21h


          mov ah, 35h                 ; get old INT_8 vect
          mov al, 08h
          int 21h                     ; ES:BX --> int 8 vect.

          pop ds                      ; reset new data segment

          mov word ptr [old_8], bx      ; save it
          mov word ptr [old_8 + 2], es

          mov ax, seg new_8           ; set new INT_8 vect
          mov ds, ax
          mov dx, offset new_8
          mov ah, 25h
          mov al, 08h
          int 21h

          pop ds

          ret
load_vects endp

;----------------------------------------------------------------------------
cmd_parse proc near   ; Parse the Command line

; ES must point to the psp.  Returns the carry flag set if there are any
; parameters
          clc
          xor ah, ah
          mov al, byte ptr es:[80h]              ; length of cmdline
          cmp al, 0
          je cmd_end
          
          stc
cmd_end:
          ret
cmd_parse endp

;----------------------------------------------------------------------------
cseg ends
end start

