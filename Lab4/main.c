#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "gpio.h"
#include "uart.h"
#include "motor.h"

void PLL_Init(void);
void GPIO_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);



int main()
{
    PLL_Init();
    SysTick_Init();
    GPIO_Init();

    return 0;
}
