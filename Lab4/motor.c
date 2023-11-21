#include <stdint.h>
#include "motor.h"
#include "tm4c1294ncpdt.h"

#define GPIO_PORT_H = (0x1 << 7) /* address of GPIO port H register, connected to the motor*/;
#define graus_passo_completo 2048
#define graus_meio_passo 4096
void SysTick_Wait1ms(uint32_t delay);
void PortH_Output(uint32_t graus);

void Motor_Init(void)
{
    PortH_Output(0);
}
// Function to control the stepper motor
void controlStepperMotor(uint32_t direction, uint32_t stepMode)
{
    // passo completo

    for (int i = 0; i < 22; i++)
    {
        if (stepMode == '0')
        {
            if (direction == '0')
            {
                // nesse caso o motor está andando 4 passos, o equivalente ao step angle x 4
                PortH_Output(0xe); // 1110
                SysTick_Wait1ms(10);
                PortH_Output(0xd); // 1101
                SysTick_Wait1ms(10);
                PortH_Output(0xb); // 1011
                SysTick_Wait1ms(10);
                PortH_Output(0x7); // 0111
                SysTick_Wait1ms(10);
            }
            else if (direction == '1')
            {

                PortH_Output(0x8); // 0111
                SysTick_Wait1ms(10);
                PortH_Output(0x4); // 1011
                SysTick_Wait1ms(10);
                PortH_Output(0x2); // 1101
                SysTick_Wait1ms(10);
                PortH_Output(0x1); // 1110
                SysTick_Wait1ms(10);
            }
        }
        // meio passo
        else if (stepMode == '1')
        {
            if (direction == '0')
            {

                PortH_Output(0xE); // 1110
                SysTick_Wait1ms(10);
                PortH_Output(0xC); // 1100
                SysTick_Wait1ms(10);

                PortH_Output(0xD); // 1101
                SysTick_Wait1ms(10);
                PortH_Output(0x9); // 1001
                SysTick_Wait1ms(10);

                PortH_Output(0xB); // 1011
                SysTick_Wait1ms(10);
                PortH_Output(0x3); // 0011
                SysTick_Wait1ms(10);

                PortH_Output(0x7); // 0111
                SysTick_Wait1ms(10);
                PortH_Output(0x6); // 0110
                SysTick_Wait1ms(10);
            }
            else if (direction == '1')
            {

                PortH_Output(0x6); // 0110
                SysTick_Wait1ms(10);
                PortH_Output(0x7); // 0111
                SysTick_Wait1ms(10);

                PortH_Output(0x3); // 0011
                SysTick_Wait1ms(10);
                PortH_Output(0xB); // 1011
                SysTick_Wait1ms(10);

                PortH_Output(0x9); // 1001
                SysTick_Wait1ms(10);
                PortH_Output(0xD); // 1101
                SysTick_Wait1ms(10);

                PortH_Output(0xC); // 1100
                SysTick_Wait1ms(10);
                PortH_Output(0xE); // 1110
                SysTick_Wait1ms(10);
            }
        }
    }
}
