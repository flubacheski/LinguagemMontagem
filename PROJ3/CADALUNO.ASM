;[]--------------------------------------------------------------------------[]
;[]      NOME.......:    Fabio Gamarra Lubacheski                            []
;[]      PROGRAMA...:    CadAlun.Asm                                         []
;[]      OBJETIVO...:    O Programa faz cadastro, Alteracao, Consulta e      []
;[]                      Delecao guardando dados em arquivo                  []
;[]                                                                          []
;[]      PROFESSOR..:    ALMIR DE SOUZA                                      []
;[]      DATA.......:    11/10/94                                            []
;[]      HORA.......:    16:00                                               []
;[]--------------------------------------------------------------------------[]

        .MODEL small    ; modelo de dados a ser usados 64Kb para
                        ; o codigo

        .STACK 0900H    ; usado para reservar 1Kb de dados o stack


NoFile  equ        2h   ; Arquivo nao encontrado
BELL    equ        7h   ; campainha
CR      equ       0Dh   ; retorno do carro Enter
LF      equ       0Ah   ; Fim
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
Cr_Y    equ      019h   ; Crtl_Y
Cr_T    equ      014h   ; Crtl_T
Cr_U    equ      015h   ; Crtl_U
F2      equ      0BCh   ; F2
NULL    equ       00h   ; Caracter nulo
VIDEO   equ    0b800h   ; VIDEO guarda endereco da memoria de video
ON      equ        1h   ; Ativado
OFF     equ        0h   ; Desativado
TRUE    equ        1h
FALSE   equ        0h

;=====================================
; Variavel Local do Editor de Registro

ContReg    equ             - 2 ; Conta o numero de Registros
fCampo     equ ContReg     - 2 ; Marca o fim dos Campos
fBuffer    equ fCampo      - 2 ; Marca o fim do Buffer
SomaSize   equ fBuffer     - 2 ; Faz somatorio do Tamanho do Buffer
IniBuffer  equ SomaSize    - 2 ; Guarda o endereco do primeiro buffer
BecReg     equ IniBuffer  - 1024   ; 1Kb de Buffer para Becape

;===================================
; Variavel Local do Editor de Linha

iLin    equ        -1   ; Linha inicial
iCol    equ  iLin - 1   ; Coluna inicial
fCol    equ  iCol - 1   ; Coluna final
Tam     equ  fCol - 1   ; Tamanho da string
TamA    equ  Tam  - 1   ; Tamanho atual da string
IntC    equ  TamA - 1   ; Intervalo das colunas
iStr    equ  IntC - 2   ; Endereco inicial da String
fStr    equ  iStr - 2   ; Endereco final String
PosT    equ  fStr - 2   ; Guarda a posicao na tela para impressao
Empty   equ  PosT - 2   ; Se pode ser Vazio

;=====================
; Definicoes de Cor

Az_Am   equ  00011110b  ; Fundo Azul Letra Amarela
Az_Br   equ  00011111b  ; Fundo Azul Letra Branca
Br_Am   equ  01111110b  ; Fundo Branco com Letra Amarela
Br_Az   equ  01110001b  ; Fundo Branco com Letra Azul Claro
Ve_Br   equ  00101111b  ; Fundo Verde com Letra Branca
Br_Ng   equ  01110000b  ; Fundo Branco com Letra Preta
Ci_Br   equ  00111111b  ; Fundo Ciano com Letra Branca
Br_Br   equ  01111111b  ; Fundo Branco com Letra Branca
Ve_Ng   equ  00100000b  ; Fundo Verde com Letra Negra
Re_Br   equ  01001111b  ; Fundo Vermelho com Letra Branca
   
        .DATA           ; reentrada no segmento de dados DATA

Valid           db      0       ; Valida 'C' - Caracter, 'N' - Numeros

LastKey         db      0       ; guarda o valor da ultima tecla pressionada

Ctrl_Del        db      0       ; Testa se esta valendo Delecao do Registro

Deletado        db      0       ; Testa se Registro esta deletado

InsOnOff        db      0       ; guarda o estado da insercao

MsgInsOn        db      'Ins',0

MsgInsOff       db      '   ',0

Ctrl_Y_U        db      0

Estend          db      0       ; guarda se e caracter estendido

CharEsq         db      17,0
CharDir         db      16,0


; GetStr        Parameters(char * Msg , int lin, int col , int colfinal, int tam )

BufferCod       db      5  Dup ( NULL )
Registro        db      95 Dup ( NULL )

Codigo          db      07,15,'Matricula do Aluno ..: ',0
Nome            db      09,15,'Nome ................: ',0
Endereco        db      11,15,'Endereco ............: ',0
Cidade          db      13,15,'Cidade ..............: ',0
Serie           db      15,15,'Serie ...............: ',0

Campo1          dw      Codigo
                db      07,40,44,05,'N',1
                dw      BufferCod

VetReg1         dw      Campo1
                db      FALSE

Campo2          dw      Nome
                db      09,40,65,30,'C',1
                dw      Registro

Campo3          dw      Endereco
                db      11,40,60,30,'C',0
                dw      Registro + 30

Campo4          dw      Cidade
                db      13,40,60,30,'C',1
                dw      Registro + 60

Campo5          dw      Serie
                db      15,40,44,05,'N',1
                dw      Registro + 90

VetReg2         dw      Campo2
                dw      Campo3
                dw      Campo4
                dw      Campo5
                db      FALSE

OpcCad          db      08, 35,' Cadastra  ',0
                db      'Cadastro, Consulta, Alteracao e Delecao de Alunos',0

OpcRel          db      09, 35,' Relatorio ',0
                db      'Relatorio em Tela',0

OpcFim          db      10, 35,' Fim       ',0
                db      'Finaliza o Programa e Retorna ao Dos',0

VetMsg          dw      OpcCad, OpcRel, OpcFim

VetProc         dw      Cad, Rel, Fim

BecapeStr       db      255 Dup( Null )

BuffStr         db      255 Dup( Null )


MsgTela         db      'Manutencao de Alunos',0
MsgMenu         db      ' Menu Principal ',0

MsgCad          db      ' Cadastro de Alunos ',0
MsgIniC         db      ' Digite a Matricula do Aluno para Pesquisa ',0
MsgOpcoes       db      ' F2 - Deleta Registro ÄÄÄÄÄÄÄÄ Esc - Cancela e Retorna',0
MsgEnterEsc     db      ' Enter - Confirma              Esc - Cancela ',0
MsgConfC        db      ' Confirma Aluno ',0
MsgDel          db      ' Confirma a Delecao ',0
MsgRel          db      ' Relatorio de Alunos ',0
MsgRelO         db      ' Pressione Qualquer tecla para Continuar    Esc - Cancela ',0
MsgRelFim       db      '       Fim de Relatorio Pressione Qualquer Tecla        ',0
MsgRelInt       db      '     Relatorio Interrompido Pressione Qualquer Tecla     ',0
MsgFound        db      '      Aluno Encontrado - A L T E R A N D O      ',0
MsgNoFound      db      '   Aluno Nao Encontrado - C A D A S T R A N D O   ',0
    
Simples         db      'ÚÄ¿ÀÄÙ³³ '
Box             db      '°°°°°°°°°'
Duplo           db      'ÉÍ»ÈÍ¼ºº '

StrBorda        db      80 Dup( Null )

;===============================
; Variaveis de Arquivo


ArqDbf          db      'Alunos.Dbf',0          ; Arquivo de Registro
ArqNtx          db      'IndAluno.Ntx',0          ; Arquivo de Indice

HandleNtx       dw      0
HandleDbf       dw      0

Found           db      0
Eof             db      0

RecNo           dw      0                       ; Registro Corrente
NumReg          dw      0                       ; Numero de Registros
SizeReg         dw      100                      ; Tamanho dos Registros

