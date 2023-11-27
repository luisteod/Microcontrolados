#include <stdint.h>
#include "tm4c1294ncpdt.h"
#include "motor_dc.h"
#include "adc.h"
#include "system_global_definitions.h"

#define HIGH 1
#define LOW 0

// Em que x e o valor em ms
#define TIMER_VALUE(x) ( x > 0 ? (x * 80000 - 1) : 0)

#define TIMER_2 (0x1 << 2)
#define TIMER_2_MS 200 //<----- Edite para configurar o timer 2A em ms

#define TIMER_1 (0x1 << 1)

int volatile estado_pwm = 0;
float volatile porcentagem = 0;

extern int estado_motor;
extern int modo_entrada;
extern int sentido;

void pwm(void);
void ativa_motor_teclado(void);
void ativa_motor_potenciometro(void);
void Timer2A_Handler(void);
void Timer2A_Init(void);
void Timer1A_Handler(void);
void Timer1A_Init(void);
void dispara_timer_1A(int valor);

void inicia_motor(void)
{
	/*Configura o timer que ira altera a velocidade de giro
	conforme o potenciometro*/
	Timer2A_Init();
	// Configura o timer que ira gerar o pwm
	Timer1A_Init();

	GPIO_PORTF_AHB_DATA_R = 0x1 << 2; // Habilita o pino F2 (enable)
}
void ativa_motor(void)
{
	estado_motor = ATIVO;

	if (modo_entrada == TECLADO)
	{
		ativa_motor_teclado();
	}
	else if (modo_entrada == POTENCIOMETRO)
	{
		ativa_motor_potenciometro();
	}
}

void para_motor(void)
{
	estado_motor = INATIVO;

	// Desliga o motor
	GPIO_PORTE_AHB_DATA_R = 0x0;
}

// funcao que configurara o pwm
void ativa_motor_teclado(void)
{
	// Salva a porcentagem numa variavel global
	porcentagem = adc_read() / (float)VALOR_MAX_ADC;
	pwm();
}

// funcao que ira configurar o pwm
void ativa_motor_potenciometro(void)
{
	// TODO
}

// Cria um timer periodico de 200ms
void Timer2A_Init(void)
{
	SYSCTL_RCGCTIMER_R = SYSCTL_RCGCTIMER_R | TIMER_2; // habilita clock do timer 2

	while ((SYSCTL_PRTIMER_R & TIMER_2) != TIMER_2)
		;

	TIMER2_CTL_R = TIMER2_CTL_R & 0xFFE; // desabilita timer 2

	TIMER2_CFG_R = 0x00;

	TIMER2_TAMR_R = 0x02; // periodic mode

	TIMER2_TAILR_R = TIMER_VALUE(TIMER_2_MS); // 15.999.999

	TIMER2_TAPR_R = 0x000; // sem prescaler

	TIMER2_ICR_R = 0x1; // limpa flag de interrupcao

	TIMER2_IMR_R = 0x1; // habilita interrupcao

	NVIC_PRI5_R = NVIC_PRI5_R | 4 << 29; // prioridade 4

	NVIC_EN0_R = NVIC_EN0_R | 1 << 23; // habilita interrupcao no NVIC

	TIMER2_CTL_R = TIMER2_CTL_R | 0x1; // habilita timer 2
}

// A cada 200ms atualiza o pwm
void Timer2A_Handler(void)
{
	TIMER2_ICR_R = 0x1; // limpa flag de interrupcao

	if (estado_motor == ATIVO)
	{
		ativa_motor();
	}
}

void Timer1A_Init(void)
{
	SYSCTL_RCGCTIMER_R = SYSCTL_RCGCTIMER_R | TIMER_1; // habilita clock do timer 1

	while ((SYSCTL_PRTIMER_R & TIMER_1) != TIMER_1)
		;

	TIMER1_CTL_R = TIMER1_CTL_R & 0xFFE; // desabilita timer 1A

	TIMER1_CFG_R = 0x00; // Contagem de 32 bits

	TIMER1_TAMR_R = 0x01; // oneshot mode

	// TIMER1_TAILR_R = 0x0; // Sem valor inicialmente

	TIMER1_TAPR_R = 0x000; // sem prescaler

	TIMER1_ICR_R = 0x1; // limpa flag de interrupcao

	TIMER1_IMR_R = 0x1; // habilita interrupcao

	NVIC_PRI5_R = NVIC_EN0_R | 2 << 13; // prioridade 2

	NVIC_EN0_R = NVIC_EN0_R | 1 << 21; // habilita interrupcao no NVIC

	// TIMER1_CTL_R = TIMER1_CTL_R | 0x1; // habilita timer 1
}

void Timer1A_Handler(void)
{
	TIMER1_ICR_R = 0x1; // limpa flag de interrupcao

	// Calcula prox valor do pwm e comuta os sinal para geracao da onda
	if (estado_motor == ATIVO)
	{
		pwm();
	}
}

// Configura o pwm conforme o potenciometro
void pwm(void)
{
	int valor_timer_1A = 0;

	if (estado_pwm == HIGH)
	{
		estado_pwm = LOW;

		// Zera o sinal
		GPIO_PORTE_AHB_DATA_R = 0x0;

		valor_timer_1A = TIMER_VALUE((1 - porcentagem) * PERIODO_PWM_MS);
	}
	else if (estado_pwm == LOW)
	{
		estado_pwm = HIGH;

		// Gera um sinal conforme o complemento da porcentagem
		valor_timer_1A = TIMER_VALUE(porcentagem * PERIODO_PWM_MS);

		if (sentido == DIREITA)
		{
			// Habilita o pino E0 apenas
			GPIO_PORTE_AHB_DATA_R = 0x1;
		}
		else if (sentido == ESQUERDA)
		{
			// Habilita o pino E1 apenas
			GPIO_PORTE_AHB_DATA_R = 0x2;
		}
	}

	// Rearma timer 1A com o valor do pwm
	dispara_timer_1A(valor_timer_1A);
}

void dispara_timer_1A(int valor)
{
	TIMER1_TAILR_R = valor;

	TIMER1_CTL_R = TIMER1_CTL_R | 0x1; // habilita timer 1A
}