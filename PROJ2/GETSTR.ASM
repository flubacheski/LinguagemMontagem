
        .MODEL small    ; modelo de dados a ser usados 64Kb para
                        ; o codigo

        .STACK 0700H    ; usado para reservar 1Kb de dados o stack
                        ;
BELL    equ        7h   ; campainha
CR      equ       0Dh   ; retorno do carro Enter
BACK    equ       08h   ; Backspace
_ESC    equ      01Bh   ; Esc
_DEL    equ      0D3h   ; Del
_INS    equ      0D2h   ; Insercao
_HOME   equ      0C7h   ; Home
_END    equ      0CFh   ; End
LEFT    equ      0CBh   ; Seta a Esquerda
RIGHT   equ      0CDh   ; Seta a Direita
UP      equ      0C8h   ; Seta para Cima
DOWN    equ      0D0h   ; Seta para Baixo
PgUp    equ      0C9h   ; Tecla PgUp
PgDn    equ      0D1h   ; Tecla PgDn
NULL    equ       00h   ; Caracter nulo
VIDEO   equ    0b800h   ; VIDEO guarda endereco da memoria de video
ON      equ        1h   ; Ativado
OFF     equ        0h   ; Desativado
TRUE    equ        1h
FALSE   equ        0h
iLin    equ        -1   ; Linha inicial
iCol    equ  iLin - 1   ; Coluna inicial
fCol    equ  iCol - 1   ; Coluna final
Tam     equ  fCol - 1   ; Tamanho da string
TamA    equ  Tam  - 1   ; Tamanho atual da string
IntC    equ  TamA - 1   ; Intervalo das colunas
iStr    equ  IntC - 2   ; Endereco inicial da String
fStr    equ  iStr - 2   ; Endereco final String
PosT    equ  fStr - 2   ; Guarda a posicao na tela para impressao

        .DATA           ; reentrada no segmento de dados DATA

LastKey         db      0       ; guarda o valor da ultima tecla pressionada

InsOnOff        db      0       ; guarda o estado da insercao

MsgInsOn        db      'Ins',0

MsgInsOff       db      '   ',0

Estend          db      0       ; guarda se e caracter estendido

CharEsq         db      17,0
CharDir         db      16,0


; GetStr        Parameters(int lin, int col , int colfinal, int tam , char * string )
String1         db      05,30,50,30,31 Dup(NULL)
String2         db      07,30,50,30,31 Dup(NULL)
String3         db      09,30,50,30,31 Dup(NULL)


VetReg          dw       String1
                dw       String2
                dw       String3
                db       '}'

BecapeStr       db      1024 Dup ( NULL )
BuffStr         db      255  Dup ( NULL )

Nome            db      'Digite o Nome.....: ',0
Endereco        db      'Digite o Endereco.: ',0
Cidade          db      'Digite a Cidade...: ',0

Msg             db      'Pressione Qualquer tecla para Continuar        - Esc - Sai',0


        .CODE           ; usado para reentrada no segmento de codigo
;[]---------------------------------------------------------------------------[]
;[]                         INICIO DO PROGRAMA                                []
;[]---------------------------------------------------------------------------[]
JUMPS
MAIN    PROC NEAR

        mov     ax,@DATA
        mov     ds,ax


WhileMain:
        xor     ax,ax           ; define linha = 0 coluna = 0
        push    ax
        mov     ax,184Fh        ; define linha = 24 coluna = 79
        push    ax
        mov     ax,17h
        push    ax
        call    Clear
        add     sp,6h

        mov     ax,05
        push    ax
        mov     ax,09
        push    ax
        mov     ax,offset Nome
        push    ax
        call    PutS
        add     sp,6h

        mov     ax,07
        push    ax
        mov     ax,09
        push    ax
        mov     ax,offset Endereco
        push    ax
        call    PutS
        add     sp,6h

        mov     ax,09
        push    ax
        mov     ax,09
        push    ax
        mov     ax,offset Cidade
        push    ax
        call    PutS
        add     sp,6h


        mov     ax,offset VetReg
        push    ax
        call    EditReg
        add     sp,2h


        mov     ax,20
        push    ax
        mov     ax,10
        push    ax
        mov     ax,offset Msg
        push    ax
        call    PutS
        add     sp,6h

        call    InKey

        cmp     al,_ESC
        jne     WhileMain

        call    Fim

        ret