BufferNtx       db      1024 Dup ( Null )       ; Quarda o Buffer em Arquivo

        .CODE           ; usado para reentrada no segmento de codigo
;[]---------------------------------------------------------------------------[]
;[]                         INICIO DO PROGRAMA                                []
;[]---------------------------------------------------------------------------[]
JUMPS
MAIN    PROC NEAR

        mov     ax,@DATA
        mov     ds,ax

        call    LoadArq

WhileMain:

        call    Menu                    ; procedimento imprime menu e espera uma tecla

        mov     bx,offset VetProc       ; Bx recebe endereco dos Procedimentos
        add     bx,ax                   ; Bx mais a opcao escolhida
        call    [ bx ]                  ; Chama a opcao escolhida

        jmp     WhileMain

        ret

MAIN    ENDP
;[]---------------------------------------------------------------------------[]
;[]        FUNCAO FAZ MENU E A TELA PRINCIPAL, RETORNA OPCAO ESCOLHIDA        []                     []
;[]---------------------------------------------------------------------------[]
Menu    PROC    NEAR

        push    bx
        push    cx

        mov     ax,0000
        push    ax
        mov     ah,02
        mov     al,79
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax, Az_Am
        push    ax
        call    Borda
        add     sp,8h


        mov     ah,03
        mov     al,00
        push    ax
        mov     ah,23
        mov     al,79
        push    ax
        mov     ax, offset Box
        push    ax
        mov     ax, Az_Br
        push    ax
        call    Borda
        add     sp,8h

        mov     ax,0001
        push    ax
        mov     ax,offset MsgTela
        push    ax
        call    Centra
        add     sp,4h

        mov     ah,05
        mov     al,25
        push    ax
        mov     ah,15
        mov     al,54
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Br_Br
        push    ax
        call    Borda
        add     sp,8h

        mov     al,05
        push    ax
        mov     ax,offset MsgMenu
        push    ax
        call    Centra
        add     sp,4h


        mov     ax,0003
        push    ax
        mov     ax, offset VetMsg
        push    ax
        call    MyMenu
        add     sp,4h

        pop     cx
        pop     bx

        ret

Menu    ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO FAZ A TELA DE CADASTRO                        []
;[]---------------------------------------------------------------------------[]
TelaCad PROC    NEAR

        push    ax

        mov     ah,05
        mov     al,10
        push    ax
        mov     ah,18
        mov     al,69
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Az_Br
        push    ax
        call    Borda
        add     sp,8h


        mov     ah,20
        mov     al,10
        push    ax
        mov     ah,22
        mov     al,69
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Re_Br
        push    ax
        call    Borda
        add     sp,8h

        mov     ax,0005
        push    ax
        mov     ax,offset MsgCad
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,0021
        push    ax
        mov     ax,offset MsgIniC
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,0018
        push    ax
        mov     ax,offset MsgOpcoes
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,offset Codigo
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Nome
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Endereco
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Cidade
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Serie
        push    ax
        call    _PutS
        add     sp,2h
        pop     ax

        ret

TelaCad ENDP                      
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO FAZ A TELA DE RELATORIO                       []
;[]---------------------------------------------------------------------------[]
TelaRel PROC    NEAR

        push    ax

        mov     ah,05
        mov     al,10
        push    ax
        mov     ah,18
        mov     al,69
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Az_Br
        push    ax
        call    Borda
        add     sp,8h


        mov     ah,20
        mov     al,10
        push    ax
        mov     ah,22
        mov     al,69
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Re_Br
        push    ax
        call    Borda
        add     sp,8h

        mov     ax,0005
        push    ax
        mov     ax,offset MsgRel
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,0021
        push    ax
        mov     ax,offset MsgRelO
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,offset Codigo
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Nome
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Endereco
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Cidade
        push    ax
        call    _PutS
        add     sp,2h

        mov     ax,offset Serie
        push    ax
        call    _PutS
        add     sp,2h
        pop     ax

        ret

TelaRel ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO FAZ A TELA DE EDICAO                          []
;[]---------------------------------------------------------------------------[]
Cad     PROC    NEAR

        push    ax

LoopCad:

        mov     al,FALSE
        mov     Ctrl_Del,al

        mov     ax,ds
        push    ax
        mov     ax,offset Registro
        push    ax
        mov     ax,0000
        push    ax
        mov     ax,95
        push    ax
        call    MemSet
        add     sp,8h

        mov     ax,ds
        push    ax
        mov     ax,offset BufferCod
        push    ax
        mov     ax,0000
        push    ax
        mov     ax,5
        push    ax
        call    MemSet
        add     sp,8h

        call    TelaCad

        mov     ax,offset VetReg1
        push    ax
        call    EditReg
        add     sp,2h

        mov     al,LastKey
        cmp     al,_ESC
        je      FimCad

        call    Seek                    ; Rotina procura o buffer no Arquivo
                                        ; se achar carrega no buffer Registro
        mov     al,Found                ; Testa se Encontrou
        cmp     al,FALSE
        je      _NoFound

_OkFound:

        mov     ax,0021
        push    ax
        mov     ax,offset MsgFound
        push    ax
        call    Centra
        add     sp,4h
        jmp     _EditRegistro

_NoFound:

        mov     ax,0021
        push    ax
        mov     ax,offset MsgNoFound
        push    ax
        call    Centra
        add     sp,4h

_EditRegistro:

        mov     ax,offset VetReg2
        push    ax
        call    EditReg
        add     sp,2h

        mov     al,LastKey

        cmp     al,_ESC
        je      LoopCad

        cmp     al,F2
        je      TecDelete

        mov     ax,offset MsgConfC     ; Confirma o cadastro
        push    ax
        call    EnterEsc
        add     sp,2h

        cmp     al,FALSE
        je      LoopCad

        call    Replace
        jmp     LoopCad

TecDelete:
        mov     ax,offset MsgDel        ; Confirma a Delecao
        push    ax
        call    EnterEsc
        add     sp,2h

        cmp     al,FALSE
        je      LoopCad

        call    Delete
        jmp     LoopCad
FimCad:
        pop     ax

        ret

Cad     ENDP
;[]---------------------------------------------------------------------------[]
;[]                  FUNCAO MARCA REGISTRO DELETADO                           []
;[]---------------------------------------------------------------------------[]
Delete  PROC    NEAR

        push    si

        mov     ax,RecNo
        mov     cx,0008h
        mul     cx

        mov     si,offset BufferNtx
        add     si,ax
        mov     al,TRUE         ; Recebe a marca de deletado
        mov     [ si ],al

        pop     si

        ret
Delete  ENDP
;[]---------------------------------------------------------------------------[]
;[]                  FUNCAO FAZ RELATORIO DO ARQUIVO                          []
;[]---------------------------------------------------------------------------[]
Rel     PROC    NEAR

        push    ax
        push    dx
        push    di


        mov     ax,OFF
        push    ax
        call    Cursor
        add     sp,2h

        xor     dx,dx

        mov     di,offset BufferNtx

WhileRel:
        call    TelaRel

TstOutro:
        inc     dx
        cmp     dx,NumReg               ; Testa se ja chegou ao fim do arquivo
        jg      FimRel

        mov     al,[ di ]               ; Move o status do Registro
        cmp     al,FALSE                ; testa se esta deletado
        je      FacaRel

        add     di,0008

        jmp     TstOutro

