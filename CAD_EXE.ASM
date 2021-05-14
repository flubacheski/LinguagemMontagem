;[]--------------------------------------------------------------------------[]
;[]      NOME.......:    Fabio Gamarra Lubacheski                            []
;[]      PROGRAMA...:    Cadastro.Asm                                        []
;[]      OBJETIVO...:    O programa cadastra, altera e consulta dados em     []
;[]                      um mesmo modulo (C)adastra                          []
;[]                      No modulo (R)elatorio                               []
;[]      PROFESSOR..:    ALMIR DE SOUZA                                      []
;[]      DATA.......:    08/06/94                                            []
;[]      HORA.......:    16:00                                               []
;[]--------------------------------------------------------------------------[]

        .MODEL SMALL
        .STACK  0100h
; Definicoes de Strings


BELL    equ       7             ; campainha
CR      equ      0Dh            ; retorno do carro Enter
SizeRec equ      28h            ; tamanho do registro
EoB     equ     190h            ; Fim do Buffer 400 posicoes
Nome    equ     01Dh            ; tamanho do nome 30
Idade   equ      2              ; tamanho da idade 2
Serie   equ      2              ; tamanho da serie 2

        .DATA
Titulo          db      01,23,'C A D A S T R O  D E  A L U N O S',CR
tMenu           db      07,36,'MENU',CR

Opcao1          db      09,33,'(C)adastro',CR
Opcao2          db      11,33,'(R)elatorio',CR
Opcao3          db      13,33,'(F)im',CR


Msg1            db      10,05,'Matricula do Aluno......: [   ]',CR
Msg2            db      12,05,'Nome do Aluno...........: [                             ]',CR
Msg3            db      14,05,'Idade do Aluno..........: [  ]',CR
Msg4            db      16,05,'Serie do Aluno..........: [  ]',CR

LeiaC           db      15,30,'Escolha uma Opcao',CR
Continue        db      22,05,'Esc - Retorna ao Menu   Enter - Continua',CR
FimBuffer       db      22,05,'Aluno nao pode ser Cadastrado o Buffer esta cheio',BELL,CR
EndRel          db      22,05,'Fim do Relatorio                     - Pressione Enter -',BELL,CR
MsgC            db      22,05,'Aluno nao Encontrado - CADASTRANDO',CR
MsgA            db      22,05,'Enter - Altera        PgUp - Retorna        Esc - Sai',BELL,CR
MsgR            db      22,05,'RELATORIO DE ALUNOS      Enter - Continua      Esc - Sai',CR
MsgR2           db      22,05,'Cadastre pelo menos um aluno anter de fazer o Relatorio   - Enter',BELL,CR
Cls1            db      22,05,'                                                                  ',CR

LastReC         dw       0              ; guarda a ultima posicao no Buffer
Rec             dw       0

; Definicoes de Buffer
matri           db      4 dup (' ')  ; 3 + Enter

Buffer          db    400 dup (' ')

        .CODE
        mov     ax,@DATA
        mov     ds,ax
        mov     es,ax

INICIO:
        call    Menu            ; procedimento imprime menu

GTEC:                           ; recebe em dl a opcao
        mov     ah,00h          ; parametro para funcao
        int     16h

        cmp     al,'C'          ; se tecla for C
        je      CADAS           ; cadastre
        cmp     al,'c'
        je      CADAS

        cmp     al,'R'          ; se tecla for R
        je      RELAT           ; faca relatorio
        cmp     al,'r'
        je      RELAT

        cmp     al,'F'          ; se tecla for f
        je      FINAL           ; finalize o programa e retorna para dos
        cmp     al,'f'
        je      FINAL           ; finaliza o programa e retorna para dos
        cmp     al,27           ; se al for igual a Esc
        je      FINAL           ;

        jmp     GTEC            ; se opcao for diferente de "C,R,F" ou "c,r,f"

CADAS:
        call    _Cadas          ; procedimento faz cadastramento
        jmp     INICIO
RELAT:
        call    _Relat          ; procedimento faz relatorio
        jmp     INICIO          ; leia novamente a opcao

FINAL:  call    fim             ; procedimento finaliza o programa e retorna
                                ; ao DOS

