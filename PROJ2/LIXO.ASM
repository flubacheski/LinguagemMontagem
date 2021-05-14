LIXO_TEXT	segment byte public 'CODE'
LIXO_TEXT	ends

DGROUP	group	_DATA,_BSS
	assume	cs:LIXO_TEXT,ds:DGROUP

_DATA	segment word public 'DATA'

	d@	label	byte
	d@w	label	word

_DATA	ends

_BSS	segment word public 'BSS'

	b@	label	byte
	b@w	label	word

_BSS	ends

_DATA	segment word public 'DATA'

_LastKey	label	word
	db	0
	db	0
_insercao	label	word
	db	0
	db	0
_letra	label	word
	db	7
	db	0
_fundo	label	word
	db	0
	db	0
_getAtivo	label	word
	db	0
	db	0
_LinhasHelp	label	word
	db	0
	db	0
_HelpAtivo	label	word
	db	0
	db	0
_EstadoCursor	label	word
	db	1
	db	0
_MenuAtivo	label	word
	db	0
	db	0
_DATA	ends
LIXO_TEXT	segment byte public 'CODE'
	;
	;	void Limpa( int col, int lin, int col2, int lin2)
	;
	assume	cs:LIXO_TEXT

@Limpa$qiiii	proc	far

	push	bp
	mov	bp,sp
	;
	;	{
	;		window(col,lin,col2,lin2);
	;
	push	word ptr [bp+12]
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _window
	add	sp,8
	;
-   ;		clrscr();
	;
	call	far ptr _clrscr
	;
	;		window(1,1,80,25);
	;
	push	25
	push	80
	push	1
	push	1
	call	far ptr _window
	add	sp,8
	;
	;	}
	;
	pop	bp
	ret
@Limpa$qiiii	endp

	;
	;	void Cursor(int tipo)
	;
	assume	cs:LIXO_TEXT

@Cursor$qi	proc	far
	push	bp
	mov	bp,sp
	push	si
	mov	si,word ptr [bp+6]
	;
	;	{
	;		if ( tipo  == ON ){
	;
	cmp	si,1
	jne	short @2@86
	;
	;			_setcursortype ( _NORMALCURSOR );
	;
	push	2
	call	far ptr __setcursortype
	pop	cx
	;
	;			 EstadoCursor = tipo;
	;
	mov	word ptr DGROUP:_EstadoCursor,si
@2@86:
	;
	;		}
	;		if ( tipo  == OFF ){
	;
	or	si,si
	jne	short @2@142
	;
	;			_setcursortype ( _NOCURSOR );
	;
	push	0
	call	far ptr __setcursortype
	pop	cx
	;
	;			EstadoCursor  = tipo;
	;
	mov	word ptr DGROUP:_EstadoCursor,si
@2@142:
	;
	;		}
	;		if ( tipo  == 2 ){
	;
	cmp	si,2
	jne	short @2@198
	;
	;			_setcursortype ( _SOLIDCURSOR );
	;
	push	1
	call	far ptr __setcursortype
	pop	cx
	;
	;			EstadoCursor = tipo;
	;
	mov	word ptr DGROUP:_EstadoCursor,si
@2@198:
	;
	;		}
	;	 }
	;
	pop	si
	pop	bp
	ret
@Cursor$qi	endp
	;
	;	int Inkey ( void )
	;
	assume	cs:LIXO_TEXT