FacaRel:
        add     di,6                    ; recebe o numero de registro
        mov     ah,[ di ]               ;
        mov     al,[ di + 1 ]
        add     di,2

        push    dx
        mov     RecNo,ax                ; RecNo recebe o numero do arquivo                                         ;
                                        ; encontrado
        mov     cx,SizeReg
        mul     cx

        push    ax                      ; Qtd bytes a mover
        mov     ax,HandleDbf
        push    ax
        call    GotoFile
        add     sp,4h

        pop     dx

        mov     ax,HandleDbf
        push    ax
        mov     ax,5
        push    ax
        mov     ax,offset BufferCod
        push    ax
        call    ReadFile
        add     sp,6h

        mov     ax,HandleDbf
        push    ax
        mov     ax,95
        push    ax
        mov     ax,offset Registro
        push    ax
        call    ReadFile
        add     sp,6h

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,07                   ; empilha linha
        push    ax
        mov     al,40                   ; empilha coluna
        push    ax
        mov     al,44                   ; empilha coluna final
        push    ax
        mov     ax,offset BufferCod      ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,09                   ; empilha linha
        push    ax
        mov     al,40                   ; empilha coluna
        push    ax
        mov     al,65                   ; empilha coluna final
        push    ax
        mov     ax,offset Registro      ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,11                   ; empilha linha
        push    ax
        mov     al,40                   ; empilha coluna
        push    ax
        mov     al,60                   ; empilha coluna final
        push    ax
        mov     ax,offset Registro + 30 ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,13                   ; empilha linha
        push    ax
        mov     al,40                   ; empilha coluna
        push    ax
        mov     al,60                   ; empilha coluna final
        push    ax
        mov     ax,offset Registro + 60 ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,15                   ; empilha linha
        push    ax
        mov     al,40                   ; empilha coluna
        push    ax
        mov     al,44                   ; empilha coluna final
        push    ax
        mov     ax,offset Registro + 90 ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah

        call    Inkey

        mov     al,LastKey
        cmp     al,_ESC
        je      IntRel

        jmp     WhileRel

FimRel:
        mov     ax,0021
        push    ax
        mov     ax,offset MsgRelFim
        push    ax
        call    Centra
        add     sp,4h

        jmp     EndRel
IntRel:

        mov     ax,0021
        push    ax
        mov     ax,offset MsgRelInt
        push    ax
        call    Centra
        add     sp,4h

EndRel:
        call    Inkey

        mov     ax,ON
        push    ax
        call    Cursor
        add     sp,2h

        pop     di
        pop     dx
        pop     ax

        ret
Rel     ENDP
;[]---------------------------------------------------------------------------[]
;[]                      FUNCAO EDITA CAMPOS UM A UM                          []
;[] Parametros ( VetStruct Struct )                                           []
;[]---------------------------------------------------------------------------[]
EditReg PROC    NEAR

        push    bp
        mov     bp,sp

        sub     sp,40Ah                 ; 1 Kb para as variveis locais quarda
                                        ; o numero de campos
        push    bx
        push    cx
        push    dx
        push    di
        push    si

        xor     cx,cx
        mov     [ bp + SomaSize ],cx    ; zera o somatorio dos campos
        mov     di,[ bp + 4 ]           ; di recebe os campos

InicioReg:                              ; Imprima as Msg
        mov     bx,[ di ]
        mov     ax,[ bx ]
        push    ax
        call    _Puts
        add     sp,2h

        inc     bx
        inc     bx
        mov     si,[ bx + 6 ]           ; si recebe o endereco buffer

;; Faz Retangulo na Tela
 

;; Imprime String no Regangulo

        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,[ bx ]               ; empilha linha
        push    ax
        mov     al,[ bx + 1 ]           ; empilha coluna
        push    ax
        mov     al,[ bx + 2 ]           ; empilha coluna final
        push    ax
        mov     ax,si                   ; empilha o endereco da string
        push    ax
        call    ImpStr                  ; funcao imprime string
        add     sp,0Ah



;; Coloca o caracter '' se string for maior que o retangulo

        mov     ax,si                   ; empilha o endereco inicial da string
        push    ax
        call    StrLen                  ; calcula o tamanho atual da string
        add     sp,2h

        mov     dh,[ bx + 1 ]           ; dh recebe coluna inicial
        mov     dl,[ bx + 2 ]           ; dl recebe coluna final
        sub     dl,dh
        cmp     al,dl                   ; se tamanho da string for maior
        jle     PuleEdit                ; que intervalo das colunas

        mov     al,[ bx ]               ; linha
        push    ax
        mov     al,[ bx + 2 ]           ; coluna final
        inc     al
        push    ax
        mov     ax,offset CharDir
        push    ax
        call    PutS
        add     sp,6h

PuleEdit:
        mov     [ bp + fCampo ],di      ; guarda o fim do camp
        mov     [ bp + fBuffer],si      ; guarda o fim do buffer
        xor     ax,ax
        mov     al,[ bx + 3 ]
        add     si,ax
        add     [ bp + SomaSize ], ax   ; Soma o Tamaho dos Campos
        inc     di
        inc     di
        inc     cx
        mov     al,[ di ]
        cmp     al,FALSE
        jne     InicioReg

        dec     cx
        mov     [ bp  + ContReg ],cx    ; guarda em uma variavel local o numero de campos

        mov     di,[ bp + 4 ]           ; di recebe os campos
        mov     bx,[ di ]
        inc     bx                      ; Pule endereco da Msg
        inc     bx
        mov     si,[ bx + 6 ]           ; recebe o endereco do buffer
        mov     [ bp + IniBuffer ],si   ; guarda o inicio do buffer
        xor     cx,cx

;;  Becape do Registro
        mov     ax,ss
        push    ax
        mov     ax,[ bp + BecReg ]
        push    ax
        mov     ax,ds
        push    ax
        mov     ax,[ bp + IniBuffer ]   ; ax recebe endereco do primeiro buffer
        push    ax
        xor     ax,ax
        mov     al,[ bp + SomaSize ]
        push    ax
        call    MoveMem
        add     sp,0Ah

LoopEdit:
        mov     bx,[ di ]
        inc     bx
        inc     bx
        mov     si,[ bx + 6 ]           ; recebe o endereco do buffer

        mov     ax,bx
        push    ax
        mov     ax,si
        push    ax
        call    GetStr
        add     sp,4h

        mov     al,LastKey

        cmp     al,CR
        je      TecEnter

        cmp     al,UP
        je      TecUp

        cmp     al,PgUP
        je      TecPgUp

        cmp     al,DOWN
        je      TecDown

        cmp     al,PgDn
        je      TecPgDn

        cmp     al,F2           ;
        je      TecF2

        cmp     al,_ESC
        je      FimEditEsc

        jmp     LoopEdit

TecUp:
        cmp     cx,NULL                 ; Testa se cx igual a zero
        je      LoopEdit

        dec     cx
        dec     di
        dec     di

        jmp     LoopEdit

TecPgUp:
        mov      di,[ bp + 4 ]
        xor      cx,cx

        jmp     LoopEdit

TecEnter:
        cmp     cx,[ bp + ContReg ]
        je      FimEdit
TecDown:
        cmp     cx,[ bp + ContReg ]     ; Testa se Esta no ultimo registro
        je      LoopEdit

        inc     cx

        inc     di
        inc     di

        jmp     LoopEdit

TecPgDn:
        mov     cx,[ bp + ContReg ]     ; cx recebe o numero de Registros
        add     cx,cx
        mov     di,[ bp + 4 ]
        add     di,cx
        mov     cx,[ bp + ContReg ]     ; cx recebe o numero de Registros
        jmp     LoopEdit

TecF2:
        mov     al,Ctrl_Del             ; Testa se Esta valendo Delecao
        cmp     al,FALSE
        je      LoopEdit


        jmp     FimEdit