;[]---------------------------------------------------------------------------[]
;[]                    PROCEDIMENTO FAZ O MENU                                []
;[]---------------------------------------------------------------------------[]
Menu    PROC    NEAR

        call    Clear           ; procedimento limpa a tela

        mov     si,offset Titulo
        call    PrinStr         ; imprime o Titulo "CADASTRO DE ALUNOS"

        mov     si,offset tMenu
        call    PrinStr         ; imprime "MENU"

        mov     si,offset Opcao1
        call    PrinStr         ; imprime "Cadastra"

        mov     si,offset Opcao2
        call    PrinStr         ; imprime "Busca"

        mov     si,offset Opcao3
        call    PrinStr         ; imprime "Fim"

        mov     si,offset LeiaC
        call    PrinStr         ; imprime "Escolha Uma Opcao"

        ret

Menu    ENDP
;[]---------------------------------------------------------------------------[]
;[]                    PROCEDIMENTO FAZ O CADASTRO                            []
;[]---------------------------------------------------------------------------[]
_Cadas  PROC    NEAR

IniC:                           ; inicio do "loop" _Cadas

        call    Clear           ; limpa a tela

        mov     si,offset Titulo
        call    PrinStr         ; imprime o Titulo "CADASTRO DE ALUNOS"

        mov     si,offset Msg1  ; imprime "matri"
        call    PrinStr

        mov     si,offset Msg2  ; imprime "Nome"
        call    PrinStr

        mov     si,offset Msg3  ; imprime "Idade"
        call    PrinStr

        mov     si,offset Msg4  ; imprime "Serie"
        call    PrinStr

        mov     cx,04           ; matricula recebera 4 espacos em branco
        mov     al,' '          ; al recebe espacos em branco
        mov     bx,00           ; bx indice da matricula
Limpe:                          ; limpe o buffer ( zerar variavel matri )
        mov     matri[bx],al    ; matricula recebe espacos em branco
        inc     bx              ; incrementa bx
        loop    Limpe           ; loop decrementa cx

        mov     bx,00           ;
        mov     cx,03h          ; cx recebe quantos caracteres a ler
        mov     dh,10           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        mov     di,offset matri ; apanha o endereco da estrutura
        call    LeiaStr         ; procedimento le string

        call    Find            ; procedimento faz procura

        cmp     al,49h          ; se a ultima  tecla presionada for PgUp
        je      IniC            ; volte para Inicio do Cadastramento

        cmp     al,1Bh          ; se a ultima tecla presionada for Esc
        je      FimC            ; retorne ao Menu

        mov     cx,Nome         ; cx recebe quanto ler sem contar o enter
        mov     dh,12           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    LeiaStr         ; procedimento le string

        mov     cx,Idade        ; cx recebe quanto ler sem contar o enter
        mov     dh,14           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    LeiaStr         ; procedimento le string

        mov     cx,Serie        ; cx recebe quanto ler sem contar o enter
        mov     dh,16           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    LeiaStr         ; procedimento le string


        mov     si,offset Continue ; si recebe string continue
        call    PrinStr         ; procedimento imprime string

        call    InKey           ; espera uma tecla ser precionada

        cmp     al,0Dh          ; compara se al e igual a Enter
        je      IniC            ; se for faz cadastro novamente

FimC:                           ; fim do procedimento cadastro
        ret

_Cadas  ENDP
;[]---------------------------------------------------------------------------[]
;[]           PROCEDIMENTO FAZ A PROCURA E O ARMAZENAMENTO NO BUFFER          []
;[]---------------------------------------------------------------------------[]
Find    PROC    NEAR
        mov     bx,00h          ; bx vai para o inicio do Buffer

TstFind:
        cmp     bx,LastRec      ; se nao chegou ao final do buffer
        jle     Search          ; pesquise de novo


        mov     LastRec,bx      ; se nao achou de append Blank
        mov     bx,ReC          ; bx recebe ReC numero do ultimo registro

        cmp     bx,EoB          ; testa se bx esta no final do buffer
        jge     EoBuffer        ; se estiver

        mov     si,offset MsgC  ; imprime que esta cadastrando
        call    PrinStr         ;

        mov     cx,04h          ; cx quantidade de bytes para mover
        lea     si,matri
        lea     di,buffer[bx]   ;
        rep     movsb           ; move da matricula para o buffer

        add     bx,4            ; incrementa bx para matricula
        lea     di,buffer       ; di recebe o endereco do Buffer

        jmp     EndFind         ; va para o fim do procedimento