@Inkey$qv	proc	far
	push	si
	;
	;	{
	;		int tecla = 0;
	;
	;
	;		tecla = getch();
	;
	call	far ptr _getch
	mov	si,ax
	;
	;		if ( tecla == 0 ){
	;
	or	si,si
	jne	short @3@86
	;
	;			tecla = getch();
	;
	call	far ptr _getch
	mov	si,ax
	;
	;			tecla = tecla - 256 ;
	;
	add	si,-256
@3@86:
	;
	;		}
	;		if ( tecla == INS && MenuAtivo == OFF ){
	;
	cmp	si,-174
	jne	short @3@226
	cmp	word ptr DGROUP:_MenuAtivo,0
	jne	short @3@226
	;
	;			if( insercao == OFF ){
	;
	cmp	word ptr DGROUP:_insercao,0
	jne	short @3@198
	;
	;				Cursor(2);
	;
	push	2
	push	cs
	call	near ptr @Cursor$qi
	pop	cx
	;
	;				insercao = ON;
	;
	mov	word ptr DGROUP:_insercao,1
	;
	;			}
	;
	jmp	short @3@226
@3@198:
	;
	;			else{
	;				Cursor(1);
	;
	push	1
	push	cs
	call	near ptr @Cursor$qi
	pop	cx
	;
	;				insercao = OFF;
	;
	mov	word ptr DGROUP:_insercao,0
@3@226:
	;
	;			}
	;		}
	;		if ( tecla == F1 && HelpAtivo == TRUE ){
	;
	cmp	si,-197
	jne	short @3@310
	cmp	word ptr DGROUP:_HelpAtivo,1
	jne	short @3@310
	;
	;			HelpAtivo = FALSE;
	;
	mov	word ptr DGROUP:_HelpAtivo,0
@3@310:
	;
	;		}
	;	LastKey = tecla;
	;
	mov	word ptr DGROUP:_LastKey,si
	;
	;	return( tecla );
	;
	mov	ax,si
	;
	;	}
	;
	pop	si
	ret
@Inkey$qv	endp



	;
	;	void  GetStr( int iCol, int iLin,int fCol, char *Valid, char *str, int Tam )
	;
	assume	cs:LIXO_TEXT
@GetStr$qiiinuct4i	proc	far
	enter	10,0
	push	si
	push	di
	;
	;	{
	;		int i 		= FALSE,	// Indice do vetor da string
	;
	xor	si,si
	;
	;			teclaInt= FALSE,   	// Pega tecla
	;
	;
	;			pCol    = FALSE,    // Coluna na tela
	;
	;
	;			Print 	= TRUE,   	// Testa se ‚ para imprimir
	;
	mov	word ptr [bp-4],1
	;
	;			cursor  = ON,       // Guarda estado do cursor
	;
	;
	;			PosTela = FALSE,	// Guarda a partir de onde imprimir
	;
	mov	word ptr [bp-8],0
	;
	;			iFinal  = FALSE;    // Guarda o final da string
	;
	;
	;
	;		Limpa ( iCol - 1,iLin,fCol + 1,iLin); // Limpa posicao da string
	;
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+10]
	inc	ax
	push	ax
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+6]
	dec	ax
	push	ax
	push	cs
	call	near ptr @Limpa$qiiii
	add	sp,8
	;
	;		pCol = iCol;                          // pCol recebe coluna inicial
	;
	mov	di,word ptr [bp+6]
	;
	;		iFinal = strlen( str );
	;
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	call	far ptr _strlen
	add	sp,4
	mov	word ptr [bp-10],ax
@4@58:
	;
	;
	;		while( TRUE ){
	;
	;			cursor = EstadoCursor;
	;
	mov	ax,word ptr DGROUP:_EstadoCursor
	mov	word ptr [bp-6],ax
	;
	;			Cursor( OFF );
	;
	push	0
	push	cs
	call	near ptr @Cursor$qi
	pop	cx
	;
	;
	;			if ( Print == TRUE ){
	;
	cmp	word ptr [bp-4],1
	jne	short @4@114
	;
	;				PrintStr( iCol, iLin, fCol, PosTela, str );
	;
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	push	word ptr [bp-8]
	push	word ptr [bp+10]
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr @PrintStr$qiiiinuc
	add	sp,12
	;
	;				Print = FALSE;
	;
	mov	word ptr [bp-4],0
@4@114:
	;
	;			}
	;
   ;			if (  iFinal >  i + ( fCol - pCol )){  	// Se tamanho da string for
   ;	
	mov	ax,word ptr [bp+10]
	sub	ax,di
	mov	dx,si
	add	dx,ax
	cmp	dx,word ptr [bp-10]
	jge	short @4@170
   ;	
   ;				gotoxy( fCol + 1, iLin );           // Maior que espaco na tela
	;
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+10]
	inc	ax
	push	ax
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;				cprintf("%c",16);
	;
	push	16
	push	ds
	push	offset DGROUP:s@
	call	far ptr _cprintf
	add	sp,6
   ;	
   ;			}
   ;	
	jmp	short @4@254