FimEditEsc:
;;  Becape do Registro   // Restaurando

        mov     ax,ds
        push    ax
        mov     ax,[ bp + IniBuffer ]   ; ax recebe endereco do primeiro buffer
        push    ax
        mov     ax,ss
        push    ax
        mov     ax,[ bp + BecReg ]
        push    ax
        xor     ax,ax
        mov     al,[ bp + SomaSize ]
        push    ax
         call    MoveMem
        add     sp,0Ah

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

        sub     sp,0Eh          ; reserva 12 bytes ou 6 words como variavel local
                                ; a 1a word para linha e coluna
                                ; 2a word  para coluna final e tamanho maximo em bytes
                                ; 3a word  para tamanho atual e intervalo de coluna
                                ; 4a word  para endereco inicial da string
                                ; 5a word  para endereco final da string
                                ; 6a word  para a posicao na tela a imprimir

        push    bx
        push    cx
        push    dx
        push    di

        xor     bx,bx
        xor     cx,cx
        xor     dx,dx

        mov     Ctrl_Y_U,cl     ; nenhuma linha apagada

        mov     bx,[ bp + 6 ]   ; bx recebe o as definicoes da string
        mov     di,[ bp + 4 ]   ; di recebe o endereco da string

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
        dec     al
        mov     [ bp + Tam ],al ; variavel guarda tamanho maximo da string

        inc     bx
        mov     al,[ bx ]
        mov     Valid,al        ; Valid recebe a validacao 'C' ou 'N'

        inc     bx
        xor     ax,ax
        mov     al,[ bx ]
        mov     [ bp + Empty  ],ax

        mov     cl,[ bp + iCol ]; cl recebe coluna inicial
        mov     al,[ bp + fCol ]; al recebe coluna final
        sub     ax,cx           ; subtrai coluna final - coluna inicial
        mov     [ bp + IntC ],al; guarda na variavel

        mov     [ bp + iStr ],di; recebe o endereco inicial da string
        mov     bx,di

        xor     cx,cx           ; zera cx
        mov     cl,[ bp + Tam ] ; cx recebe quantos caracteres a ler
        add     cx,bx           ; calcula o endereco final da string
        mov     [ bp + fStr ],cx; guarda o endereco final da string

        mov     [ bp + PosT ],bx; guarda a posicao na tela para rolagem

        mov     [ bp + iStr ],di; recebe o endereco inicial da string

LoopS:
        mov     ax,[ bp + iStr ]; empilha o endereco inicial da string
        push    ax
        call    StrLen          ; calcula o tamanho atual da string
        add     sp,2h
        mov     [ bp + TamA ],al; guarda na variavel tamanho atual da string

        mov     ax,Ve_Br
        push    ax
        mov     al,[ bp + iLin ]; empilha linha
        push    ax
        mov     al,[ bp + iCol ]; empilha coluna
        push    ax
        mov     al,[ bp + fCol ]; empilha coluna final
        push    ax
        mov     ax,[ bp + PosT ]; empilha o endereco da string
        push    ax
        call    ImpStr          ; funcao imprime string
        add     sp,0Ah

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

        cmp     al,Cr_T         ; se al ‚ ^T
        je      _Ctrl_T

        cmp     al,Cr_Y         ; se al ‚ ^Y
        je      _Ctrl_Y

        cmp     al,Cr_U         ; se al ‚ ^U
        je      _Ctrl_U

        cmp     al,_ESC
        je      NaoVazio

        cmp     al,CR           ; se al ‚ Enter
        je      FimGetStr       ; va para o fim da string

        mov     ah,Estend       ; ah recebe se e' caracter estendido
        cmp     ah,TRUE         ;
        je      FimGetStr       ; va para final

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
        cmp     ax,NULL         ; se Insercao estava ligado e ja encheu ou
        je      LoopS           ; nao foi aceita a validacao
                                ; o buffer nao faca nada

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
        cmp     bx,[ bp + iStr ]; compara se esta no inicio da lstring
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
        mov     al,[ bp + iStr ]
        mov     [ bp + PosT ],al
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

_Ctrl_T:
        mov     ax,bx
        push    ax
        call    Crtl_T
        add     sp,2h

        jmp     LoopS

_Ctrl_Y:
        mov     al,[ bp + TamA ]        ; se ja estiver vazia nao apage
        cmp     al,NULL
        je      LoopS

        mov     bx,[ bp + iStr ]        ; zera as variaveis
        mov     dl,[ bp + iCol ]
        mov     [ bp + PosT ],bx

        mov     ax,bx
        push    ax
        mov     ax,[ bp + Tam ]
        push    ax
        call    Crtl_Y
        add     sp,4h

        jmp     LoopS


_Ctrl_U:
        mov     al,Ctrl_Y_U
        cmp     al,NULL
        je      LoopS

        mov     bx,[ bp + iStr ]        ; zera as variaveis
        mov     dl,[ bp + iCol ]
        mov     [ bp + PosT ],bx

        mov     ax,bx
        push    ax
        mov     ax,[ bp + Tam ]
        push    ax
        call    Crtl_U
        add     sp,4h

        jmp     LoopS
FimGetStr:
        mov     ax,[ bp + iStr ]
        push    ax
        call    StrLen          ; testa se o buffer esta vazio
        add     sp,2h

        cmp     ax,NULL
        jne     NaoVazio

        cmp     ax,[ bp + Empty ] ; se nao poder ser vazio volte
        je      NaoVazio

        jmp     Loops

NaoVazio:
        mov     ax,Br_Ng
        push    ax
        xor     ax,ax
        mov     al,[ bp + iLin ]; empilha linha
        push    ax
        mov     al,[ bp + iCol ]; empilha coluna
        push    ax
        mov     al,[ bp + fCol ]; empilha coluna final
        push    ax
        mov     ax,[ bp + iStr ]; empilha o endereco da string
        push    ax
        call    ImpStr          ; funcao imprime string
        add     sp,0Ah

        pop     di
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

        mov     al, LastKey
        cmp     al,48           ;; Testa se ‚ menor de um numero
        jl      TstValid

        cmp     al,57
        jg      TstValid        ;; nao foi precionado um numero

        jmp     Continue

TstValid:
        mov     al,Valid
        cmp     al,'N'          ; se digitou uma letra e Valid == 'N'
        jne     Continue

        xor     ax,ax

        jmp     RetEscr

Continue:

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
;[]                       FUNCAO APAGA UMA PALAVRA                            []
;[] Parametros (  char * string )                                             []
;[]---------------------------------------------------------------------------[]
Crtl_T  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    di
        push    si

        mov     bx,[ bp + 4 ]
        mov     di,bx

WhilePare:
        mov     al,[ di ]
        cmp     al,' '
        jle     EndPare

        inc     di

        jmp     WhilePare

EndPare:

WhileEspaco:
        mov     al,[ di ]
        cmp     al,' '
        jne     EndEspaco

        inc     di
        jmp     WhileEspaco

EndEspaco:

WhileApgWord:
        mov     al,[ di ]
        mov     [ bx ],al
        cmp     al,NULL
        je      EndApgWord

        inc     di
        inc     bx

        jmp     WhileApgWord

EndApgWord:

WhileFimWord:
        cmp     bx,di
        je      EndFimWord

        mov     al,NULL
        mov     [ bx ],al

        inc     bx

        jmp     WhileFimWord

EndFimWord:

        pop     si
        pop     di
        pop     bx

        mov     sp,bp
        pop     bp

        ret

Crtl_T  ENDP
;[]---------------------------------------------------------------------------[]
;[]                       FUNCAO APAGA UMA LINHA                              []
;[] Parametros (  char * string, int Tam )                                    []
;[]---------------------------------------------------------------------------[]
Crtl_Y  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx

        xor     dx,dx

        mov     bx,[ bp + 6 ]   ; endereco da string

        mov     dl,[ bp + 4 ]   ; tamanho da string

        mov     ax,offset BecapeStr
        push    ax
        mov     ax,bx
        push    ax
        mov     ax,dx
        push    ax
        call    StrnCpy
        add     sp,6h

        mov     al,TRUE
        mov     Ctrl_Y_U,al

        mov     al,NULL

