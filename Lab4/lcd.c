#include "lcd.h"

#define GPIO_PORTM 0x800
#define GPIO_PORTK 0x200

void LCD_Init(void){
    LCD_sendCommand(0x38, 40); // Modo 2 linhas
    LCD_sendCommand(0x06, 40); // Incrementa cursor
    LCD_sendCommand(0x0E, 40); // Configura o cursor
    LCD_sendCommand(0x01, 1640); // Limpa o display
}

void LCD_sendCommand(uint8_t command, uint32_t delay){
    PortK_Output(command);
    PortM_Output_lcd(0x4);     // RS = 0, RW = 0, EN = 1
    SysTick_Wait1us(10);    // delay de 10us
    PortM_Output_lcd(0x0);     // RS = 0, RW = 0, EN = 0
    SysTick_Wait1us(delay);
}

void LCD_sendData(uint8_t data){
    PortK_Output(data);
    PortM_Output_lcd(0x5);     // RS = 1, RW = 0, EN = 1
    SysTick_Wait1us(10);    // delay de 10us
    PortM_Output_lcd(0x0);     // RS = 0, RW = 0, EN = 0
    SysTick_Wait1us(40);    // delay de 40us
}

void LCD_writeStringUpper(char *string){
    // Limpar o display e levar o cursor para o home
    LCD_sendCommand(0x01, 1640);
    // Percorre a string at� o fim
    while (*string) {
        LCD_sendData(*string++);
    }
}

void LCD_writeStringLower(char *string){
    // Levar o cursor para a segunda linha
    LCD_sendCommand(0xC0, 40);
    // Percore a string at� o fim
    while (*string) {
        LCD_sendData(*string++);
    }
}

void PortK_Output(uint32_t valor){
    uint32_t temp;
	//vamos zerar somente os bits menos significativos
	//para uma escrita amig?vel nos bits 0-7
	temp = GPIO_PORTK_DATA_R & 0x00;
	//agora vamos fazer o OR com o valor recebido na fun??o
	temp = temp | valor;
	GPIO_PORTK_DATA_R = temp; 
}

 void PortM_Output_lcd(uint32_t valor){
     uint32_t temp;
     //vamos zerar somente os bits menos significativos
     //para uma escrita amig?vel nos bits 0-2
     temp = GPIO_PORTM_DATA_R & 0xF8;
     //agora vamos fazer o OR com o valor recebido na fun??o
     temp = temp | valor;
     GPIO_PORTM_DATA_R = temp; 
 }