@4@170:
	;
   ;			else{
   ;				gotoxy( fCol + 1, iLin );
   ;	
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+10]
	inc	ax
	push	ax
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;				putchar(' ');
   ;	
	inc	word ptr DGROUP:__streams+20
	jge	short @4@226
	les	bx,dword ptr DGROUP:__streams+32
	inc	word ptr DGROUP:__streams+32
	mov	al,32
	mov	byte ptr es:[bx],al
	mov	ah,0
	jmp	short @4@254
@4@226:
	push	ds
	push	offset DGROUP:__streams+20
	push	32
	call	far ptr __fputc
	add	sp,6
@4@254:
   ;	
	;			}
   ;	
   ;			if (  PosTela > 0 ){       //  Se ja estiver rolado tela
   ;	
	cmp	word ptr [bp-8],0
	jle	short @4@310
   ;	
   ;				gotoxy( iCol - 1, iLin );
   ;	
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+6]
	dec	ax
	push	ax
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;				cprintf("%c",17);
   ;	
	push	17
	push	ds
	push	offset DGROUP:s@+3
	call	far ptr _cprintf
	add	sp,6
   ;	
   ;			}
   ;	
	jmp	short @4@394
@4@310:
   ;	
   ;			else{
   ;				gotoxy( iCol - 1, iLin );
	;
	push	word ptr [bp+8]
	mov	ax,word ptr [bp+6]
	dec	ax
	push	ax
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;				putchar(' ');
	;
	inc	word ptr DGROUP:__streams+20
	jge	short @4@366
	les	bx,dword ptr DGROUP:__streams+32
	inc	word ptr DGROUP:__streams+32
	mov	al,32
	mov	byte ptr es:[bx],al
	mov	ah,0
	jmp	short @4@394
@4@366:
	push	ds
	push	offset DGROUP:__streams+20
	push	32
	call	far ptr __fputc
	add	sp,6
@4@394:
   ;	
   ;			}
   ;	
   ;			gotoxy(pCol, iLin);
	;
	push	word ptr [bp+8]
	push	di
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;			Cursor( cursor );
   ;	
	push	word ptr [bp-6]
	push	cs
	call	near ptr @Cursor$qi
	pop	cx
   ;	
   ;	
   ;			teclaInt = Inkey();
   ;	
	push	cs
	call	near ptr @Inkey$qv
	mov	word ptr [bp-2],ax
   ;	
	;
   ;			if ( teclaInt == ESC || teclaInt == ENTER )
   ;	
	cmp	word ptr [bp-2],27
	jne	@@0
	jmp	@4@1570
@@0:
	cmp	word ptr [bp-2],13
	jne	@@1
	jmp	@4@1570
