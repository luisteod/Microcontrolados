#include <stdint.h>
#include "motor.h"
#include "tm4c1294ncpdt.h"


volatile uint32_t *const GPIO_PORT_H = (0x1 << 7)/* address of GPIO port H register, connected to the motor*/;
void SysTick_Wait1ms(uint32_t delay);
void PortH_Output(uint32_t graus);

void Motor_Init(void){
    PortH_Output(0);
}
// Function to control the stepper motor
void controlStepperMotor(void) {
    
}

