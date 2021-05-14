
;
; Fabio Lubacheski  17/05/94
; O programa gerara um som no alto-falante do computador
;

        DOSSEG                  ;usa ordenacao de segmento Intel
        .MODEL  small           ;define tamanho do modelo
        .STACK  300h            ;define uma pilha de 768 bytes
        .DATA                   ;define localizacao dos dados
temp    dw      0
        .CODE
Turbo   PROC    FAR             ;declaracao do procedimento principal
        mov     ax,@DATA        ;aponta para .DATA
        mov     ds,ax
        mov     dx,0            ;inicializa dx em zero
        in      al,61h          ;apanha informacao da porta do
                                ;alto falante para aL
        and     al,0FCh         ;mascara inferior Mantem 2 bits inferiores

more:   mov     temp,00h        ;inicializa variavel em zero
        inc     dx              ;incrementa registrador dx
        cmp     dx,15           ;ja o fez 50 vezes ?
        je      finish          ;xor 2 bits do registrador a1

go:     xor     al,02h          ;apanha frequencia corrente
        mov     cx,temp         ;apanha frequencia corrente
        cmp     cx,2400         ;atingiu 600 hertz ?
        je      more            ;se sim, repete a sequencia
        inc     temp            ;se nao, aumenta a frequencia
        out     61h,al          ;envia para a porta do af

delay:  loop    delay           ;retorna controle ao DOS
        jmp     go              ;continue

finish:
        mov     ah,4Ch          ;retorna controle ao DOS
        int     21h             ;
Turbo   ENDP                    ;fim do procedimento principal
                                ;fim do programa

        END