@@1:
	;
   ;				break;
   ;	
   ;			if ( teclaInt == ESQUERDA && i > 0 ){
   ;	
	cmp	word ptr [bp-2],-181
	jne	short @4@618
	or	si,si
	jle	short @4@618
	;
   ;				if ( pCol > iCol )
   ;	
	cmp	di,word ptr [bp+6]
	jle	short @4@562
   ;	
   ;					pCol--;
   ;	
	dec	di
	jmp	short @4@590
@4@562:
	;
   ;				else{
   ;					PosTela--;
   ;	
	dec	word ptr [bp-8]
   ;	
   ;					Print = TRUE;
   ;	
	mov	word ptr [bp-4],1
@4@590:
   ;	
   ;				}
   ;	
   ;				i--;
   ;	
	dec	si
@4@618:
   ;	
   ;			}
   ;	
	;			if ( teclaInt == DIREITA && i < iFinal){
   ;	
	cmp	word ptr [bp-2],-179
	jne	short @4@786
	cmp	si,word ptr [bp-10]
	jge	short @4@786
   ;	
   ;				if ( pCol <  fCol  )  // Se dentr do limite
   ;	
	cmp	di,word ptr [bp+10]
	jge	short @4@730
   ;	
   ;					pCol++;           // da tela incremente col
   ;	
	inc	di
	jmp	short @4@758
@4@730:
   ;	
   ;				else{
   ;					PosTela++;        // Senao role a Tela
	;
	inc	word ptr [bp-8]
   ;	
   ;					Print = TRUE;
   ;	
	mov	word ptr [bp-4],1
@4@758:
   ;	
   ;				}
	;				i++;
   ;	
	inc	si
@4@786:
   ;	
   ;			}
   ;	
   ;			if ( teclaInt == HOME ){
   ;	
	cmp	word ptr [bp-2],-185
	jne	short @4@898
	;
   ;				if ( i >= (fCol - iCol ) ) // Se fora do limite reescreva a tela
   ;	
	mov	ax,word ptr [bp+10]
	sub	ax,word ptr [bp+6]
	cmp	ax,si
	jg	short @4@870
   ;	
   ;					Print = TRUE;
	;
	mov	word ptr [bp-4],1
@4@870:
   ;	
   ;	
   ;				PosTela =  i = 0;          // Zera as variaveis
   ;	
	xor	si,si
	mov	ax,si
	mov	word ptr [bp-8],ax
   ;	
	;				pCol = iCol;
   ;	
	mov	di,word ptr [bp+6]
@4@898:
   ;	
   ;			}
   ;	
   ;			if ( ( teclaInt == DEL && i < iFinal ) || ( teclaInt == BACK && i > 0)){
   ;	
	cmp	word ptr [bp-2],-173
	jne	short @4@954
	cmp	si,word ptr [bp-10]
	jl	short @4@1010
@4@954:
	cmp	word ptr [bp-2],8
	jne	short @4@1206
	or	si,si
	jle	short @4@1206
@4@1010:
   ;	
	;				Fun_Apage( str, i);
   ;	
	push	si
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	call	far ptr @Fun_Apage$qnuci
	add	sp,6
   ;	
   ;				Print  = TRUE;
	;
	mov	word ptr [bp-4],1
   ;	
   ;				iFinal = strlen( str );
   ;	
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	call	far ptr _strlen
	add	sp,4
	mov	word ptr [bp-10],ax
   ;	
	;				if ( teclaInt == BACK ){
   ;	
	cmp	word ptr [bp-2],8
	jne	short @4@1206
   ;	
   ;					if ( iFinal ==  (fCol - iCol) - 1 ){ // Se Tamanho da string
   ;	
	mov	ax,word ptr [bp+10]
	sub	ax,word ptr [bp+6]
	dec	ax
	cmp	ax,word ptr [bp-10]
	jne	short @4@1094
   ;	
   ;						PosTela = 0;					 // Atingiu o limite da tela reescreva
   ;	
	mov	word ptr [bp-8],0
   ;	
   ;						pCol    = fCol - 1;				 // A tela
   ;	
	mov	di,word ptr [bp+10]
	dec	di
   ;	
   ;	
   ;					}
   ;	
	jmp	short @4@1150
@4@1094:
   ;	
   ;					else if ( pCol > iCol ) // Decremente a coluna
	;
	cmp	di,word ptr [bp+6]
	jle	short @4@1150
   ;	
   ;						pCol--;
   ;	
	dec	di
@4@1150:
   ;	
   ;	
   ;					i--;
	;
	dec	si
   ;	
   ;					if ( i < PosTela )
   ;	
	cmp	si,word ptr [bp-8]
	jge	short @4@1206
   ;	
   ;						PosTela = i;
	;
	mov	word ptr [bp-8],si
@4@1206:
   ;	
   ;				}
   ;	
   ;			}
   ;	
   ;			if ( teclaInt == END  ){
   ;	
	cmp	word ptr [bp-2],-177
	jne	short @4@1346
   ;	
   ;				if ( iFinal < ( fCol - iCol )){
   ;	
	mov	ax,word ptr [bp+10]
	sub	ax,word ptr [bp+6]
	cmp	ax,word ptr [bp-10]
	jle	short @4@1290
   ;	
	;					pCol = iCol + iFinal;
   ;	
	mov	di,word ptr [bp+6]
	add	di,word ptr [bp-10]
   ;	
   ;				}
   ;	
	jmp	short @4@1318
@4@1290:
   ;	
   ;				else{
	;					 PosTela = iFinal - ( fCol - iCol );
   ;	
	mov	ax,word ptr [bp+10]
	sub	ax,word ptr [bp+6]
	mov	dx,word ptr [bp-10]
	sub	dx,ax
	mov	word ptr [bp-8],dx
   ;	
   ;					 pCol = fCol;
	;
	mov	di,word ptr [bp+10]
   ;	
   ;					 i = iFinal;
   ;	
	;
   ;					 Print = TRUE;
   ;	
	mov	word ptr [bp-4],1
@4@1318:
   ;	
	;				}
   ;				i = iFinal;
   ;	
	mov	si,word ptr [bp-10]
@4@1346:
   ;	
   ;			}
   ;			if ( strchr(Valid,teclaInt) && ( iFinal < Tam - 1  || ( insercao == ON && i < iFinal ))){
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp+14]
	push	word ptr [bp+12]
	call	far ptr _strchr
	add	sp,6
	or	ax,dx
	jne	@@2
	jmp	@4@58
