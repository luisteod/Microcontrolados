// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "gpio.h"
#include "adc.h"
#include "motor_dc.h"
#include "lcd.h"
#include "teclado.h"
#include "system_global_definitions.h"

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);

int modo_entrada = TECLADO;
int sentido = DIREITA;
int estado_motor = INATIVO;
int velocidade = 0; //de 0 a 100
char velocidade_str[17];
int estado_usuario = USUARIO_INICIO;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	adc_init();
	inicia_motor();
	LCD_Init();

	
reinicia_sistema:
	estado_usuario = USUARIO_INICIO;
	LCD_writeStringUpper("Motor Parado!");
	LCD_writeStringLower("* para iniciar");
	// TODO : Captura o se teclado ou potenciometro

	while (estado_usuario < USUARIO_FEEDBACK_POT)
	{	
		switch (estado_usuario)
		{
			case USUARIO_INICIO:
				if(keyboard_read() == '*')
				{
					LCD_writeStringUpper("1. Potenciometro");
					LCD_writeStringLower("2. Teclado");
					estado_usuario = USUARIO_ESCOLHA_MODO;
				}
				break;
			case USUARIO_ESCOLHA_MODO:
				if(keyboard_read() == '1')
				{
					modo_entrada = POTENCIOMETRO;
					estado_usuario = USUARIO_FEEDBACK_POT;
					break;
				}
				else if(keyboard_read() == '2')
				{
					modo_entrada = TECLADO;
					LCD_writeStringUpper("Sentido desejado:");
					LCD_writeStringLower("1 H, 2 AH");
					SysTick_Wait1ms(100);
					estado_usuario = USUARIO_SENTIDO;
				}
				break;
			case USUARIO_SENTIDO:
				if(keyboard_read() == '1')
				{
					sentido = DIREITA;
					estado_usuario = USUARIO_FEEDBACK_TECLADO;
					break;
				}
				else if(keyboard_read() == '2')
				{
					sentido = ESQUERDA;
					estado_usuario = USUARIO_FEEDBACK_TECLADO;
					break;
				}
				break;
				default:
					break;

		}
		
	}
	ativa_motor();

	while ((estado_usuario == USUARIO_FEEDBACK_POT || estado_usuario == USUARIO_FEEDBACK_TECLADO) && estado_usuario != USUARIO_FIM)
	{
		switch (estado_usuario)
		{
			case USUARIO_FEEDBACK_POT:
				if (keyboard_read() == '*')
						estado_usuario = USUARIO_FIM;
				velocidade = get_porcentagem();
				if (sentido == DIREITA)
					LCD_writeStringUpper("Horario");
				else if (sentido == ESQUERDA)
					LCD_writeStringUpper("Anti-horario");
				else
					LCD_writeStringUpper("Parado");

				velocidade_str[0] = 'V';
				velocidade_str[1] = 'e';
				velocidade_str[2] = 'l';
				velocidade_str[3] = 'o';
				velocidade_str[4] = 'c';
				velocidade_str[5] = 'i';
				velocidade_str[6] = 'd';
				velocidade_str[7] = 'a';
				velocidade_str[8] = 'd';
				velocidade_str[9] = 'e';
				velocidade_str[10] = ':';
				velocidade_str[11] = ' ';
				velocidade_str[12] = (velocidade / 100) + 0x30;
				velocidade_str[13] = ((velocidade % 100) / 10) + 0x30;
				velocidade_str[14] = (velocidade % 10) + 0x30;
				velocidade_str[15] = '\0';
				
				LCD_writeStringLower(velocidade_str);
				SysTick_Wait1ms(100);
				
				break;
			case USUARIO_FEEDBACK_TECLADO:
					if (sentido == DIREITA)
						LCD_writeStringUpper("Sentido = H");
					else
						LCD_writeStringUpper("Sentido = AH");
					
					velocidade = get_porcentagem();
					velocidade_str[0] = 'V';
					velocidade_str[1] = 'e';
					velocidade_str[2] = 'l';
					velocidade_str[3] = 'o';
					velocidade_str[4] = 'c';
					velocidade_str[5] = 'i';
					velocidade_str[6] = 'd';
					velocidade_str[7] = 'a';
					velocidade_str[8] = 'd';
					velocidade_str[9] = 'e';
					velocidade_str[10] = ':';
					velocidade_str[11] = ' ';
					velocidade_str[12] = (velocidade / 100) + 0x30;
					velocidade_str[13] = ((velocidade % 100) / 10) + 0x30;
					velocidade_str[14] = (velocidade % 10) + 0x30;
					velocidade_str[15] = '\0';
					
					LCD_writeStringLower("Velocidade:");
					LCD_writeStringLower(velocidade_str);
					
					if (keyboard_read() == '9')
						troca_sentido();						
					else if (keyboard_read() == '*')
						estado_usuario = USUARIO_FIM;
					
			default:
					LCD_writeStringUpper("VINICIUS KAMIYA");
					LCD_writeStringLower("LUIS HENRIQUE");
				break;
		}		
	}
	para_motor();
	goto reinicia_sistema;
		
}
