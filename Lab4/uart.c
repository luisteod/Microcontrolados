#include <stdint.h>
#include <math.h>
#include "uart.h"
#include "tm4c1294ncpdt.h"

#define UARTSysClk 80000000
#define BAUD_RATE 57600
void SysTick_Wait1ms(uint32_t delay);

void UARTInit () {

    // 1. Enable UART0 and verify if the correct bit is set on PRUART
   SYSCTL_RCGCUART_R = SYSCTL_RCGCUART_R0; 

   while ((SYSCTL_PRUART_R & SYSCTL_PRUART_R0) != SYSCTL_PRUART_R0) { }

    // 2. Disable temporarily UART0 on its last bit 
    UART0_CTL_R = UART0_CTL_R & (~UART_CTL_UARTEN);

    // 3. Write the baud rate defined as 
    int clkDiv = ((UART0_CTL_R & 0x20) == 0) ? 16 : 8;
    float baudRate = UARTSysClk / (clkDiv * BAUD_RATE);
   
	baudRate = 86.8111;

//    UART0_IBRD_R = (int) baudRate;
//    UART0_FBRD_R = (int) round((baudRate - (int) baudRate) * 64);
	UART0_IBRD_R = (int) 86;	// baudRate = 80M / (16*57600) = 86.8111
    UART0_FBRD_R = (int) 52;	// baudRate = round(0.8111 * 64) = round(51.56) = 52
   

    // 4. Set number of bits, parity, stop bits and queue
    // SPS = 0, WLEN = 11, FEN = 1, STP2 = 1, EPS = 1, PEN = 1, BRK = 0
    UART0_LCRH_R = 0x7E; // 0b 0111 1110

    // 5. Set clk as SysCLK (System clk)
    UART0_CC_R = 0; 

    // 6. Enable Tx, Rx, HSE=0 (clkDiv = 16) and UARTEN
    UART0_CTL_R = (UART_CTL_UARTEN | UART_CTL_TXE | UART_CTL_RXE);
}


unsigned char UARTReceive (void) {

	unsigned char msg = 0;
	unsigned long queueEmpty = (UART0_FR_R & UART_FR_RXFE) >> 4;

	if (!queueEmpty) {
		msg = UART0_DR_R;
	}

	return msg;
}


void UARTTransmit (unsigned char msgChar) {

	unsigned long queueFull = (UART0_FR_R & UART_FR_TXFF) >> 5;

	if ((!queueFull) && (msgChar != 0)) {
		UART0_DR_R = msgChar;
	}
	SysTick_Wait1ms(10);
}

void UARTSendString (unsigned char* string) {
	unsigned char c = string[0];
	int i = 1;
  while (c != '\0') {
        UARTTransmit(c);
		c = string[i++];
    }
}


