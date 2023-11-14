// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron

#include <stdint.h>

#include "gpio.h"
#include "tm4c1294ncpdt.h"

// port H
#define GPIO_PORTH (0x1 << 7)  // bit 7
#define GPIO_PORTN (0x1 << 12) // bit 12
#define GPIO_PORTF (0x1 << 5)  // bit 5
#define GPIO_PORTJ (0x1 << 8)
#define GPIO_PORTA (0x1) // bit 0
#define GPIO_PORTQ (0x1 << 14)
#define GPIO_PORTP (0X1 << 13)

void GPIOPortJ_Handler(void);
extern int is_rotate_canc;
extern int angulo_it;

// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIO_Init(void)
{
	// 1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP);
	// 1b.   ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
	while ((SYSCTL_PRGPIO_R & (GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP)) !=
		   (GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP))
	{
	};

	// 2. Limpar o AMSEL para desabilitar a anal�gica
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTQ_AMSEL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0X00;
	GPIO_PORTH_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;

	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTQ_PCTL_R = 0X00;
	GPIO_PORTP_PCTL_R = 0X00;
	GPIO_PORTH_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;
	GPIO_PORTJ_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for sa�da
	GPIO_PORTA_AHB_DIR_R = 0x02 | 0XF0; // BIT1
	GPIO_PORTQ_DIR_R = 0XF;
	GPIO_PORTP_DIR_R = 0X1 << 5;
	GPIO_PORTH_AHB_DIR_R = 0xF;	 // BIT0 | BIT1 -> INPUT
	GPIO_PORTN_DIR_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11; // BIT0 | BIT4
	GPIO_PORTJ_AHB_DIR_R = 0x0;

	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem funcaoo alternativa
	GPIO_PORTA_AHB_AFSEL_R = 0x03; // Habilita funcao altgernativa (UART)
	GPIO_PORTQ_AFSEL_R = 0x00;
	GPIO_PORTP_AFSEL_R = 0X00;
	GPIO_PORTH_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00;
	GPIO_PORTF_AHB_AFSEL_R = 0x00;
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;

	// 6. Setar os bits de DEN para habilitar I/O digital
	GPIO_PORTA_AHB_DEN_R = 0x03 | 0xF0; // BIT0 | BIT1
	GPIO_PORTQ_DEN_R = 0XF;
	GPIO_PORTP_DEN_R = 0X1 << 5;
	GPIO_PORTH_AHB_DEN_R = 0xf;	 // BIT0 | BIT1
	GPIO_PORTN_DEN_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DEN_R = 0x11; // BIT0 | BIT1
	GPIO_PORTJ_AHB_DEN_R = 0x1;

	GPIO_PORTJ_AHB_PUR_R = 0x1;

	// interrupt routine
	GPIO_PORTJ_AHB_IM_R = 0x0;
	GPIO_PORTJ_AHB_IS_R = 0x0;
	GPIO_PORTJ_AHB_IBE_R = 0x0;
	GPIO_PORTJ_AHB_IEV_R = 0x0;
	GPIO_PORTJ_AHB_ICR_R = 0x1;
	GPIO_PORTJ_AHB_IM_R = 0x1;
	NVIC_EN1_R = 0x1 << 19;
	NVIC_PRI12_R = 5 << 29;
}

// -------------------------------------------------------------------------------
// Fun��o PortN_Output
// Escreve os valores no port N
// Par�metro de entrada: Valor a ser escrito
// Par�metro de sa�da: n�o tem
void PortH_Output(uint32_t graus)
{
	uint32_t temp;
	// vamos zerar somente os bits menos significativos
	// para uma escrita amig�vel nos bits 0 e 1
	temp = GPIO_PORTH_AHB_DATA_R & 0x00;
	// agora vamos fazer o OR com o valor recebido na fun��o
	temp = temp | graus;
	GPIO_PORTH_AHB_DATA_R = temp;
}

void GPIOPortJ_Handler(void)
{
	is_rotate_canc = 1;
	GPIO_PORTJ_AHB_ICR_R = 1;
}

void led_dir_output(char direcao)
{
	if (angulo_it % 45 == 0)
	{
		int which_led = angulo_it / 45;

		if (direcao == '0')
		{

			if (which_led == 1)
			{
				GPIO_PORTQ_DATA_R = 0x1;
			}
			if (which_led == 2)
			{
				GPIO_PORTQ_DATA_R = 0X3;
			}
			if (which_led == 3)
			{
				GPIO_PORTQ_DATA_R = 0X7;
			}
			if (which_led == 4)
			{
				GPIO_PORTQ_DATA_R = 0XF;
			}
			if (which_led == 5)
			{
				GPIO_PORTA_AHB_DATA_R = 0x10 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 6)
			{
				GPIO_PORTA_AHB_DATA_R = 0x30 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 7)
			{
				GPIO_PORTA_AHB_DATA_R = 0x70 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 8)
			{
				GPIO_PORTA_AHB_DATA_R = 0xF0 | GPIO_PORTA_AHB_DATA_R;
			}
		}
		else if (direcao == '1')
		{
			if (which_led == 1)
			{
				GPIO_PORTA_AHB_DATA_R = 0x80 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 2)
			{
				GPIO_PORTA_AHB_DATA_R = 0xC0 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 3)
			{
				GPIO_PORTA_AHB_DATA_R = 0xE0 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 4)
			{
				GPIO_PORTA_AHB_DATA_R = 0xF0 | GPIO_PORTA_AHB_DATA_R;
			}
			if (which_led == 5)
			{
				GPIO_PORTQ_DATA_R = 0x8;
			}
			if (which_led == 6)
			{
				GPIO_PORTQ_DATA_R = 0XC;
			}
			if (which_led == 7)
			{
				GPIO_PORTQ_DATA_R = 0XE;
			}
			if (which_led == 8)
			{
				GPIO_PORTQ_DATA_R = 0XF;
			}

		}
		// ACTIVATES TRANSISTOR
			GPIO_PORTP_DATA_R = 0X1 << 5;
	}
}
