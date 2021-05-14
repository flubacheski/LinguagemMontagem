
;_TEXT   segment word public 'CODE'
;
;        org     100h
;
;        assume cs:_TEXT, ds:_TEXT, es:_TEXT, ss:_TEXT

	    model small
	    stack	0400h
public	_DIVISAO

.CODE

_DIVISAO PROC    FAR
	   push	 bp
	   mov	bp,sp

	   mov	ax,[ bp + 6 ]
	   mov	cx,[ bp + 8 ]

	   div	cl

;	   mov     ax,cs
;	   mov     ss,ax

;	   mov     ax,FimStack
;	   mov     sp,ax

;LoopD:
;	   mov     ax,10h
;	   xor     bx,bx
;
;	   div     bl
;	   jmp     LoopD
;
;	   mov     ah,4ch
;	   int     21h

	   mov	sp,bp
	   pop	bp
	   ret

	   endp
;			 dw      1024 dup(0)
;FimStack        dw      0

	   end