MAIN    ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO EDITA CAMPOS UM A UM                          []
;[] Parametros ( VetStruct Struct )                                           []
;[]---------------------------------------------------------------------------[]
EditReg PROC    NEAR

        push    bp
        mov     bp,sp

        sub     sp,2h

        push    bx
        push    cx
        push    dx
        push    di
        push    si

        xor     cx,cx

        mov     si,offset BecapeStr; si indice do buffer local as duas primeiras posicoes
        mov     di,[ bp + 4 ]   ; sao para  guardar o numero de campos
        mov     bx,[ di ]       ; move para di o primeiro endereco da string

WhileEdit:
        mov     dx,bx
        add     dx,4h

        mov     ax,si           ; endereco da string de  becape
        push    ax              ; na pilha destino
        mov     ax,dx           ; string de origem
        push    ax
        mov     al,[ bx + 3 ]   ; tamanho da string
        push    ax
        call    StrCpy
        add     sp,6h

        xor     ax,ax
        mov     al,[ bx + 3 ]
        add     si,ax           ; incrementa si mais o tamanho da string
        inc     si

        mov     ah,[ bx ]       ; linha inicial
        mov     al,[ bx + 1 ]   ; coluna inicial
        dec     al              ; limpa coluna inicial - 1
        push    ax
        mov     ah,[ bx ]       ; linha final
        mov     al,[ bx + 2 ]   ; coluna final
        inc     al              ; limpa coluna final + 1
        push    ax
        mov     ax,0071h
        push    ax
        call    Clear
        add     sp,6h

        xor     ax,ax
        mov     al,[ bx ]       ; empilha linha
        push    ax
        mov     al,[ bx + 1 ]   ; empilha coluna
        push    ax
        mov     al,[ bx + 2 ]   ; empilha coluna final
        push    ax
        mov     ax,dx           ; empilha o endereco da string
        push    ax
        call    ImpStr          ; funcao imprime string
        add     sp,8

        mov     ax,dx           ; empilha o endereco inicial da string
        push    ax
        call    StrLen          ; calcula o tamanho atual da string
        add     sp,2h

        mov     dh,[ bx + 1 ]   ; dh recebe coluna inicial
        mov     dl,[ bx + 2 ]   ; dl recebe coluna final
        sub     dl,dh
        cmp     al,dl           ; se tamanho da string for maior
        jle     PuleEdit        ; que intervalo das colunas

        mov     al,[ bx ]       ; linha
        push    ax
        mov     al,[ bx + 2 ]   ; coluna final
        inc     al
        push    ax
        mov     ax,offset CharDir
        push    ax
        call    PutS
        add     sp,6h
PuleEdit:
        inc     cx
        inc     di
        inc     di
        mov     bl,[ di ]       ; move para di o primeiro endereco da string
        cmp     bl,'}'
        jnz     WhileEdit

        dec     cx
        mov     [ bp  - 2 ],cx  ; guarda em uma variavel local o numero de campos
        mov     di,[ bp + 4 ]
        xor     cx,cx

LoopEdit:
        mov     ax,[ di ]
        push    ax
        call    GetStr
        add     sp,2h

        mov     ax,[ di ]       ; aponta para endereco inicial da string
        add     ax,4h           ; vai para string
        push    ax
        call    StrLen
        add     sp,2h

        mov     dl,al

        mov     al,LastKey

        cmp     al,CR
        je      TecEnter

        cmp     al,UP
        je      TecUp

        cmp     al,DOWN
        je      TecDown

        cmp     al,_ESC
        je      FimEditEsc

        jmp     LoopEdit

TecUp:

        cmp     cx,NULL         ; Testa se cx igual a zero
        je      LoopEdit

        dec     cx
        dec     di
        dec     di

        jmp     LoopEdit