WhileLinha:

        mov     [ bx ],al
        inc     bx
        cmp     [ bx ],al
        jne     WhileLinha

        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

Crtl_Y  ENDP
;[]---------------------------------------------------------------------------[]
;[]                       FUNCAO APAGA UMA LINHA                              []
;[] Parametros (  char * string , int Tam )                                             []
;[]---------------------------------------------------------------------------[]
Crtl_U  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx

        xor     dx,dx

        mov     bx,[ bp + 6 ]   ; endereco da string
        mov     dl,[ bp + 4 ]   ; tamanho da string

        mov     ax,bx
        push    ax
        mov     ax,offset BecapeStr
        push    ax
        mov     ax,dx
        push    ax
        call    StrnCpy
        add     sp,6h

        mov     al,NULL
        mov     Ctrl_Y_U,al

        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

Crtl_U  ENDP
;[]---------------------------------------------------------------------------[]
;[]           FUNCAO IMPRIME STRING NA TELA COM LIMITE DE COLUNA              []
;[] Parametros ( int cor, int lin, int col, int colfinal, char * string )              []
;[]---------------------------------------------------------------------------[]
ImpStr  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx
        push    si


        mov     ah,[ bp + 10 ]          ; empilha linha
        mov     al,[ bp + 8  ]          ; coluna inicial
        dec     al                      ; limpa coluna inicial - 1
        push    ax
        mov     ah,[ bp + 10 ]          ; linha final
        mov     al,[ bp + 6  ]          ; coluna final
        inc     al                      ; limpa coluna final + 1
        push    ax
        xor     ax,ax
        mov     al,[ bp + 12 ]
        push    ax
        call    Clear
        add     sp,6h

        xor     dx,dx
        xor     ax,ax

        mov     bx,[ bp + 4 ]           ; ax recebe endereco de string

        mov     dl,[ bp + 6 ]           ; dl recebe coluna final
        mov     al,[ bp + 8 ]           ; al recebe coluna inicial

        sub     dx,ax                   ; dx guarda o intervalo na tela
        mov     ax,offset BuffStr       ; string destino
        push    ax
        mov     ax,bx                   ; string origem
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
        mov     al,[ bx ]       ; al recebe o caracter
        mov     [ di ],al
        inc     di
        inc     bx
        inc     cx

        cmp     cx,dx           ; compara se ja imprimiu todos
        jl      LoopC

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
;[] Paramentos : ( char (Seg:Off) * dest, char (Seg:Off) * origem, int Size ) []          []
;[]---------------------------------------------------------------------------[]
MoveMem PROC    NEAR

        push    bp

        mov     bp,sp

        push    bx
        push    cx
        push    dx
        push    di
        push    es
        push    ds

        mov     dx,[ bp + 4 ]   ; dx recebe quanto caracteres a mover
        mov     bx,[ bp + 6 ]   ; bx recebe o Offset da string origem
        mov     ax,[ bp + 8 ]   ; ax recebe o Segmento da string origem
        mov     ds,ax

        mov     di,[ bp + 10]   ; di recebe o Offset da string destino
        mov     ax,[ bp + 12]   ; ax recebe o Segmento da string destino
        mov     es,ax

        xor     cx,cx
MoveLoop:
        mov     al,ds:[ bx ]
        mov     es:[ di ],al
        inc     di
        inc     bx
        inc     cx
        cmp     cx,dx
        jle     MoveLoop

        pop     ds
        pop     es
        pop     di
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

MoveMem ENDP
;[]---------------------------------------------------------------------------[]
;[]         FUNCAO PREENCHE UM BUFFER COM UM DETERMINADO CARACTER             []
;[] Paramentos : ( char (Seg:Off) * dest, char Car, int Quantos )             []
;[]---------------------------------------------------------------------------[]
MemSet  PROC    NEAR

        push    bp

        mov     bp,sp

        push    bx
        push    dx
        push    cx
        push    es

        xor     cx,cx
        mov     dx,[ bp + 4 ]   ; Quantos Caracter
        mov     bx,[ bp + 8 ]   ; bx recebe o Offset da string destino
        mov     ax,[ bp + 10]   ; ax recebe o Segmento da string destino
        mov     es,ax

        dec     dx

        mov     al,[ bp + 6 ]   ; caracter para preencher o buffer
MemLoop:
        mov     es:[ bx ],al
        inc     bx
        inc     cx
        cmp     cx,dx
        jl      MemLoop

        mov     al,Null
        mov     es:[ bx ],al

        pop     es
        pop     cx
        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

MemSet  ENDP
;[]---------------------------------------------------------------------------[]
;[]                FUNCAO RECEBE STRING TRATA E MANDA PARA PUTS               []
;[] Parametros (  char * String )                                             []
;[]---------------------------------------------------------------------------[]
_PutS    PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx

        xor     ax,ax

        mov     bx,[ bp + 4 ]           ; ax recebe endereco da string
        mov     al,[ bx ]               ; recebe a linha
        push    ax
        inc     bx
        mov     al,[ bx ]               ; recebe a coluna
        push    ax
        inc     bx
        mov     ax, bx                  ; recebe o endereco da string
        push    ax
        call    Puts
        add     sp,6h

        pop     bx

        mov     sp,bp
        pop     bp

        ret

_PutS    ENDP
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
        sub     sp,4h

        push    bx
        push    cx
        push    dx
        push    es
        push    si

        mov     ax,VIDEO        ; VIDEO igual a segmento de video 0b800h
        mov     es,ax           ; di recebe segmento da memoria de video

        xor     ax,ax
        xor     dx,dx

        mov     bx,[ bp + 8 ]   ;
        mov     al,bh           ; al recebe linha inicial
        mov     cl,160
        mul     cl              ; multiplica conteudo de al vezes cl = 160
        mov     dx,ax           ; retorna valor em ax, e guarda em dx

        mov     al,bl           ; al coluna inicial
        mov     cl,02h          ;
        mul     cl              ; conteudo de al vezes cl = 2

        add     dx,ax           ; adiciona ax mais dx

        mov     si,dx

        mov     ax,[ bp + 4 ]
        mov     ah,20h

        mov     bx,[ bp + 6 ]   ; linha e Coluna Final
        mov     cx,[ bp + 8 ]   ; Lin e Coluna Inicial
        mov     [ bp - 2 ],cl   ; guarda na variavel local a coluna final
        mov     [ bp - 4 ],si   ; guarda o inicio do deslocamento
LoopClear:

        mov     es:[ si ],ah    ; move para memoria de video espaco em branco
        inc     si
        mov     es:[ si ],al    ; move atributo para memoria de video
        inc     si
        inc     cl
        cmp     cl,bl           ; compara se coluna ja chegou na coluna final
        jle     LoopClear

        mov     si,[ bp - 4 ]
        add     si,160          ; incrementa si mais 160
        mov     [ bp - 4],si
        mov     cl,[ bp - 2 ]
        inc     ch
        cmp     ch,bh           ; compara se a linha ja chegou na linha final
        jle     LoopClear


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
        mov     cx,0804h

PrinIns:
        mov     ax,0001h        ; empilha linha = 0
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