@@2:
	mov	ax,word ptr [bp+20]
	dec	ax
	cmp	ax,word ptr [bp-10]
	jg	short @4@1458
	cmp	word ptr DGROUP:_insercao,1
	je	@@3
	jmp	@4@58
@@3:
	cmp	si,word ptr [bp-10]
	jl	@@4
	jmp	@4@58
@@4:
@4@1458:
   ;	
   ;				Escreva( str, i, teclaInt);
   ;	
	push	word ptr [bp-2]
	push	si
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	call	far ptr @Escreva$qnucii
	add	sp,8
	;
   ;				iFinal = strlen( str );
   ;	
	push	word ptr [bp+18]
	push	word ptr [bp+16]
	call	far ptr _strlen
	add	sp,4
	mov	word ptr [bp-10],ax
   ;	
	;				if ( pCol <  fCol ){
   ;	
	cmp	di,word ptr [bp+10]
	jge	short @4@1514
   ;	
   ;					pCol++;
   ;	
	inc	di
   ;	
   ;				}
   ;	
	jmp	short @4@1542
@4@1514:
   ;	
   ;				else{
   ;					PosTela++;
   ;	
	inc	word ptr [bp-8]
@4@1542:
   ;	
	;				}
   ;				Print = TRUE;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;				i++;
   ;	
	inc	si
	jmp	@4@58
@4@1570:
   ;	
	;			}
   ;	
   ;		}
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
@GetStr$qiiinuct4i	endp
   ;	
   ;	void Fun_Apage( char *str ,int Pos )
   ;	
	assume	cs:LIXO_TEXT
@Fun_Apage$qnuci	proc	far
	enter	4,0
	push	si
	mov	si,word ptr [bp+10]
	;
   ;	{
	;		char *STR;
   ;	
   ;		if ( ( STR = new char ) == NULL ){
   ;	
	push	1
	call	far ptr @$bnew$qui
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
	or	ax,dx
	jne	short @5@86
   ;	
   ;			cputs("Erro na alocacao de memoria");
   ;	
	push	ds
	push	offset DGROUP:s@+6
	call	far ptr _cputs
	add	sp,4
   ;	
   ;			exit(0);
	;
	push	0
	call	far ptr _exit
	pop	cx
@5@86:
   ;	
   ;		}
   ;	
   ;		if ( LastKey == DEL ){
	;
	cmp	word ptr DGROUP:_LastKey,-173
	jne	short @5@142
   ;	
   ;			strncpy( STR, str, Pos );
   ;	
	push	si
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strncpy
	add	sp,10
   ;	
   ;			STR [ Pos ] = FALSE;
   ;	
	les	bx,dword ptr [bp-4]
	add	bx,si
	mov	byte ptr es:[bx],0
   ;	
	;			strcat( STR, &str[ Pos + 1 ]);
   ;	
	mov	ax,si
	add	ax,word ptr [bp+6]
	inc	ax
	jmp	short @5@170
@5@142:
   ;	
   ;		}
   ;		else{
   ;			strncpy( STR, str,Pos);
	;
	push	si
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strncpy
	add	sp,10
   ;	
	;			STR [ Pos - 1 ] = FALSE;
   ;	
	les	bx,dword ptr [bp-4]
	mov	byte ptr es:[bx+si-1],0
   ;	
   ;			strcat(STR,&str[ Pos ]);
   ;	
	mov	ax,word ptr [bp+6]
	add	ax,si
@5@170:
	push	word ptr [bp+8]
	push	ax
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strcat
	add	sp,8
   ;	
   ;		}
   ;		STR[ strlen(str) - 1 ] = FALSE ;
   ;	
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _strlen
	add	sp,4
	dec	ax
	les	bx,dword ptr [bp-4]
	add	bx,ax
	mov	byte ptr es:[bx],0
   ;	
   ;		strcpy(str, STR);
	;
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _strcpy
	add	sp,8
	;
	;		delete( STR );
	;
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr @$bdele$qnv
	add	sp,4
	;
	;	}
	;
	pop	si
	leave
	ret