TecEnter:
        cmp     dl,NULL         ; se string for vazia nao leia de novo
        je      LoopEdit

        cmp     cx,[ bp - 2 ]
        je      FimEdit

TecDown:
        cmp     dl,NULL         ; se string for vazia nao leia de novo
        je      LoopEdit

        cmp     cx,[ bp - 2 ]   ; Testa se esta no fim das strings
        je      LoopEdit

        inc     cx
        inc     di
        inc     di

        jmp     LoopEdit

FimEditEsc:
        xor     cx,cx
        mov     si,offset BecapeStr; zera o indice da string destino
        mov     di,[ bp + 4 ]   ; di recebe o endereco dos campos
        mov     cx,[ bp - 2 ]   ; cx recebe o numero de campos
        inc     cx
LoopEsc:
        mov     bx,[ di ]
        mov     dx,bx
        add     dx,4h

        mov     ax,dx           ; string de origem
        push    ax
        mov     ax,si           ; endereco da string de  becape
        push    ax              ; na pilha destino
        mov     al,[ bx + 3 ]   ; tamanho da string
        push    ax
        call    StrCpy
        add     sp,6h

        xor     ax,ax
        mov     al,[ bx + 3 ]   ; move para al tamanho da string
        add     si,ax           ; incrementa si mais o tamanho da string

        inc     si              ; pule o caracter NULL

        inc     di
        inc     di

        dec     cx

        cmp     cx,NULL
        jne     LoopEsc

FimEdit:

        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

EditReg ENDP
;[]---------------------------------------------------------------------------[]
;[]                         FUNCAO LE STRING                                  []
;[] Parametros ( int Lin, int Col, int ColFinal, int Tam, char *String )      []
;[]---------------------------------------------------------------------------[]
GetStr  PROC    NEAR

        push    bp
        mov     bp,sp

        sub     sp,0Ch          ; reserva 12 bytes ou 6 words como variavel local
                                ; a 1a word para linha e coluna
                                ; 2a word  para coluna final e tamanho maximo em byteas
                                ; 3a word  para tamanho atual e intervalo de coluna
                                ; 4a word  para endereco inicial da string
                                ; 5a word  para endereco final da string
                                ; 6a word  para a posicao na tela a imprimir

        push    bx
        push    cx
        push    dx

        xor     bx,bx
        xor     cx,cx
        xor     dx,dx

        mov     bx,[ bp + 4 ]   ; bx recebe o endereco da string

        mov     dh,[ bx ]       ; dh recebe linha
        mov     [ bp + iLin ],dh; variavel guarda linha
        inc     bx

        mov     dl,[ bx ]
        mov     [ bp + iCol ],dl; dl recebe coluna
        inc     bx

        mov     al,[ bx ]       ; al recebe coluna final
        mov     [ bp + fCol ],al; variavel guarda coluna final
        inc     bx

        mov     al,[ bx ]       ; al recebe tamanho maximo da string
        mov     [ bp + Tam ],al ; variavel guarda tamanho maximo da string
        inc     bx

        mov     cl,[ bp + iCol ]; cl recebe coluna inicial
        mov     al,[ bp + fCol ]; al recebe coluna final
        sub     ax,cx           ; subtrai coluna final - coluna inicial
        mov     [ bp + IntC ],al; guarda na variavel

        mov     [ bp + iStr ],bx; recebe o endereco inicial da string

        xor     cx,cx           ; zera cx
        mov     cl,[ bp + Tam ] ; cx recebe quantos caracteres a ler
        add     cx,bx           ; calcula o endereco final da string
        mov     [ bp + fStr ],cx; guarda o endereco final da string

        mov     [ bp + PosT ],bx; guarda a posicao na tela para rolagem

