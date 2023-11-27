// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "gpio.h"
#include "adc.h"
#include "motor_dc.h"
#include "system_global_definitions.h"

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);

int modo_entrada = POTENCIOMETRO;
int sentido = DIREITA;
int estado_motor = INATIVO;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	adc_init();
	inicia_motor();

	// TODO : Captura o se teclado ou potenciometro

reset_sentido_motor:

	// TODO : Captura o sentido de rotacao SE TECLADO

	para_motor();
	ativa_motor();

	while (1)
	{
		/*CODIGO ABAIXO APENAS TESTE*/
		SysTick_Wait1ms(5000);
		para_motor();
    

		// TODO : Metodo que executa a linha abaixo caso queira alterar o metodo : Teclado ou potenciometro
		goto reset_sentido_motor;
	}
}
