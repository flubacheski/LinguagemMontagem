#include <stdio.h>
#include <conio.h>

void main ( void )
{
	int num1, num2;

	clrscr();

	printf("digite o primeiro numero ");
	scanf("%d",&num1);

	printf("digite o segundo numero ");
	scanf("%d",&num2);

	num1 = num1/num2;
	num1 = num1*num2;
	getch();
}
