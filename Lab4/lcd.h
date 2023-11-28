#ifndef LCD_H
#define LCD_H

#include <stdint.h>
#include "tm4c1294ncpdt.h"

void SysTick_Wait1us(uint32_t delay);

// Inicializa o display
void LCD_Init(void);

// Envia comando para o display
void LCD_sendCommand(uint8_t command, uint32_t delay);

// Envia dado para o display
void LCD_sendData(uint8_t data);

// Escreve uma string na primeira linha do display
void LCD_writeStringUpper(char *string);

// Escreve uma string na segunda linha do display
void LCD_writeStringLower(char *string);

void PortK_Output(uint32_t valor);
void PortM_Output_lcd(uint32_t valor);

#endif