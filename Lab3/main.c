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
void UARTInit(void);
void Motor_Init(void);
void ativaLEDS(uint32_t angle, uint32_t direction);
void waitForChar(char ch);
void reset(void);
void reset_LEDS();
unsigned char pula_linha[] = "\n\r";
unsigned char espaco = ' ';

//global
int is_rotate_canc = 0;
int angulo_it = 0;
int is_motor_active = 0;

// Convert uint32_t to unsigned char array
void att_TERMINAL(uint32_t val, unsigned char vel, unsigned char dir)
{
    uint32_t centena = val / 100;
    uint32_t dezena = (val - centena*100) / 10;
    uint32_t unidade = val % 10;
    unsigned char att[4];
    att[3] = '\0';
    att[2] = unidade + 0x30;
    att[1] = dezena + 0x30;
    att[0] = centena + 0x30;

    UARTTransmit(vel);
    UARTTransmit(espaco);
    UARTTransmit(dir);
    UARTTransmit(espaco);
    UARTSendString(att);
    UARTSendString(pula_linha);
}

// Custom atoi function
uint32_t customAtoi(unsigned char *str)
{
    uint32_t result = 0;
    int i = 0;

    // Iterate through each character in the string
    while (str[i] != '\0')
    {
        // Convert character to digit
        int digit = str[i] - '0';

        // Check if the character is a valid digit
        if (digit >= 0 && digit <= 9)
        {
            // Update the result
            result = result * 10 + digit;
        }
        else
        {
            // Invalid character, break out of the loop
            break;
        }

        // Move to the next character
        i++;
    }

    return result;
}

unsigned char solicita_velocidade()
{

    unsigned char solicita_velocidade[] = "Velocidade(0/1): ";
    UARTSendString(solicita_velocidade);
    unsigned char msg = 0;

    while (msg == 0x00)
    {
        msg = UARTReceive();
        UARTTransmit(msg);
    }
    UARTSendString(pula_linha);
    return (msg);
}

unsigned char solicita_direcao()
{

    unsigned char solicita_direcao[] = "Direcao(0/1): ";
    UARTSendString(solicita_direcao);
    unsigned char msg = 0;

    while (msg == 0)
    {
        msg = UARTReceive();
        UARTTransmit(msg);
    }
    UARTSendString(pula_linha);
    return (msg);
}

// unsigned char* solicita_angulo(){
//     unsigned char solicita_angulo[] = "Angulo(0~360):  ";
//     UARTSendString(solicita_angulo);
//     unsigned char msg = 0;
//     unsigned char* angulo;

//    int index = 0;

//    while(msg != ' ')
//    {
//        msg = UARTReceive();
//        if (msg != 0 && msg != ' ')
//        {
//            UARTTransmit(msg);
//            angulo[index] = msg;
//            index += 1;
//            msg = 0;
//        }
//    }
//
//    // Add a null terminator to make it a valid C string
//    angulo[index] = '\0';
//    UARTSendString(pula_linha);
//	return (angulo);
//}

void RotateFromUART()
{
    unsigned char velocidade = solicita_velocidade();
    unsigned char direcao = solicita_direcao();
    // unsigned char* angulo_char = solicita_angulo();

    unsigned char solicita_angulo[] = "Angulo(0~360): ";
    UARTSendString(solicita_angulo);
    unsigned char msg = 0;
    unsigned char angulo_char[10];

    int index = 0;
    while (msg != ' ')
    {
        msg = UARTReceive();
        if (msg != 0 && msg != ' ')
        {
            UARTTransmit(msg);
            angulo_char[index] = msg;
            index += 1;
            msg = 0;
        }
    }

    // Add a null terminator to make it a valid C string
    angulo_char[index] = '\0';
    UARTSendString(pula_linha);
    unsigned char angulo_it_char[4] = "0";

    uint32_t angulo = customAtoi(angulo_char);

    unsigned char solicita_aguardo[] = "Aguarde...\n";
    UARTSendString(solicita_aguardo);
    UARTSendString(pula_linha);

    att_TERMINAL(velocidade, direcao, 0);

    for(angulo_it = 0 ; angulo_it < angulo && is_rotate_canc == 0; angulo_it += 15)
    {

        UARTSendString(solicita_aguardo);
        UARTSendString(pula_linha);
        controlStepperMotor(direcao, velocidade); // Call your stepper motor control function
        led_dir_output(direcao);
        att_TERMINAL(angulo_it, velocidade, direcao);
    }
    led_dir_output(direcao);
		 att_TERMINAL(angulo_it, velocidade, direcao);

    
    unsigned char fim[] = "FIM...Pressione * para continuar\n";
    UARTSendString(fim);
    UARTSendString(pula_linha);
    waitForChar('*');
    reset();
}

void reset(void)
{
    Motor_Init();
    reset_LEDS();
}

// Function to wait for a specific character from UART
void waitForChar(char ch)
{
    while (UARTReceive() != ch)
        ;
}

int main()
{
    PLL_Init();
    SysTick_Init();
    GPIO_Init();
    UARTInit();
    // Aguarda input do usuário de quantos graus o motor deve girar (0~360), o sentido de rotação e a velocidade
    while (1)
    {
        // Considera a posição do motor como 0 graus
        reset();
        controlStepperMotor(0, 0);
        RotateFromUART();
    }
    return 0;
}