LoopS:
        mov     ax,[ bp + iStr ]; empilha o endereco inicial da string
        push    ax
        call    StrLen          ; calcula o tamanho atual da string
        add     sp,2h
        mov     [ bp + TamA ],al; guarda na variavel tamanho atual da string

        mov     ah,[ bp + iLin ]; linha inicial
        mov     al,[ bp + iCol ]; coluna inicial
        dec     al              ; limpa coluna inicial - 1
        push    ax
        mov     ah,[ bp + iLin ]; linha final
        mov     al,[ bp + fCol ]; coluna final
        inc     al              ; limpa coluna final + 1
        push    ax
        mov     ax,0071h
        push    ax
        call    Clear
        add     sp,6h

        xor     ax,ax
        mov     al,[ bp + iLin ]; empilha linha
        push    ax
        mov     al,[ bp + iCol ]; empilha coluna
        push    ax
        mov     al,[ bp + fCol ]; empilha coluna final
        push    ax
        mov     ax,[ bp + PosT ]; empilha o endereco da string
        push    ax
        call    ImpStr          ; funcao imprime string
        add     sp,8

        mov     ax,[ bp + iStr ];
        cmp     ax,[ bp + PosT ];
        je      Continue1

        mov     al,[ bp + iLin ]
        push    ax
        mov     al,[ bp + iCol ]
        dec     al
        push    ax
        mov     ax,offset CharEsq; caracter especial indica mais string a esquerda
        push    ax
        call    PutS
        add     sp,6h
Continue1:
        mov     cx,bx
        sub     cx,[ bp + iStr ]
        mov     al,[ bp + fCol ]
        sub     al,dl
        add     cl,al
        mov     ch,[ bp + TamA ]
        cmp     ch,cl
        jle     Continue2

        mov     al,[ bp + iLin ]
        push    ax
        mov     al,[ bp + fCol ]
        inc     al
        push    ax
        mov     ax,offset CharDir
        push    ax
        call    PutS
        add     sp,6h

Continue2:
        mov     al,[ bp + iLin ]; al recebe linha
        push    ax
        mov     al,dl           ; al recebe coluna
        push    ax
        call    gotoxy          ; funcao posiciona cursor na tela
        add     sp,4



        call    InKey           ; Funcao retorna o codigo ASCII

        cmp     al,BACK         ; Testa se al ‚ BackSpace
        je      ApagueC

        cmp     al,_DEL
        je      ApagueC

        cmp     al,LEFT         ; Testa se Seta Esquerda
        je      Esquerda

        cmp     al,RIGHT        ; Testa se Seta Direita
        je      Direita

        cmp     al,_INS         ; se al ‚ Insercao
        je      GotoIns

        cmp     al,_HOME        ; se al ‚ Home
        je      TstHome

        cmp     al,_END         ; se al ‚ End
        je      TstEnd

        cmp     al,_ESC
        je      FimGetStr

        cmp     al,CR           ; se al ‚ Enter
        je      FimGetStr       ; va para o fim da string

        mov     ah,Estend       ; ah recebe se e' caracter estendido
        cmp     ah,TRUE         ; se al nao for caracter "~" til
        je      FimGetStr       ; le outro caracter ignore esse

        cmp     bx,[ bp + fStr ]; compara se bx ‚ maior ou igual endereco
        jge     LoopS           ; final da string, leia outro caracter

        cmp     al,' '          ; se al nao for caracter que " " espaco
        jl      LoopS           ; le outro caracter ignore esse

        mov     ax,[ bp + fStr ]; empilha fim da string
        push    ax
        mov     ax,bx           ; empilha o endereco da string
        push    ax
        call    Escreva
        add     sp,4h
        cmp     ax,NULL         ; se Insercao estava ligado e ja encheu
        je      LoopS           ; o buffer nao faca nada

        jmp     Direita         ; rola tela a direita

Direita:
        cmp     bx,[ bp + fStr ]; compara se bx ‚ maior ou igual cx
        je      LoopS
        mov     al,NULL
        cmp     [ bx ],al       ; compara se esta no final da string
        je      LoopS           ;

        inc     bx

        cmp     dl,[ bp + fCol ]; compara se coluna igual coluna final
        jge     RolaTelaD       ; se estiver role a tela

        inc     dl              ; incrementa coluna

        jmp     LoopS

RolaTelaD:
        mov     ax,[ bp + PosT ]; ax recebe Posicao tela para decrementar
        inc     ax
        mov     [ bp + PosT ],ax

        jmp     LoopS