EoBuffer:
        mov     LastRec,bx
        mov     si,offset FimBuffer    ; si imprime mensagem do final do buffer
        call    PrinStr         ; imprime a string

        call    InKey           ; espera uma tela

        mov     al,1Bh          ; al recebe Esc para voltar ao menu e tentar
                                ; consulta e alteracao
        jmp     EndFind         ; va para fim do procedimento

Search:

        lea     di,buffer[bx]   ; di recebe endereco do buffer
        lea     si,matri        ; si recebe o endereco da matricula
        mov     cx,04h          ; cx recebe o numero de bytes para comparar
        mov     ReC,bx          ; se achar bx recebe o numero do registro
        add     bx,SizeRec      ; bx recebe mais 40 posicoes
        repe    cmpsb           ; compare matriculo com Buffer
        jne     TstFind         ; se nao for igual,teste se ja esta no final
                                ; do Buffer

        mov     bx,Rec          ; achou o registro procurado
        add     bx,4            ; bx incrementa mais 1
        lea     di,buffer       ; di recebe o endereco do Buffer

        push    bx              ; guarde o valor de bx
        mov     cx,Nome         ; cx recebe a quantidade a imprimir
        mov     dh,12           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento le string

        inc     bx

        mov     cx,Idade        ; cx recebe a quantidade a imprimir
        mov     dh,14           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento le string

        inc     bx

        mov     cx,Serie        ; cx recebe a quantidade a imprimir
        mov     dh,16           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento le string
        pop     bx

        mov     si,offset MsgA         ;
        call    PrinStr

        call    Inkey           ; procedimento espera Esc ou Enter ou PgUp

        mov     si,offset Cls1  ;
        call    PrinStr

EndFind:                        ; fim da procura
        ret

Find    ENDP
;[]---------------------------------------------------------------------------[]
;[]                  PROCEDIMENTO FAZ RELATORIO EM TELA                       []
;[]---------------------------------------------------------------------------[]
_Relat  PROC    NEAR

        mov     bx,00h
        cmp     bx,LastRec      ; testa se ja foi castrado alguem
        jnz     InicRel


        mov     si,offset MsgR2 ; imprime message para que nao existe
        call    PrinStr         ; niguem cadastrado ainda

        jmp     FimRel

InicRel:
        call    Clear           ; limpa a tela

        mov     si,offset Titulo
        call    PrinStr         ; imprime o Titulo "CADASTRO DE ALUNOS"

        mov     si,offset Msg1
        call    PrinStr

        mov     si,offset Msg2
        call    PrinStr

        mov     si,offset Msg3
        call    PrinStr

        mov     si,offset Msg4
        call    PrinStr

        lea     di,Buffer

WhileRel:
        cmp     bx,LastRec
        je      EnddoRel

        mov     cx,03h          ; cx recebe quantidade a imprimir (MATRICULA)
        mov     dh,10           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento imprime string

        inc     bx

        mov     cx,Nome         ; cx recebe a quantidade a imprimir (NOME)
        mov     dh,12           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento imprime string

        inc     bx

        mov     cx,Idade        ; cx recebe a quantidade a imprimir  (IDADE)
        mov     dh,14           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento imprime string

        inc     bx

        mov     cx,Serie        ; cx recebe a quantidade a imprimir  (SERIE)
        mov     dh,16           ; dh recebe linha
        mov     dl,32           ; dl recebe coluna
        call    ImpStr          ; procedimento imprime string

        inc     bx

        mov     si,offset MsgR         ; imprime message "se continua com o relatorio"
        call    PrinStr

        call    Inkey
        cmp     al,0Dh
        je      WhileRel
EnddoRel:
        mov     si,offset EndRel       ; imprime message "que relatorio terminou"
        call    PrinStr
FimRel:
        call    Inkey           ; espera uma tecla

        ret
_Relat  ENDP
;[]---------------------------------------------------------------------------[]
;[]                    PROCEDIMENTO LE E ARMAZENA                             []
;[]---------------------------------------------------------------------------[]
LeiaStr PROC    NEAR

        push    bx
        mov     bh,00           ; define pagina de video
        mov     ah,02h
        int     10h             ; chama a funcao que posiona o cursor na tela
        pop     bx

        add     cx,bx

        push    bx
        mov     bx,cx
        mov     al,' '          ;
        mov     di[bx],al       ; ultima posicao recebe espaco em branco
        pop     bx

        mov     si,bx           ; guarda o Inicio do vetor

