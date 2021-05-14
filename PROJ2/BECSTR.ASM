        .MODEL small    ; modelo de dados a ser usados 64Kb para
                        ; o codigo

        .STACK 0400H    ; usado para reservar 1Kb de dados o stack
                        ;
        .DATA           ; reentrada no segmento de dados DATA

; GetStr        Parameters lin,col ,colfinal, tamanho string

String  db      10,10,40, 30, 30 Dup(32),0

        .CODE           ; usado para reentrada no segmento de codigo

MAIN    PROC NEAR
        mov     ax,@DATA
        mov     ds,ax

        Fim

;[]---------------------------------------------------------------------------[]
;[]                    PROCEDIMENTO LE E ARMAZENA                             []
;[]---------------------------------------------------------------------------[]
LeiaStr PROC    NEAR
        dec     cx              ; cx quantos ler mais enter

        mov     ah,02h          ; funcao posiciona cursor
        int     10h             ;

        push    bx
        push    cx
        push    dx

        mov     bx,01h
        mov     dx,si
        mov     ah,40h
        int     21h


;Wprint:
;        mov     dl,si[bx]
;        mov     ah,02h          ; imprime caracter na tela
;        int     21h
;        inc     bx              ; incrementa si
;        loop    Wprint

        pop     dx
        pop     cx
        pop     bx

        mov     ah,02h
        int     10h             ; chama a funcao que posiona o cursor na tela

LoopS:
        mov     ah,00h          ; pega caracter do teclado sem eco
        int     16h             ; os caracteres estendidos recebem codigo em ah al=00

        cmp     al,8     ; testa se al ‚ BackSpace
        je      TstBack

        cmp     al,00
        je      Estend

        cmp     al,13    ; se al ‚ Enter
        je      TstEnter ;

        cmp     al,' '   ; se al nao for caracter que " " espaco
        jl      LoopS    ; le outro caracter ignore esse

        cmp     al,126   ; se al nao for caracter "~" til
        jg      LoopS    ; le outro caracter ignore esse

        cmp     bx,cx    ; compara se bx ‚ maior ou igual cx
        jge     LoopS    ; leia outro caracter

        mov     si[bx],al

        push    dx
        mov     dl,al    ; dl recebe o caracter a imprimir
        mov     ah,02h   ; imprime caracter na tela
        int     21h
        pop     dx

        inc     bx

        inc     dl       ; dl = coluna ‚ incrementada
        mov     ah,02h   ;
        int     10h      ; interrupcao posiciona cursor

        jmp     LoopS

TstEnter:
        mov    al,si[00] ; al recebe o inicio da string
        cmp    al,' '    ; compara se esta vazia
        je     LoopS     ; si igual esta vazio

        jmp    FimFun

Estend:                  ; se precionaou um caracter estendido
        cmp    ah,4Bh    ; se seta para esquerda
        je     Esquerda  ;

        cmp    ah,4Dh    ; se seta para direita
        je     Direita

        jmp    LoopS

Esquerda:
        cmp   bx,00      ; compara se esta no inicio da string
        je    LoopS

        dec    bx       ; decrementa bx
        dec    dl       ; decrementa a coluna
        mov    ah,02h   ; funcao posiciona cursor
        int    10h      ; chama interrupcao

        jmp    LoopS    ; Leia caracter denovo
Direita:
        cmp     bx,cx    ; compara se bx ‚ maior ou igual cx
        jge     LoopS    ; leia outro caracter

        inc     bx       ; incremento bx
        inc     dl       ; dl = coluna, ‚ incrementada
        mov     ah,02h   ;
        int     10h      ; interrupcao posiciona cursor

        jmp     LoopS

TstBack:
        cmp    bx,00h   ; compara se esta no inicio da string
        je     LoopAux
        mov    al,' '   ; al recebe espacos em brancos

        cmp    si[bx],al
        jne    LoopAux  ;

        dec    bx       ; decrementa bx
        mov    si[bx],al; string recebe espaco

        dec    dl       ; decrementa a coluna

        mov    ah,02h   ; funcao posiciona cursor
        int    10h      ; chama interrupcao

        push   dx
        mov    dl,al
        mov    ah,02    ; imprime caracter na tela
        int    21h
        pop    dx

        mov    ah,02h  ;
        int    10h     ; interrupcao posiciona cursor de novo
LoopAux:
        jmp    LoopS    ; leia outro caracter

FimFun:
        inc    cx
        mov    bx,cx    ; bx recebe o numero maximo de caracteres
        mov    al,13
        mov    si[bx],al; string recebe enter no final

        ret

        ENDP

;[]---------------------------------------------------------------------------[]
;[]                      PROCEDIMENTO LIMPA A TELA                            []
;[]---------------------------------------------------------------------------[]
Clear   PROC    NEAR
        push    ax
        push    bx
        push    cx
        push    dx

        mov     bh,07d          ; define atributo a ser utilizado
        mov     cx,00h          ; define em ch e cl (0,0)
        mov     dh,24d          ; define em dh a linha final
        mov     dl,79d          ; define em dl a coluna final
        mov     al,00d          ; define em al para rolar toda a tela
        mov     ah,06d          ; parametro para int 10h
        int     10h

        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret

        ENDP
;[]---------------------------------------------------------------------------[]
;[]                 PROCEDIMENTO ESPERA ENTER, ESC OU PgUp                    []
;[]---------------------------------------------------------------------------[]
Inkey   PROC    NEAR

LoopI:
        mov     ah,00d          ; parametro para funcao int 21h
        int     16h
        cmp     al,00           ; testa ‚ caracter estendido
        je      InKEst
        cmp     al,CR           ; compara se dl Igual a Enter
        je      EndInKey
        cmp     al,1Bh          ; compara se al Igual a Esc
        je      EndInKey


        jmp     LoopI
InKEst:
        cmp     ah,49h          ; testa se ‚ PgUp
        jne     LoopI
        mov     al,ah           ; al recebe ah e final de programa
EndInkey:                       ; se for igual a Enter ou Esc

        ret
InKey   ENDP
;[]---------------------------------------------------------------------------[]
;[]                  PROCEDIMENTO FINALIZA O PROGRAMA                         []
;[]---------------------------------------------------------------------------[]
Fim     PROC    NEAR

        call    Clear           ; procedimemto limpa a tela

        mov     bh,00           ; define a pagina de video
        mov     dh,00           ; linha  para posicionar o cursor
        mov     dl,00           ; coluna para posicionar o cursor
        mov     ah,02h          ; chama a funcao que posiona o cursor na tela
        int     10h

        mov     ah,4CH          ; retorna o controle ao DOS
        int     21h             ;

        ret

        ENDP
;[]---------------------------------------------------------------------------[]
;[]                    FIM DO PROGRAMA                                        []
;[]---------------------------------------------------------------------------[]
        END MAIN