;==================
; Salva o ntx


        mov     ax,OFF           ; procedimento desliga o Cursor
        push    ax
        call    Cursor
        add     sp,2h

        xor     ax,ax
        push    ax
        mov     ax,HandleNtx
        push    ax
        call    GotoFile        ; movimenta o ponteiro para o inicio do
        add     sp,4h           ; do arquivo

        mov     ax,HandleNtx
        push    ax
        mov     ax,0002
        push    ax
        mov     ax,offset NumReg
        push    ax
        call    ReplFile                ; Grava o NumReg em Arquivo
        add     sp,6h

        mov     ax,HandleNtx
        push    ax
        mov     ax,0002
        push    ax
        mov     ax,offset SizeReg
        push    ax
        call    ReplFile                ; Grava o SizeReg em Arquivo
        add     sp,6h

        mov     ax,HandleNtx
        push    ax
        mov     ax,1024
        push    ax
        mov     ax,offset BufferNtx
        push    ax
        call    ReplFile                ; Grava o BufferNtx em Arquivo
        add     sp,6h


        mov     ax,HandleDbf
        push    ax              ; Funcao fecha Arquivo Alunos.Ntx
        call    CloseFile
        add     sp,2h

        mov     ax,HandleNtx
        push    ax              ; Funcao fecha Arquivo IndAluno.Ntx
        call    CloseFile
        add     sp,2h

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
        push    ax
        call    gotoxy          ; funcao posiciona cursor
        add     sp,4

        mov     ax,ON           ; procedimento liga o Cursor
        push    ax
        call    Cursor
        add     sp,2h

        mov     ah,4CH          ; retorna o controle ao DOS
        int     21h

        ret

Fim     ENDP
;[]---------------------------------------------------------------------------[]
;[]                            FUNCAO FAZ BORDA                               []
;[] Parametros ( int Lin, char *Str )                                         []
;[]---------------------------------------------------------------------------[]
Centra  PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    cx

        mov     bx,[ bp + 4 ]           ; bx recebe a String
        mov     ax,bx
        push    ax
        call    strlen                  ; calcula o tamanho da string
        add     sp,2h
                                        ; ( ( 80 - len )/2 )
        mov     cx,80
        sub     cx,ax                   ; 80 - Len

        shr     cx,1                    ; divide o tamanho por dois

        xor     ax,ax
        mov     al,[ bp + 6 ]           ; Linha para impressao
        push    ax
        mov     ax,cx
        push    ax
        mov     ax,[ bp + 4 ]           ; * Str
        push    ax
        call    Puts
        add     sp,6h

        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp
        ret

Centra  ENDP
;[]---------------------------------------------------------------------------[]
;[]                            FUNCAO FAZ BORDA                               []
;[] Parametros ( int Lin1, int Col1, int Lin2, int Col2, char *Str, int Cor ) []
;[]---------------------------------------------------------------------------[]
Borda   PROC    NEAR

        push    bp
        mov     bp,sp

        sub     sp,6h                   ; Lin1, Col1, Lin2, Col2


        push    bx
        push    dx
        push    di


        mov     bx,[ bp + 6 ]

        mov     ax,[ bp + 8 ]           ; Lin2, Col2
        mov     [ bp - 3 ],ah           ; Lin2
        mov     [ bp - 4 ],al           ; Col2

        mov     ax,[ bp + 10]           ; Lin1, Col1
        mov     [ bp - 1 ],ah           ; Lin1
        mov     [ bp - 2 ],al           ; Col1

        mov     ah,[ bp - 1 ]           ; Lin1
        mov     al,[ bp - 2 ]           ; Col1
        push    ax
        mov     ah,[ bp - 3 ]           ; Lin2
        mov     al,[ bp - 4 ]           ; Col2
        push    ax
        xor     ax,ax
        mov     al,[ bp + 4 ]           ; Cor para limpar a Tela
        push    ax
        call    Clear
        add     sp,6h

        xor     ax,ax
        mov     al,[ bp - 4 ]           ; Col2
        mov     ah,[ bp - 2 ]           ; Col1
        sub     al,ah                   ; Col2 - Col1
        mov     [ bp - 5 ],al           ; al recebe intervalo Col2 - Col1

;; Traco de Cima
        mov     di,offset StrBorda
        mov     al,[ bx ]
        mov     [ di ] ,al
        inc     di

        mov     ax,ds
        push    ax
        push    di
        xor     ax,ax
        mov     al,[ bx + 1 ]
        push    ax
        mov     al,[ bp - 5 ]
        push    ax
        call    MemSet
        add     sp,8h

        xor     ax,ax
        mov     al,[ bp - 5 ]
        dec     ax
        add     di,ax
        mov     al,[ bx + 2 ]
        mov     [ di ], al
        inc     di
        mov     [ di ],ah

        xor     ax,ax
        mov     al,[ bp - 1 ]
        push    ax
        mov     al,[ bp - 2 ]
        push    ax
        mov     ax,offset StrBorda
        push    ax
        call    Puts
        add     sp,6h


;; Traco de Baixo

        mov     di,offset StrBorda
        mov     al,[ bx + 3 ]
        mov     [ di ] ,al
        inc     di

        mov     ax,ds
        push    ax
        push    di
        xor     ax,ax
        mov     al,[ bx + 4 ]
        push    ax
        mov     al,[ bp - 5 ]
        push    ax
        call    MemSet
        add     sp,8h

        xor     ax,ax
        mov     al,[ bp - 5 ]
        dec     ax
        add     di,ax
        mov     al,[ bx + 5 ]
        mov     [ di ], al
        inc     di
        mov     [ di ],ah

        xor     ax,ax
        mov     al,[ bp - 3 ]
        push    ax
        mov     al,[ bp - 2 ]
        push    ax
        mov     ax,offset StrBorda
        push    ax
        call    Puts
        add     sp,6h

;; O Meio da Borda

        mov     di,offset StrBorda
        mov     al,[ bx + 6 ]
        mov     [ di ] ,al
        inc     di

        mov     ax,ds
        push    ax
        push    di
        xor     ax,ax
        mov     al,[ bx + 8 ]
        push    ax
        mov     al,[ bp - 5 ]
        push    ax
        call    MemSet
        add     sp,8h

        xor     ax,ax
        mov     al,[ bp - 5 ]
        dec     ax
        add     di,ax
        mov     al,[ bx + 7 ]
        mov     [ di ], al
        inc     di
        mov     [ di ],ah

        xor     dx,dx
        mov     dl,[ bp - 1 ]           ; dl recebe linha
        inc     dl

WhileBorda:
        xor     ax,ax
        mov     al,dl
        push    ax
        mov     al,[ bp - 2 ]
        push    ax
        mov     ax,offset StrBorda
        push    ax
        call    Puts
        add     sp,6h

        inc     dl
        cmp     dl,[ bp - 3 ]
        jl      WhileBorda

        pop     di
        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp
        ret

Borda   ENDP
;[]---------------------------------------------------------------------------[]
;[]                            FUNCAO FAZ BORDA                               []
;[] Parametros ( int Qtd , Vetor *Opcoes )                                        []
;[]---------------------------------------------------------------------------[]
MyMenu  PROC    NEAR

        push    bp
        mov     bp,sp
        sub     sp,6h

        push    bx
        push    cx
        push    dx
        push    di
        push    si

        xor     dx,dx                   ; Guarda a opcao

        mov     bx,[ bp + 4 ]
        mov     si,[ bx ]

        mov     ah,[ si ]
        mov     al,[ si + 1 ]
        mov     [ bp - 2 ],ax

        mov     ax,si
        push    ax
        call    StrLen
        add     sp,2h

        mov     [ bp - 4 ],ax           ; guarda o tamanho da string
        mov     ax,[ bp - 2 ]
        add     ah,[ bp + 6 ]           ; Linha mais Qtd
        add     al,[ bp - 4 ]           ; Coluna inicial mais tamanho
        mov     [ bp - 6 ],ax

        mov     ax,[ bp + 6 ]
        dec     ax
        mov     [ bp + 6 ],ax

        mov     ax,OFF                  ; desliga cursor
        push    ax
        call    Cursor
        add     sp,2h