LoopS:
        mov     ah,00h          ; pega caracter do teclado sem eco
        int     16h             ; os caracteres estendidos recebem codigo em ah al=00

        cmp     al,8            ; testa se al ‚ BackSpace
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

        mov     di[bx],al

        push    dx
        mov     dl,al    ; dl recebe o caracter a imprimir
        mov     ah,02h   ; imprime caracter na tela
        int     21h
        pop     dx

        inc     bx

        inc     dl       ; dl = coluna ‚ incrementada

PosXY:
        push    bx
        mov     bh,00    ; recebe a pagina de video
        mov     ah,02h   ; funcao posiciona o cursor
        int     10h      ;
        pop     bx

        jmp     LoopS

TstEnter:
        push   bx
        mov    bx,si
        mov    al,di[bx] ; al recebe o inicio da string
        pop    bx

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
        cmp   bx,si     ; compara se esta no inicio da string
        je    LoopS

        dec    bx       ; decrementa bx
        dec    dl       ; decrementa a coluna
        jmp    PosXY

Direita:
        cmp     bx,cx    ; compara se bx ‚ maior ou igual cx
        jge     LoopS    ; leia outro caracter

        inc     bx       ; incremento bx
        inc     dl       ; dl = coluna, ‚ incrementada

        jmp     PosXY

TstBack:
        cmp    bx,si    ; compara se esta no inicio da string
        je     LoopAux
        mov    al,' '   ; al recebe espacos em brancos

        cmp    di[bx],al; testa se na ultima posicao esta vazia
        jne    LoopAux  ;

        dec    bx       ; decrementa bx
        mov    di[bx],al; string recebe espaco

        dec    dl       ; decrementa a coluna

        push   bx
        mov    bh,00    ; bh recebe a pagina de video
        mov    ah,02h   ; funcao posiciona cursor
        int    10h      ; chama interrupcao
        pop    bx

        push   dx
        mov    dl,al
        mov    ah,02    ; imprime caracter na tela
        int    21h
        pop    dx
        jmp    PosXY

LoopAux:
        jmp    LoopS    ; leia outro caracter

FimFun:
        mov    bx,cx    ; bx recebe o numero maximo de caracteres
        mov    al,13
        mov    di[bx],al; string recebe enter no final
        inc    bx       ; incrementa bx para o Enter

        ret

        ENDP

;[]---------------------------------------------------------------------------[]
;[]                 PROCEDIMENTO IMPRIME STRING NA TELA                       []
;[]---------------------------------------------------------------------------[]
ImpStr  PROC    NEAR

        push    bx              ; empilha bx
        mov     bh,00h          ; bh recebe a pagina de video
        mov     ah,02h          ; funcao posiciona cursor
        int     10h             ;
        pop     bx              ; desimpilha bx

        push    cx
        push    dx
Wprint:
        mov     dl,di[bx]       ; dl recebe o caracter na posicao de di[bx]
        mov     ah,02h          ; imprime caracter na tela
        int     21h
        inc     bx              ; incrementa bx, vai para proximo caracter
        loop    Wprint

        pop     dx
        pop     cx

        ret

ImpStr  ENDP
;[]---------------------------------------------------------------------------[]
;[]       PROCEDIMENTO IMPRIME STRING NA TELA PASSANDO COLUNA E LINHA         []
;[]---------------------------------------------------------------------------[]
PrinStr PROC    NEAR
        push    ax
        push    bx

        mov     dh,si[00]       ; dh recebe linha
        mov     dl,si[01]       ; dl recebe coluna
        mov     bh,00           ; define a pagina de video
        mov     ah,02h
        int     10h             ; chama a funcao que posiona o cursor na tela

        mov     bx,02h
        mov     dh,CR           ; dh recebe Enter
LacoP:
        mov     dl,si[bx]
        mov     ah,2            ; funcao imprime string na tela
        int     21h
        inc bx
        cmp     si[bx],dh       ; testa se ‚ Enter
        jne     LacoP

        pop     bx
        pop     ax
        ret

PrinStr ENDP
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
;[]                         FIM DE PROGRAMA                                   []
;[]---------------------------------------------------------------------------[]
        END