@Fun_Apage$qnuci	endp
	;
	;	void Escreva (char *str, int Pos, int Ch)
	;
	assume	cs:LIXO_TEXT
@Escreva$qnucii	proc	far
	enter	4,0
	push	si
	mov	si,word ptr [bp+10]
	;
	;	{
	;		char *STR;
	;
	;		int  num;
	;
	;		if ( ( STR = new char ) == NULL ){
	;
	push	1
	call	far ptr @$bnew$qui
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
	or	ax,dx
	jne	short @6@86
	;
	;			cputs("Erro na alocacao de memoria");
	;
	push	ds
	push	offset DGROUP:s@+34
	call	far ptr _cputs
	add	sp,4
	;
	;			exit(0);
	;
	push	0
	call	far ptr _exit
	pop	cx
@6@86:
	;
	;		}
	;
	;		if( insercao == ON )
	;
	cmp	word ptr DGROUP:_insercao,1
	jne	short @6@142
	;
	;			str[ Pos ] = Ch;
	;
	les	bx,dword ptr [bp+6]
	add	bx,si
	mov	al,byte ptr [bp+12]
	mov	byte ptr es:[bx],al
	jmp	short @6@170
@6@142:
	;
	;
	;		else{
	;			strncpy( STR, str, Pos );
	;
	push	si
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strncpy
	add	sp,10
	;
	;			STR [ Pos ] = Ch;
	;
	les	bx,dword ptr [bp-4]
	add	bx,si
	mov	al,byte ptr [bp+12]
	mov	byte ptr es:[bx],al
	;
	;			STR [ Pos + 1 ] = FALSE ;
	;
	mov	bx,word ptr [bp-4]
	mov	byte ptr es:[bx+si+1],0
	;
	;
	;			strcat(STR,&str[Pos]);
	;
	mov	ax,word ptr [bp+6]
	add	ax,si
	push	word ptr [bp+8]
	push	ax
	push	word ptr [bp-2]
	push	bx
	call	far ptr _strcat
	add	sp,8
	;
	;
	;			STR[ strlen(str) + 1 ] = FALSE ;
	;
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _strlen
	add	sp,4
	inc	ax
	les	bx,dword ptr [bp-4]
	add	bx,ax
	mov	byte ptr es:[bx],0
	;
	;			strcpy(str, STR);
	;
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	push	word ptr [bp+8]
	push	word ptr [bp+6]
	call	far ptr _strcpy
	add	sp,8
@6@170:
	;
	;		}
	;		delete ( STR );
	;
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr @$bdele$qnv
	add	sp,4
   ;	
	;	}
   ;	
	pop	si
	leave	
	ret	
@Escreva$qnucii	endp
   ;	
   ;	void PrintStr  ( int iCol, int iLin, int fCol, int PosTela, char *str )
   ;	
	assume	cs:LIXO_TEXT
