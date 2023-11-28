#include <stdint.h>
#include "tm4c1294ncpdt.h"

// port H
#define GPIO_PORTH (0x1 << 7)  // bit 7
#define GPIO_PORTN (0x1 << 12) // bit 12
#define GPIO_PORTF (0x1 << 5)  // bit 5
#define GPIO_PORTE (0x1 << 4)  // bit 4
#define GPIO_PORTJ (0x1 << 8)
#define GPIO_PORTA (0x1) // bit 0
#define GPIO_PORTQ (0x1 << 14)
#define GPIO_PORTP (0X1 << 13)
#define GPIO_PORTL (0X1 << 10)
#define GPIO_PORTM (0X1 << 11)
#define GPIO_PORTK (0X1 << 9)

void GPIOPortJ_Handler(void);
extern int is_rotate_canc;
extern int angulo_it;
extern int is_motor_active;

// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIO_Init(void)
{
	// 1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTE | GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP | GPIO_PORTL | GPIO_PORTM | GPIO_PORTK);
	// 1b.   ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
	while ((SYSCTL_PRGPIO_R & (GPIO_PORTE | GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP | GPIO_PORTL | GPIO_PORTM | GPIO_PORTK)) !=
		   (GPIO_PORTE | GPIO_PORTF | GPIO_PORTH | GPIO_PORTN | GPIO_PORTA | GPIO_PORTJ | GPIO_PORTQ | GPIO_PORTP | GPIO_PORTL | GPIO_PORTM | GPIO_PORTK))
	{
	};


	//teclado e LCD
	// 2. Limpar o AMSEL para desabilitar a analógica
    GPIO_PORTL_AMSEL_R = 0x00;
    GPIO_PORTM_AMSEL_R = 0x00;
	GPIO_PORTK_AMSEL_R = 0x00;

    // 3. Limpar PCTL para selecionar o GPIO
    GPIO_PORTL_PCTL_R = 0x00;
    GPIO_PORTM_PCTL_R = 0x00;
    GPIO_PORTK_PCTL_R = 0x00;

    // 4. DIR para 0 se for entrada, 1 se for saída
    GPIO_PORTL_DIR_R = 0x00; // Bit0-3
    GPIO_PORTM_DIR_R = 0x07; // Bit0-2
    GPIO_PORTK_DIR_R = 0xFF; // Bit0-7


    // 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem função alternativa
    GPIO_PORTL_AFSEL_R = 0x00;
    GPIO_PORTM_AFSEL_R = 0x00;
		GPIO_PORTK_AFSEL_R = 0x00;
	
    // 6. Setar os bits de DEN para habilitar I/O digital
    GPIO_PORTL_DEN_R = 0x0F; // Bit0-3
    GPIO_PORTM_DEN_R = 0xFF; // Bit0-2
		GPIO_PORTK_DEN_R = 0xFF; // Bit0-7

    // 7. Setar os bits PUR para habilitar o pull-up
    GPIO_PORTL_PUR_R = 0x0F; // Bit0-3


	//RESTO
	// 2. Limpar o AMSEL para desabilitar a anal�gica
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTQ_AMSEL_R = 0x00;
	GPIO_PORTP_AMSEL_R = 0X00;
	GPIO_PORTH_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
	GPIO_PORTE_AHB_AMSEL_R = 0x00;
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;

	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTQ_PCTL_R = 0X00;
	GPIO_PORTP_PCTL_R = 0X00;
	GPIO_PORTH_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;
	GPIO_PORTE_AHB_PCTL_R = 0x00;
	GPIO_PORTJ_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for saida
	GPIO_PORTA_AHB_DIR_R = 0x02 | 0XF0; // BIT1
	GPIO_PORTQ_DIR_R = 0XF;
	GPIO_PORTP_DIR_R = 0X1 << 5;
	GPIO_PORTH_AHB_DIR_R = 0xF;	 // BIT0 | BIT1 -> INPUT
	GPIO_PORTN_DIR_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x1 << 2; // BIT2
	GPIO_PORTJ_AHB_DIR_R = 0x0;
	GPIO_PORTE_AHB_DIR_R = 0x3; // BIT0 | BIT1 

	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem funcaoo alternativa
	GPIO_PORTA_AHB_AFSEL_R = 0x03; // Habilita funcao altgernativa (UART)
	GPIO_PORTQ_AFSEL_R = 0x00;
	GPIO_PORTP_AFSEL_R = 0X00;
	GPIO_PORTH_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00;
	GPIO_PORTF_AHB_AFSEL_R = 0x00;
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTE_AHB_AFSEL_R = 0x00;

	// 6. Setar os bits de DEN para habilitar I/O digital
	GPIO_PORTA_AHB_DEN_R = 0x03 | 0xF0; // BIT0 | BIT1
	GPIO_PORTQ_DEN_R = 0XF;
	GPIO_PORTP_DEN_R = 0X1 << 5;
	GPIO_PORTH_AHB_DEN_R = 0xf;	 // BIT0 | BIT1
	GPIO_PORTN_DEN_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DEN_R = 0x1 << 2; // BIT2
	GPIO_PORTJ_AHB_DEN_R = 0x1;
	GPIO_PORTE_AHB_DEN_R = 0x3; // BIT0 | BIT1

	// GPIO_PORTJ_AHB_PUR_R = 0x1;

	// // interrupt routine
	// GPIO_PORTJ_AHB_IM_R = 0x0;
	// GPIO_PORTJ_AHB_IS_R = 0x0;
	// GPIO_PORTJ_AHB_IBE_R = 0x0;
	// GPIO_PORTJ_AHB_IEV_R = 0x0;
	// GPIO_PORTJ_AHB_ICR_R = 0x1;
	// GPIO_PORTJ_AHB_IM_R = 0x1;
	// NVIC_EN1_R = 0x1 << 19;
	// NVIC_PRI12_R = 5 << 29;
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

uint8_t PortL_Input(void){
    return GPIO_PORTL_DATA_R; // Bits 0-3
}

void PortM_Output_teclado(uint32_t valor){
    uint32_t temp;
		
    //vamos zerar somente os bits menos significativos
    //para uma escrita amig�vel nos bits 0-2
    temp = GPIO_PORTM_DIR_R & 0x07;
    //agora vamos fazer o OR com o valor recebido na fun��o
    temp = temp | valor;
    GPIO_PORTM_DIR_R = temp; 
		GPIO_PORTM_DATA_R = 0x00;
		
}

//void GPIOPortJ_Handler(void)
//{
//	is_rotate_canc = 1;
//	GPIO_PORTJ_AHB_ICR_R = 1;
//}