WhileMenu2:
        mov     bx,[ bp + 4 ]
        mov     di,[ bx ]

        mov     ax,[ bp - 2 ]
        push    ax
        mov     ax,[ bp - 6 ]
        push    ax
        mov     ax,Br_Ng
        push    ax
        call    Clear
        add     sp,6h

        xor     cx,cx

WhileMenu1:
        mov     di,[ bx ]
        mov     ax,di
        push    ax
        call    _PutS
        add     sp,2h

        inc     cx
        inc     bx
        inc     bx

        cmp     cx,[ bp + 6 ]
        jle     WhileMenu1

        mov     ah,[ si ]
        mov     al,[ si + 1 ]
        push    ax
        add     al,[ bp - 4 ]           ; recebe o tamanho de primeira string
        sub     al,3                    ; subtrai menos linha e coluna
        push    ax
        mov     ax,Ve_Ng
        push    ax
        call    Clear
        add     sp,6h


        mov     ax,si
        push    ax
        call    _PutS
        add     sp,2h

        mov     ah,24
        mov     al,00
        push    ax
        mov     ah,24
        mov     al,79
        push    ax
        mov     ax,Br_Ng
        push    ax
        call    Clear
        add     sp,6h

        add     si,[ bp - 4 ]
        inc     si

        mov     ax,0024
        push    ax
        mov     ax,si
        push    ax
        call    Centra
        add     sp,4h

ValidInKey:
        call    inkey

        cmp     al,CR
        je      FimMyMenu

        cmp     al,DOWN                 ; Testa se ‚ seta para baixo
        je      MyDown
        cmp     al,UP                   ; Testa se ‚ seta para cima
        je      MyUp

        jmp     ValidInkey

MyDown:
        cmp     dx,[ bp + 6 ]           ; dx ja esta em baixo
        je      RolaCima

        mov     bx,[ bp + 4 ]
        inc     dx

        push    dx
        add     dx,dx
        add     bx,dx
        pop     dx

        mov     si,[ bx ]
        jmp     WhileMenu2

RolaCima:
        xor     dx,dx
        mov     bx,[ bp + 4 ]
        mov     si,[ bx ]

        jmp     WhileMenu2


MyUp:
        cmp     dx,NULL                 ; dx ja esta em Cima
        je      RolaBaixo

        mov     bx,[ bp + 4 ]

        dec     dx

        push    dx
        add     dx,dx
        add     bx,dx
        pop     dx

        mov     si,[ bx ]
        jmp     WhileMenu2

RolaBaixo:
        mov     dx,[ bp + 6 ]
        mov     bx,[ bp + 4 ]

        push    dx
        add     dx,dx
        add     bx,dx
        pop     dx

        mov     si,[ bx ]

        jmp     WhileMenu2

FimMyMenu:

        mov     ax,ON
        push    ax
        call    Cursor
        add     sp,2h

        add     dx,dx
        mov     ax,dx

        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

MyMenu  ENDP
;[]-----------------------------------------------------------------------------[]
;[]                   Funcao Para mudar a forma do cursor
;[]     parametros: 0 - Desliga, 1 - Liga   , 2 - Solido
;[]---------------------------------------------------------------------------[]
Cursor  PROC    NEAR

        push    bp
        mov     bp,sp

        push    cx
        push    dx

        mov     dx, word ptr[bp + 4]

        cmp     dx,1
        je      CursorOn
        cmp     dx,2
        je      CursorSol

        mov cx,2000h
        mov ah,01h       ;chamada da funcao 10h para tipo de cursor
        int 10h

        jmp FimCursor


CursorOn:

        mov cx,0607h
        mov ah,01h       ;chamada da funcao 10h para tipo de cursor
        int 10h
        jmp FimCursor

CursorSol:
        mov cx,0804h
        mov ah,01h       ;chamada da funcao 10h para tipo de cursor
        int 10h

        jmp FimCursor

FimCursor:

        pop     dx
        pop     cx

	mov     sp,bp
	pop     bp

	ret

Cursor  ENDP
;[]---------------------------------------------------------------------------[]
;[]                       FUNCAO ABRE E CARREGA ARQUIVO                       []
;[]---------------------------------------------------------------------------[]
LoadArq PROC    NEAR

        push    ax

        mov     ax,offset ArqNtx
        push    ax
        call    OpenFile
        add     sp,2h
        mov     HandleNtx,ax

        cmp     ax,NoFile       ; Arquivo nao encontrado
        je      CrieNtx

;==================
; Carrega o ntx

        mov     ax,HandleNtx
        push    ax
        mov     ax,0002
        push    ax
        mov     ax,offset NumReg
        push    ax
        call    ReadFile                ; rotina le arquivo
        add     sp,6h

        mov     ax,HandleNtx
        push    ax
        mov     ax,0002
        push    ax
        mov     ax,offset SizeReg
        push    ax
        call    ReadFile                ; rotina le arquivo
        add     sp,6h

        mov     ax,HandleNtx
        push    ax
        mov     ax,1042
        push    ax
        mov     ax,offset BufferNtx
        push    ax
        call    ReadFile                ; rotina le arquivo
        add     sp,6h

        jmp     OpenDbf

CrieNtx:
        mov     ax,offset ArqNtx        ; rotina Cria Arquivo
        push    ax
        call    UseFile
        add     sp,2h
        mov     HandleNtx,ax            ; retorna o Handle

OpenDbf:
        mov     ax,offset ArqDbf
        push    ax
        call    OpenFile
        add     sp,2h
        mov     HandleDbf,ax

        cmp     ax,NoFile               ; Arquivo nao Encontrado
        jne     FimLoad

        mov     ax,offset ArqDbf        ; rotina Cria Arquivo
        push    ax
        call    UseFile
        add     sp,2h
        mov     HandleDbf,ax            ; retorna o Handle

FimLoad:
        pop     ax

        ret
LoadArq ENDP
;[]---------------------------------------------------------------------------[]
;[]                    PROCURA EM ARQUIVO PELA CHAVE                          []
;[]---------------------------------------------------------------------------[]
Seek    PROC    NEAR

        push    bp
        mov     bp,sp

        sub     sp,2h

        push    bx
        push    cx
        push    dx
        push    di

        xor     dx,dx

        mov     di,offset BufferNtx

WhileEof:
        mov     [ bp - 2 ],di
        mov     bx,offset BufferCod
        xor     cx,cx

        mov     al,[ di ]               ; Move o status do Registro
        cmp     al,TRUE                 ; testa se esta deletado
        je      TstEof

        inc     di
WhileComp:
        mov     al,[ bx ]

        cmp     al,[ di ]
        jne     TstEof

        inc     bx
        inc     di
        inc     cx

        cmp     cx,5
        je      OkFound

        jmp WhileComp

TstEof:
        mov     di,[ bp - 2 ]
        add     di,0008
        inc     dx
        mov     ax,NumReg
        cmp     dx,ax
        jle     WhileEof

NoFound:
        mov     di,[ bp - 2 ]
        add     di,8
        mov     al,BufferNtx[ di ]
        cmp     al,NULL
        jne     WhileEof

        mov     Found,al                ; Found recebe False
        mov     ax,NumReg
        mov     RecNo,ax

        jmp     FimFound
