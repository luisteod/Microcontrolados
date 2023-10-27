// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>

typedef enum
{
	VERMELHO,
	VERDE,
	AMARELO
} semaforo;

typedef enum
{
	VERMELHO_TIME = 28,
	VERDE_TIME = 20,
	AMARELO_TIME = 4
} semaforo_time;

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void GPIO_Init(void);
uint32_t PortJ_Input(void);
void PortN_Output(uint32_t leds);
void PortF_Output(uint32_t leds);
void Pisca_leds(void);

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	semaforo sem1 = VERMELHO;
	semaforo sem2 = VERDE;
	uint16_t sem1_time = 0;
	uint16_t sem2_time = 0;

	while (1)
	{

		// // Se a USR_SW2 estiver pressionada
		// if (PortJ_Input() == 0x1)
		// 	PortN_Output(0x1);
		// // Se a USR_SW1 estiver pressionada
		// else if (PortJ_Input() == 0x2)
		// 	PortN_Output(0x2);
		// // Se ambas estiverem pressionadas
		// else if (PortJ_Input() == 0x0)
		// 	Pisca_leds();
		// // Se nenhuma estiver pressionada
		// else if (PortJ_Input() == 0x3)
		// 	PortN_Output(0x0);

		// switch (sem1)
		// {
		// case VERMELHO:
		// 	PortN_Output(0x3);
		// 	break;
		// case VERDE:
		// 	PortN_Output(0x1);
		// 	break;
		// case AMARELO:
		// 	PortN_Output(0x2);
		// 	break;
		// }

		// switch (sem2)
		// {
		// case VERMELHO:
		// 	PortF_Output(0x3);
		// 	break;
		// case VERDE:
		// 	PortF_Output(0x1);
		// 	break;
		// case AMARELO:
		// 	PortF_Output(0x2);
		// 	break;
		// }

		SysTick_Wait1ms(1000);

		sem1_time++;
		sem2_time++;

		// semaforo 1
		if (sem1_time == VERMELHO_TIME && sem1 == VERMELHO)
		{
			sem1_time = 0;
			sem1 = VERDE;
			PortN_Output(0x1);
		}
		else if (sem1_time == VERDE_TIME && sem1 == VERDE)
		{
			sem1_time = 0;
			sem1 = AMARELO;
			PortN_Output(0x2);
		}
		else if (sem1_time == AMARELO_TIME && sem1 == AMARELO)
		{
			sem1_time = 0;
			sem1 = VERMELHO;
			PortN_Output(0x3);
		}

		// semaforo 2
		if (sem2_time == VERMELHO_TIME && sem2 == VERMELHO)
		{
			sem2_time = 0;
			sem2 = VERDE;
			PortF_Output(0x1);
		}
		else if (sem2_time == VERDE_TIME && sem2 == VERDE)
		{
			sem2_time = 0;
			sem2 = AMARELO;
			PortF_Output(0x2);
		}
		else if (sem2_time == AMARELO_TIME && sem2 == AMARELO)
		{
			sem2_time = 0;
			sem2 = VERMELHO;
			PortF_Output(0x3);
		}
	}
}

// void Pisca_leds(void)
// {
// 	PortN_Output(0x2);
// 	SysTick_Wait1ms(250);
// 	PortN_Output(0x1);
// 	SysTick_Wait1ms(250);
// }
