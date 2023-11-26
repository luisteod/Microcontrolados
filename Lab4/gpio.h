#ifndef GPIO_H
#define GPIO_H
#include <stdint.h>

void led_timer_init(void);
void GPIO_Init(void);
void PortHOutput(uint32_t valor);
void led_dir_output(char direcao);

#endif