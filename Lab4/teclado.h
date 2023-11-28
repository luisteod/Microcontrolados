#ifndef TECLADO_H
#define TECLADO_H

#include <stdint.h>
#include "tm4c1294ncpdt.h"

void SysTick_Wait1ms(uint32_t delay);


// Retorna o valor da tecla pressionada
char keyboard_read(void);

uint8_t PortL_Input(void);
void PortM_Output_teclado(uint32_t valor);
void PortM_Dir(uint32_t valor);

#endif