Esquerda:
        cmp     bx,[ bp + iStr ]; compara se esta no inicio da string
        je      LoopS

        dec     bx              ; decrementa bx
        cmp     dl,[ bp + iCol ]; compara se e igual a coluna inicial
        je      RolaTelaE
        dec     dl              ; decrementa a coluna
        jmp     LoopS           ; Leia caracter denovo

RolaTelaE:
        mov     ax,[ bp + PosT ]; decrementa posicao na tela
        dec     ax
        mov     [ bp + PosT ],ax

        jmp     LoopS

GotoIns:
        call    Fun_Ins         ; funcao testa o estado do cursor
        jmp     LoopS

TstHome:
        mov     bx,[ bp + iStr ]; bx recebe o inicio da string
        mov     dl,[ bp + iCol ]; dl recebe coluna inicial
        mov     [ bp + PosT ],bx; Posicao na tela vai para o inicio da string

        jmp     LoopS

TstEnd:
        xor     ax,ax
        mov     al,[ bp + TamA ]; ax recebe o tamanho atual da string
        mov     bx,[ bp + iStr ]; zera bx
        add     bx,ax
        cmp     al,[ bp + IntC ]; ( TamA < ( fCol - iCol ) nao role
        jge     EndRolaT        ; ultrapassa o limite da coluna role

        mov     al,[ bp + iCol ]
        add     al,[ bp + TamA ]
        mov     dl,al           ; dl = ( iCol + TamA )
        jmp     LoopS

EndRolaT:
        sub     al,[ bp + IntC ]; al = ( TamA - ( fCol - iCol ))
        mov     cx,[ bp + iStr ]
        mov     [ bp + PosT ],cx; zera posicao na tela
        add     [ bp + PosT ],al; PosT + al
        mov     dl,[ bp + fCol ]; dl vai para coluna final
        jmp     LoopS

ApagueC:
        mov     ax,[ bp + iStr ];empilha o inicio da string
        push    ax
        mov     ax,bx
        push    ax
        call    DelBack         ; funcao deleta caracter
        add     sp,4

        mov     al,LastKey
        cmp     al,BACK         ; se for igual a BACK role a tela
        je      Esquerda        ; rola tela a esquerda

        jmp     LoopS

FimGetStr:
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp

        pop     bp

        ret

GetStr  ENDP
;[]---------------------------------------------------------------------------[]
;[]                FUNCAO APAGA O CARACTER DA STRING                          []
;[] Parametros ( char * IniStr, char * PosStr )                               []
;[]---------------------------------------------------------------------------[]
DelBack PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    di

        mov     bx,[ bp + 4 ]   ; bx recebe o posicao da string

        mov     al,LastKey      ; al recebe a ultima tecla pressionada
        cmp     al,_DEL         ; compara se ‚ igual a Del
        je      ApagDB

        mov     di,[ bp + 6 ]   ; di recebe o inicio da string
        cmp     di,bx           ; se di igual bx e LastKey = Back
        je      EndDB           ; nao faca nada

        dec     bx

ApagDB:

        mov     di,bx           ; di recebe o endereco de bx
        inc     di              ; endereco de di + 1
LoopDB:
        mov     al,[ di ]
        mov     [ bx ],al
        inc     bx
        inc     di
        cmp     al,NULL         ; faz ate chegar ao final da string
        jnz     LoopDB

EndDB:
        pop     di
        pop     bx

        mov     sp,bp
        pop     bp

        ret

DelBack ENDP
;[]---------------------------------------------------------------------------[]
;[]              FUNCAO COLOCA CARACTER NO BUFFER DE STRING                   []
;[] Parametros ( char * String )                                              []
;[]---------------------------------------------------------------------------[]
Escreva PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    cx
        push    dx
        push    si
        push    di

        mov     bx,[ bp + 4 ]   ; bx recebe a posicao da string
        mov     dx,[ bp + 6 ]   ; dx recebe o endereco final da string
        mov     al,InsOnOff     ; move para al o estado da insercao
        cmp     al,OFF          ; se estiver desligado jogue por cima
        je      EndEscr

        mov     ax,bx           ;
        push    ax
        call    StrLen          ; tamanho da string do indice ate fim
        add     sp,2h
        add     ax,bx

        cmp     ax,dx           ; compara se a string ja chegou no limite do
        je      ToqueBeep       ; seu tamanho nao insira mais nada
                                ; e retorne em ax zera para tocar o Beep
        mov     si,ax

        mov     di,si
        dec     di
LoopEscr:
        mov     al,[ di ]
        mov     [ si ],al
        dec     di
        dec     si
        cmp     di,bx
        jge     LoopEscr
EndEscr:
        mov     al,LastKey
        mov     [ bx ],al
        jmp     RetEscr
ToqueBeep:
        xor     ax,ax

RetEscr:
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        mov     sp,bp
        pop     bp

        ret

Escreva ENDP
;[]---------------------------------------------------------------------------[]
;[]           FUNCAO IMPRIME STRING NA TELA COM LIMITE DE COLUNA              []
;[] Parametros ( int lin, int col, int colfinal, char * string )              []
;[]---------------------------------------------------------------------------[]
ImpStr  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx
        push    si

        xor     dx,dx
        xor     ax,ax

        mov     bx,[ bp + 4 ]   ; ax recebe endereco de string

        mov     dl,[ bp + 6 ]   ; dl recebe coluna final
        mov     al,[ bp + 8 ]   ; al recebe coluna inicial

        sub     dx,ax           ; dx guarda o intervalo na tela
        mov     ax,offset BuffStr; string destino
        push    ax
        mov     ax,bx           ; string origem
        push    ax
        mov     ax,dx
        push    ax
        call    StrnCpy
        add     sp,6h

        mov     ax,[ bp + 10 ]  ; empilha linha
        push    ax
        mov     ax,[ bp + 8 ]   ; coluna inicial
        push    ax
        mov     ax,offset BuffStr; endereco da string
        push    ax
        call    PutS
        add     sp,6h

        pop     si
        pop     dx
        pop     bx


        mov     sp,bp
        pop     bp

        ret

ImpStr  ENDP
;[]---------------------------------------------------------------------------[]
;[]                FUNCAO RETORNA O TAMANHO DA STRING EM AX                   []
;[] Paramentos ( char * string )                                              []
;[]---------------------------------------------------------------------------[]
StrLen  PROC    NEAR

        push    bp

        mov     bp,sp

        push    bx
        push    cx

        mov     bx,[ bp + 4 ]
        xor     cx,cx           ; cx contador do numero de caracteres da string
        mov     al,NULL         ; al recebe caracter NULO

LoopLen:
        cmp     [ bx ],al
        je      EndLen
        inc     bx
        inc     cx
        jmp     LoopLen
EndLen:
        mov     ax,cx           ; funcao retorna em ax o endereco da string

        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

StrLen  ENDP
;[]---------------------------------------------------------------------------[]
;[]         FUNCAO COPIA UMA STRING EM OUTRA DEFININDO ATE ONDE               []
;[] Paramentos : ( char * dest, char * origem, int Size )                     []
;[]---------------------------------------------------------------------------[]
StrnCpy PROC    NEAR

        push    bp

        mov     bp,sp

        push    bx
        push    di
        push    cx
        push    dx

        xor     cx,cx
        mov     dx,[ bp + 4 ]   ; dx recebe numero de caracteres a copiar
        mov     bx,[ bp + 6 ]   ; bx recebe o endereco da string origem
        mov     di,[ bp + 8 ]   ; di recebe o endereco da string destino
LoopC:
        cmp     cx,dx           ; compara se ja imprimiu todos
        je      EndCpy

        mov     al,[ bx ]       ; al recebe o caracter
        cmp     al,NULL         ; al for igual ao caracter nulo pare
        je      EndCpy

        mov     [ di ],al
        inc     di
        inc     bx
        inc     cx

        jmp     LoopC
EndCpy:        
        mov     al,NULL         ; finaliza a string com NULL
        mov     [ di ],al

        pop     dx
        pop     cx
        pop     di
        pop     bx

        mov     sp,bp
        pop     bp

        ret

StrnCpy ENDP
;[]---------------------------------------------------------------------------[]
;[]         FUNCAO COPIA UMA STRING EM OUTRA DEFININDO ATE ONDE               []
;[] Paramentos : ( char * dest, char * origem, int Size )                     []
;[]---------------------------------------------------------------------------[]
StrCpy  PROC    NEAR

        push    bp

        mov     bp,sp

        push    bx
        push    di
        push    cx
        push    dx

        xor     cx,cx
        mov     dx,[ bp + 4 ]   ; dx recebe numero de caracteres a copiar
        mov     bx,[ bp + 6 ]   ; bx recebe o endereco da string origem
        mov     di,[ bp + 8 ]   ; di recebe o endereco da string destino
LoopC2:
        cmp     cx,dx           ; compara se ja imprimiu todos
        je      EndCpy2

        mov     al,[ bx ]       ; al recebe o caracter

        mov     [ di ],al
        inc     di
        inc     bx
        inc     cx

        jmp     LoopC2
EndCpy2:
        mov     al,NULL         ; finaliza a string com NULL
        mov     [ di ],al

        pop     dx
        pop     cx
        pop     di
        pop     bx

        mov     sp,bp
        pop     bp

        ret

StrCpy  ENDP
;[]---------------------------------------------------------------------------[]
;[]                FUNCAO IMPRIME STRING NA MEMORIA DE VIDEO                  []
;[] Parametros ( int Lin, Int Col, char * String )                            []
;[]---------------------------------------------------------------------------[]
PutS    PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    cx
        push    dx
        push    es
        push    si

        mov     ax,VIDEO        ; VIDEO igual a segmento de video 0b800h
        mov     es,ax           ; di recebe segmento da memoria de video


        mov     al,[ bp + 8 ]   ; al recebe endereco de bp + 6 ( linha )
        mov     cl,0A0h
        mul     cl              ; multiplica conteudo de al vezes cl = 160
        mov     dx,ax           ; retorna valor em ax, e guarda em dx

        mov     al,[ bp + 6 ]   ; al recebe endereco de bp + 8 ( coluna )
        mov     cl,02h          ;
        mul     cl              ; conteudo de al vezes cl = 2

        add     dx,ax           ; adiciona ax mais dx

        mov     si,dx
        mov     bx,[ bp + 4 ]
LoopI:
        mov     al,[ bx ]
        cmp     al,NULL         ; compara se ds[ bx ] esta null
        je      EndImp          ; va para o final

        mov     es:[ si ],al
        inc     bx
        inc     si
        inc     si

        jmp     LoopI
EndImp:
        pop     si
        pop     es
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

PutS    ENDP
;[]---------------------------------------------------------------------------[]
;[]                       FUNCAO LIMPA A TELA                                 []
;[] Parametros ( word iLin|iCol, word fLin|fCol, int Atrib )
;[]---------------------------------------------------------------------------[]
Clear   PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    cx
        push    dx
        push    es
        push    si

        mov     ax,VIDEO        ; VIDEO igual a segmento de video 0b800h
        mov     es,ax           ; di recebe segmento da memoria de video

        xor     ax,ax
        xor     dx,dx

        mov     bx,[ bp + 8 ]   ; al  linha inicial
        mov     al,bh
        mov     cl,0A0h
        mul     cl              ; multiplica conteudo de al vezes cl = 160
        mov     dx,ax           ; retorna valor em ax, e guarda em dx

        mov     al,bl           ; al coluna inicial
        mov     cl,02h          ;
        mul     cl              ; conteudo de al vezes cl = 2

        add     dx,ax           ; adiciona ax mais dx

        mov     si,dx


        xor     ax,ax
        xor     dx,dx

        mov     bx,[ bp + 6 ]   ; al linha final
        mov     al,bh
        mov     cl,0A0h
        mul     cl              ; multiplica conteudo de al vezes cl = 160
        mov     dx,ax           ; retorna valor em ax, e guarda em dx

        mov     al,bl           ; al coluna final
        mov     cl,02h          ;
        mul     cl              ; conteudo de al vezes cl = 2

        add     dx,ax           ; adiciona ax mais dx

        mov     ax,[ bp + 4 ]
        mov     ah,20h
LoopClear:
        cmp     si,dx           ; se tiver chegado ao final da string
        jg      EndClear        ; para de limpar a tela

        mov     es:[ si ],ah    ; move para memoria de video espaco em branco
        inc     si
        mov     es:[ si ],al    ; move atributo para memoria de video
        inc     si

        jmp     LoopClear

EndClear:
        pop     si
        pop     es
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp
        ret

        ENDP
;[]---------------------------------------------------------------------------[]
;[]                 FUNCAO PEGA TECLA E RETORNA O CODIGO ASCII                []
;[]---------------------------------------------------------------------------[]
Inkey   PROC    NEAR

        mov     al,FALSE
        mov     Estend,al

        mov     ah,al           ; parametro para funcao int 21h
        int     16h
        cmp     al,FALSE        ; testa ‚ caracter estendido
        jnz     EndInKey

        add     ah,80h          ; ah recebe seu valor + 128
        mov     al,ah           ; al recebe ah para ser retornado

        mov     ah,TRUE
        mov     Estend,ah

        cmp     al,_INS         ; compara se foi pressiona Insercao
        je      TstIns          ;

        jmp     EndInkey
TstIns:
        mov     ah,InsOnOff     ; testa se insercao esta ligado ou desligado
        cmp     ah,ON           ; se estava ligado desligue
        je      DeslIns

        mov     ah,ON           ; se estava deligado  entao ligue a insercao
        mov     InsOnOff,ah

        jmp     EndInkey
DeslIns:
        mov     ah,OFF          ; desligando a insercao
        mov     InsOnOff,ah

EndInkey:

        mov     LastKey,al      ; LastKey recebe o valor da ultima tecla

        ret
InKey   ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO POSICIONA O CURSOR                            []
;[]---------------------------------------------------------------------------[]
Fun_Ins PROC    NEAR

        push    bx
        push    cx

        mov     ah,InsOnOff     ; ah recebe estado da insercao

        cmp     ah,ON           ; esta ligado
        je      InsON

        mov     bx,offset MsgInsOff
        mov     cx,0607h
        jmp     PrinIns
InsON:
        mov     bx,offset MsgInsOn
        mov     cx,0004h

PrinIns:
        mov     ax,0000h        ; empilha linha = 0
        push    ax
        mov     ax,004Bh        ; empilha coluna = 75
        push    ax
        mov     ax,bx           ; empilha endereco da string
        push    ax
        call    PutS
        add     sp,6

        mov     ah,01h
        int     10h

        pop     cx
        pop     bx

        ret

Fun_Ins ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO POSICIONA O CURSOR                            []
;[]---------------------------------------------------------------------------[]
Gotoxy  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx

        mov     dh,[ bp + 6 ]   ; dh recebe linha
        mov     dl,[ bp + 4 ]   ; dl recebe coluna
        mov     bh,00           ; define pagina de video
        mov     ah,02h
        int     10h

        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

Gotoxy  ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO FINALIZA O PROGRAMA                           []
;[]---------------------------------------------------------------------------[]
Fim     PROC    NEAR

        xor     ax,ax           ; posicao linha coluna inicial
        push    ax
        mov     ax,184Fh        ; linha coluna final
        push    ax
        mov     ax,07h
        push    ax
        call    Clear           ; procedimemto limpa a tela
        add     sp,6

        xor     ax,ax           ; linha = 0 coluna = 0
        push    ax              ; posiciona cursor
        push    ax              ;
        call    gotoxy          ; funcao posiciona cursor
        add     sp,4

        mov     cx,0607h        ; coloca o cursor no estado normal
        mov     ah,01h          ;
        int     10h

        mov     ah,4CH          ; retorna o controle ao DOS
        int     21h             ;

        ret

Fim     ENDP
;[]---------------------------------------------------------------------------[]
;[]                         FIM DO PROGRAMA                                   []
;[]---------------------------------------------------------------------------[]
        END MAIN                ; final do programa

