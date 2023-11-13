#include <stdint.h>

#include "gpio.h"
#include "uart.h"
#include "motor.h"

void PLL_Init(void);
void GPIO_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void SysTick_Wait1us(uint32_t delay);
void UARTInit(void);
void Motor_Init(void);

int main()
{
    PLL_Init();
	SysTick_Init();
	GPIO_Init();
    UARTInit();

    
    //Aguarda input do usuário de quantos graus o motor deve girar (0~360), o sentido de rotação e a velocidade
    while(1){
        //Considera a posição do motor como 0 graus
        reset();
        RotateFromUART();
    }

    return 0;
}
        
void RotateFromUART(){
    printf("Enter rotation parameters (direction 0/1, velocity 0/1, degrees): ");
    uint32_t direction, stepMode, degrees;
    scanf("%u %u %u", &direction, &stepMode, &degrees);

    uint32_t angle = 0;
    uint32_t delayMicrosPerDegree = 1000000 / 15;  // Assuming 15 degrees rotation per second

    while (angle < degrees) {
        controlStepperMotor(direction, stepMode);  // Call your stepper motor control function
        ativaLEDS(angle, direction);
        SysTick_Wait1ms(delayMicrosPerDegree);
        angle += 15;  // Increment the angle by 15 degrees
    }
    printf("FIM\n");
    printf("Press '*' to start again: ");
    waitForChar('*');
    reset();
}

void reset(){
    Motor_Init();
}

// Function to wait for a specific character from UART
void waitForChar(char ch) {
    while (UARTReceive() != ch);
}

//Activate the LEDS based on the direction and the angle
void ativaLEDS(uint32_t graus_atual, uint32_t direction){
    if (!graus_atual%45)
        switch (direction)
        {
        //horario
        case 0:
            //liga os leds da esquerda pra direita
            break;
        //anti-horario
        case 1:
            //liga os leds da direita pra esquerda
            break;
        }
}