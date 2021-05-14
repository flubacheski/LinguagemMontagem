#include <stdio.h>
#include <conio.h>

extern int DIVISAO(int a, int b);

void main ( void )
{
	int num1, num2;

	clrscr();

	printf("digite o primeiro numero ");
	scanf("%d",&num1);

	printf("digite o segundo numero ");
	scanf("%d",&num2);

	DIVISAO(num1,num2);

	getch();
}
