
;-----------------------------------------------------------------------------;
;        NOME.......:    Fabio Gamarra Lubacheski                             ;
;        PROGRAMA...:                                                         ;
;        OBJETIVO...:                                                         ;
;                                                                             ;
;                                                                             ;
;        PROFESSOR..:    ALMIR DE SOUZA                                       ;
;        DATA.......:    08/06/94                                             ;
;        HORA.......:    16:00                                                ;
;-----------------------------------------------------------------------------;

        name    zdivide
        page    55,132
        title   ZERODIV -- Divide-by-zero handler

;       ZERODIV.ASM--Termina-e-permanece-residente

cr      equ     0Dh             ; Carrige return
lf      equ     0Ah             ; LineFeed
beep    equ     07h             ; Beel code
backsp  equ     08h             ; Backspace code

_TEXT   segment word public 'CODE'

        org     100h

        assume cs:_TEXT, ds:_TEXT, es:_TEXT, ss:_TEXT


Init    PROC    FAR

        mov     dx,offset zdiv
        mov     ah,25h
        mov     al,00h
        int     21h

        mov     dx,offset msg1
        mov     ah,9
        int     21h

        int     00

        mov     dx,offset pgm_len
        add     dx,15
        mov     cl,4
        shr     dx,cl

        add     dx,10h

;       mov     dx,100h                 ; Reservado Temporario

        mov     ax,3100h

        int     21h

Init    ENDP
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
Zdiv    PROC    FAR

        sti                     ; Habilita a interrupcao

        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    bp
        push    ds
        push    es

        mov     ax,cs
        mov     ds,ax

        mov     dx,offset msg2
        mov     ah,9
        int     21h

Zdiv1:
        mov     ah,1
        int     21h

        or      al,20h

        cmp     al,'c'
        je      zdiv3

        cmp     al,'q'
        je      zdiv2

        mov     dx,offset msg3
        mov     ah,9
        int     21h

        jmp     zdiv1

Zdiv2:
        mov     ax,4CFFh
        int     21h

Zdiv3:
        mov     dx,offset msg4
        mov     ah,9
        int     21h

        xor     ax,ax
        push    ax
        popf
        pushf
        pop     ax
        and     ax,0F000h
        cmp     ax,0F000h
        je      Zdiv5

        mov     bp,sp

        lds     bx,[bp+18]

        mov     bl,[bx+1]
        and     bx,0C7h

        cmp     bl,6
        jne     Zdiv4

        add     word ptr [bp+18],4
        jmp     Zdiv5

Zdiv4:
        mov     cl,6
        shr     bx,cl
        mov     bl,cs:[bx+itab]
        add     [bp+18],bx

Zdiv5:
        pop     es
        pop     ds
        pop     bp
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        iret

zdiv    ENDP
;------------------------------------------------------------------------------;
;                               FIM DE PROGRAMA                                ;
;------------------------------------------------------------------------------;

msg1    db      cr,lf
        db      'Divicao por Zero'
        db      cr,lf
        db      'Programa Instalado.'
        db      cr,lf,'$'

msg2    db      cr,lf,lf
        db      'Divicao por Zero detectado'
        db      cr,lf,'Continue or Quit (C/Q) ?'
        db      '$'

msg3    db      beep
        db      backsp,'',backsp,'$'

msg4    db      cr,lf,'$'

itab    db      2
        db      3
        db      4
        db      2

oldint  dd      0

pgm_len db      0

_TEXT   ENDS
        END     Init