@PrintStr$qiiiinuc	proc	far
	enter	4,0
	push	si
	push	di
	mov	si,word ptr [bp+6]
	mov	di,word ptr [bp+10]
	;
	;	{
   ;		char *AuxStr;
   ;	
	;		if ( ( AuxStr = new char ) == NULL ){
   ;	
	push	1
	call	far ptr @$bnew$qui
	pop	cx
	mov	word ptr [bp-2],dx
	mov	word ptr [bp-4],ax
	or	ax,dx
	jne	short @7@86
   ;	
   ;			cputs("Erro na alocacao de memoria");
   ;	
	push	ds
	push	offset DGROUP:s@+62
	call	far ptr _cputs
	add	sp,4
   ;	
	;			exit(0);
   ;	
	push	0
	call	far ptr _exit
	pop	cx
@7@86:
   ;	
   ;		}
   ;	
   ;		Limpa ( iCol, iLin, fCol, iLin );
   ;	
	push	word ptr [bp+8]
	push	di
	push	word ptr [bp+8]
	push	si
	push	cs
	call	near ptr @Limpa$qiiii
	add	sp,8
   ;	
   ;		if ( strlen( str ) <= ( fCol - iCol )){
	;
	push	word ptr [bp+16]
	push	word ptr [bp+14]
	call	far ptr _strlen
	add	sp,4
	mov	dx,di
	sub	dx,si
	cmp	ax,dx
	ja	short @7@142
   ;	
   ;			strncpy( AuxStr, str, strlen( str ));
   ;	
	push	word ptr [bp+16]
	push	word ptr [bp+14]
	call	far ptr _strlen
	add	sp,4
	push	ax
	push	word ptr [bp+16]
	push	word ptr [bp+14]
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strncpy
	add	sp,10
	;
   ;			AuxStr[ strlen(str) ] = FALSE;
   ;	
	push	word ptr [bp+16]
	push	word ptr [bp+14]
	call	far ptr _strlen
	add	sp,4
	les	dx,dword ptr [bp-4]
	add	dx,ax
	mov	bx,dx
	mov	byte ptr es:[bx],0
   ;	
   ;		}
   ;	
	jmp	short @7@170
@7@142:
   ;	
	;		else{
   ;			strncpy(AuxStr,&str[PosTela],fCol - iCol);
   ;	
	mov	ax,di
	sub	ax,si
	push	ax
	mov	ax,word ptr [bp+14]
	add	ax,word ptr [bp+12]
	push	word ptr [bp+16]
	push	ax
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _strncpy
	add	sp,10
   ;	
   ;			AuxStr[ fCol - iCol ] = FALSE;
   ;	
	mov	ax,di
	sub	ax,si
	les	bx,dword ptr [bp-4]
	add	bx,ax
	mov	byte ptr es:[bx],0
@7@170:
	;
   ;		}
   ;	
   ;		gotoxy( iCol, iLin);
   ;	
	push	word ptr [bp+8]
	push	si
	call	far ptr _gotoxy
	add	sp,4
   ;	
   ;		puts( AuxStr );
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr _puts
	add	sp,4
   ;	
	;		if (  strlen( str ) > ( fCol - iCol )){
   ;	
	push	word ptr [bp+16]
	push	word ptr [bp+14]
	call	far ptr _strlen
	add	sp,4
	mov	dx,di
	sub	dx,si
	cmp	ax,dx
	jbe	short @7@226
   ;	
   ;			gotoxy( fCol + 1, iLin );
   ;	
	push	word ptr [bp+8]
	mov	ax,di
	inc	ax
	push	ax
	call	far ptr _gotoxy
	add	sp,4
   ;	
	;			cprintf("%c",16);
   ;	
	push	16
	push	ds
	push	offset DGROUP:s@+90
	call	far ptr _cprintf
	add	sp,6
@7@226:
   ;	
   ;		}
   ;		delete ( AuxStr );
   ;	
	push	word ptr [bp-2]
	push	word ptr [bp-4]
	call	far ptr @$bdele$qnv
	add	sp,4
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	leave	
	ret	
@PrintStr$qiiiinuc	endp
LIXO_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'%c'
	db	0
	db	'%c'
	db	0
	db	'Erro na alocacao de memoria'
	db	0
	db	'Erro na alocacao de memoria'
	db	0
	db	'Erro na alocacao de memoria'
	db	0
	db	'%c'
	db	0
_DATA	ends
LIXO_TEXT	segment byte public 'CODE'
LIXO_TEXT	ends
	public	@Limpa$qiiii
	public	@PrintStr$qiiiinuc
	public	@Escreva$qnucii
	public	@Fun_Apage$qnuci
	public	@GetStr$qiiinuct4i
	public	@Cursor$qi
	public	@Inkey$qv
	public	_MenuAtivo
	public	_EstadoCursor
	public	_HelpAtivo
	public	_LinhasHelp
	public	_getAtivo
	public	_fundo
	public	_letra
	public	_insercao
	public	_LastKey
_pokeb	equ	pokeb
_poke	equ	poke
_peekb	equ	peekb
_peek	equ	peek
	extrn	_exit:far
_atoi	equ	atoi
_abs	equ	abs
	extrn	_strncpy:far
	extrn	_strlen:far
	extrn	_strcpy:far
	extrn	_strchr:far
	extrn	_strcat:far
	extrn	_cputs:far
	extrn	_cprintf:far
	extrn	__setcursortype:far
	extrn	_window:far
	extrn	_getch:far
	extrn	_gotoxy:far
	extrn	_clrscr:far
	extrn	__fputc:far
	extrn	_puts:far
	extrn	__streams:word
	extrn	@$bdele$qnv:far
	extrn	@$bnew$qui:far
_s@	equ	s@
	end