OkFound:
        mov     di,[ bp - 2 ]
        mov     al,TRUE
        mov     Found,al                ; Found recebe True
        mov     Ctrl_Del,al             ; Ctrl_Del recebe True
        add     di,6
        mov     ah,[ di ]
        mov     al,[ di + 1 ]

        mov     RecNo,ax                ; RecNo recebe o numero do arquivo                                         ;
                                        ; encontrado
        mov     cx,SizeReg
        mul     cx

        push    ax                      ; Qtd bytes a mover
        mov     ax,HandleDbf
        push    ax
        call    GotoFile
        add     sp,4h

        mov     ax,HandleDbf
        push    ax
        mov     ax,5
        push    ax
        mov     ax,offset BufferCod
        push    ax
        call    ReadFile
        add     sp,6h

        mov     ax,HandleDbf
        push    ax
        mov     ax,95
        push    ax
        mov     ax,offset Registro
        push    ax
        call    ReadFile
        add     sp,6h

FimFound:

        pop     di
        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

Seek    ENDP
;[]---------------------------------------------------------------------------[]
;[]                       FUNCAO ABRE E CARREGA ARQUIVO                       []
;[]---------------------------------------------------------------------------[]
Replace PROC    NEAR

        mov     ax,RecNo
        mov     cx,SizeReg
        mul     cx

        push    ax                      ; empilha Qtd de bytes a movimentar
        mov     ax,HandleDbf            ; empilha o Handle do arquivo dbf
        push    ax
        call    GotoFile
        add     sp,4h

        mov     ax,HandleDbf
        push    ax
        mov     ax,0005
        push    ax
        mov     ax,offset BufferCod
        push    ax
        call    ReplFile                ; escreve no arquivo o codigo
        add     sp,6h

        mov     ax,HandleDbf
        push    ax
        mov     ax,0095
        push    ax
        mov     ax,offset Registro
        push    ax
        call    ReplFile                ; escreve no arquivo o Registro
        add     sp,6h

        mov     al,Found
        cmp     al,TRUE                 ; Se for verdadeiro nao precisa
        je      FimReplace              ; atualizar o arquivo ntx

        mov     ax,NumReg
        mov     cx,0008h
        mul     cx

        mov     si,offset BufferNtx
        add     si,ax
        mov     di,offset BufferCod

        mov     al,FALSE                ; Guarda se esta deletado sim ou nao
        mov     [ si ],al               ; nao esta deletado

        inc     si

        mov     cx,0005
WhileReplace:
        mov     al,[ di ]
        mov     [ si ],al
        inc     si
        inc     di
        dec     cx
        cmp     cx,NULL
        jne     WhileReplace

        mov     ax,NumReg
        mov     [ si ],ah
        mov     [ si + 1 ],al
        inc     ax
        mov     NumReg,ax

FimReplace:

        ret

Replace ENDP
;[]---------------------------------------------------------------------------[]
;[]                           FUNCAO ABRE  ARQUIVO                            []
;[]---------------------------------------------------------------------------[]
OpenFile PROC    NEAR

        push    bp
        mov     bp,sp

        push    dx

        mov     al,02h
        mov     ah,3Dh
        mov     dx,[ bp + 4 ]
        int     21h

        pop     dx

        mov     sp,bp
        pop     bp

        ret

OpenFile ENDP        
;[]---------------------------------------------------------------------------[]
;[]                 FUNCAO CRIA ARQUIVO E RETORNA O HANDLE                    []
;[] Parametros ( char *NomeFile ) Retorna o Handle                            []
;[]---------------------------------------------------------------------------[]
UseFile  PROC    NEAR

        push    bp
        mov     bp,sp

        push    cx
        push    dx

        xor     ax,ax

        mov     ah,3Ch
        mov     cx,00h
        mov     dx,[ bp + 4 ]   ; Nome do Arquivo
        int     21h

        pop     dx
        pop     cx

        mov     sp,bp
        pop     bp

        ret

UseFile ENDP
;[]---------------------------------------------------------------------------[]
;[]                 FUNCAO MOVIMENTO O PONTEIRO DO ARQUIVO                    []
;[] Parametros ( int Qtd_Bytes_Movimentar, File *Handle )                     []
;[]---------------------------------------------------------------------------[]
 GotoFile PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    cx
        push    dx

        mov     bx,[ bp + 4 ]           ; recebe o Handle do arquivo
        xor     cx,cx
        mov     dx,[ bp + 6 ]           ; recebe Qtd de bytes a movimentar
        mov     ah,42h
        mov     al,00
        int     21h

        pop     dx
        pop     cx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

GotoFile ENDP
;[]---------------------------------------------------------------------------[]
;[]              FUNCAO LE ARQUIVO ARQUIVO  E JOGA PARA BUFFER                []
;[] Parametros( File *Handle, int Qtd_Bytes, char *Buffer )                   []
;[]---------------------------------------------------------------------------[]
ReadFile PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx
        push    cx

        xor     ax,ax

        mov     bx,[ bp + 8 ]           ; recebe o Handle
        mov     cx,[ bp + 6 ]           ; recebe a Quantidade de bytes a ler
        mov     dx,[ bp + 4 ]           ; Offset do buffer
        mov     ah,3Fh
        int     21h

        pop     cx
        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

ReadFile ENDP
;[]---------------------------------------------------------------------------[]
;[]                    FUNCAO ESCREVE NO ARQUIVO ARQUIVO                      []
;[] Parametros( File *Handle, int Qtd_Bytes, char *Buffer )                   []
;[]---------------------------------------------------------------------------[]
ReplFile PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx
        push    dx
        push    cx

        xor     ax,ax

        mov     bx,[ bp + 8 ]           ; recebe o Handle
        mov     cx,[ bp + 6 ]           ; recebe a Quantidade de bytes a escrever
        mov     dx,[ bp + 4 ]           ; Offset do buffer
        mov     ah,40h
        int     21h

        pop     cx
        pop     dx
        pop     bx

        mov     sp,bp
        pop     bp

        ret

ReplFile ENDP
;[]---------------------------------------------------------------------------[]
;[]                           FUNCAO FECHA ARQUIVO                            []
;[] Parametros ( File * Handle )                                              []
;[]---------------------------------------------------------------------------[]
CloseFile PROC    NEAR

        push    bp
        mov     bp,sp

        push    bx

        mov     ah,3Eh          ; Funcao fecha Arquivo
        mov     bx,[ bp + 4 ]
        int     21h

        pop     bx

        mov     sp,bp
        pop     bp

        ret

CloseFile ENDP
;[]---------------------------------------------------------------------------[]
;[]               FUNCAO IMPRIME MSG E TESTA ENTER OU ESC                     []
;[] Parametros ( char * Str  )                                                []
;[]---------------------------------------------------------------------------[]
EnterEsc  PROC    NEAR

        push    bp
        mov     bp,sp

        mov     ax,OFF
        push    ax
        call    Cursor
        add     sp,2h

        mov     ah,20
        mov     al,10
        push    ax
        mov     ah,22
        mov     al,69
        push    ax
        mov     ax, offset Simples
        push    ax
        mov     ax,Re_Br
        push    ax
        call    Borda
        add     sp,8h

        mov     ax,0020
        push    ax
        mov     ax,[ bp + 4 ]
        push    ax
        call    Centra
        add     sp,4h

        mov     ax,0021
        push    ax
        mov     ax,offset MsgEnterEsc
        push    ax
        call    Centra
        add     sp,4h

_EntEsc:
        call    Inkey

        cmp     al,CR
        je      _Enter

        cmp     al,_ESC
        je      __ESC

        jmp     _EntEsc

_Enter:
        mov     ax,TRUE
        jmp     _FimEsc

__Esc:
        mov     ax,FALSE

_FimEsc:

        push    ax
        mov     ax,ON
        push    ax
        call    Cursor
        add     sp,2h
        pop     ax

        mov     sp,bp
        pop     bp

        ret

EnterEsc  ENDP
;[]---------------------------------------------------------------------------[]
;[]                         FIM DO PROGRAMA                                   []
;[]---------------------------------------------------------------------------[]
        END MAIN                ; final do programa
