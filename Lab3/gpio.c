// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>

#include "gpio.h"
#include "tm4c1294ncpdt.h"

#define GPIO_PORTJ  (0x1 << 8) //bit 8
#define GPIO_PORTN  (0x1 << 12) //bit 12
#define GPIO_PORTF  (0x1 << 5) //bit 5
#define GPIO_PORTA  (0x1) //bit 0

// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIOInit(void) {
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTF | GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA);
	//1b.   ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
	while((SYSCTL_PRGPIO_R & (GPIO_PORTF | GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA)) !=
	      					 (GPIO_PORTF | GPIO_PORTJ | GPIO_PORTN | GPIO_PORTA)){ };
	
	// 2. Limpar o AMSEL para desabilitar a anal�gica
	GPIO_PORTA_AHB_AMSEL_R = 0x00;
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R 	   = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;
		
	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTA_AHB_PCTL_R = 0x11;
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R 	  = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for sa�da
	GPIO_PORTA_AHB_DIR_R = 0x02;	// BIT1
	GPIO_PORTJ_AHB_DIR_R = 0x00;	// BIT0 | BIT1 -> INPUT
	GPIO_PORTN_DIR_R 	 = 0x03; 	// BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11;	// BIT0 | BIT4
		
	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem funcaoo alternativa	
	GPIO_PORTA_AHB_AFSEL_R = 0x03;		// Habilita funcao altgernativa (UART)
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R 	   = 0x00; 
	GPIO_PORTF_AHB_AFSEL_R = 0x00;
		
	// 6. Setar os bits de DEN para habilitar I/O digital	
	GPIO_PORTA_AHB_DEN_R = 0x03;	// BIT0 | BIT1
	GPIO_PORTJ_AHB_DEN_R = 0x03;    // BIT0 | BIT1
	GPIO_PORTN_DEN_R 	 = 0x03; 	// BIT0 | BIT1
	GPIO_PORTF_AHB_DEN_R = 0x11;    // BIT0 | BIT1

	// 7. Habilitar resistor de pull-up interno, setar PUR para 1
	GPIO_PORTJ_AHB_PUR_R = 0x03;   // BIT0 | BIT1


	// 8. Interruption settings
		// 1. Disable interrupt
		GPIO_PORTJ_AHB_IM_R = 0;
		
		// 2. Border or level
		GPIO_PORTJ_AHB_IS_R = 0;
		
		// 3. Activate in 1 or 2 borders
		GPIO_PORTJ_AHB_IBE_R = 0;
		
		// 4. Activate in rising or lowering border 0 = lowering, 1 = rising
		GPIO_PORTJ_AHB_IEV_R = 0x2;
		
		// 5. Enable GPIORIS AND GPIOMIS reset
		GPIO_PORTJ_AHB_ICR_R = 0x3;
		
		// 6. Enable interrupt
		GPIO_PORTJ_AHB_IM_R = 0x3;
		
		// 7. Enable interrut in nvic
		NVIC_EN1_R = (0x1 << 19);
		
		// 8. Set port interrupt priority
		NVIC_PRI12_R = (0x5 << 29);
}	


// -------------------------------------------------------------------------------
// Fun��o PortN_Output
// Escreve os valores no port N
// Par�metro de entrada: Valor a ser escrito
// Par�metro de sa�da: n�o tem
void PortNOutput(uint32_t valor) {
	uint32_t temp;
	temp = GPIO_PORTN_DATA_R & 0xFC;
	temp = temp | valor;
	GPIO_PORTN_DATA_R = temp; 
}




