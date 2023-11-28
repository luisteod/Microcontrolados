#include "teclado.h"

#define GPIO_PORTL (0X1 << 10)
#define GPIO_PORTM (0X1 << 11)

char keyboard_read(void){
    // Primeira coluna
    PortM_Output_teclado(0x10);
    SysTick_Wait1ms(20);

    uint8_t input = PortL_Input();
		SysTick_Wait1ms(20);
    if(input != 0x0F){
        if(input == 0x07){
            return '*';
        } else if(input == 0x0B){
            return '7';
        } else if(input == 0x0D){
            return '4';
        } else if(input == 0x0E){
            return '1';
        }
    }

    // Segunda coluna
    PortM_Output_teclado(0x20);
    SysTick_Wait1ms(20);

    input = PortL_Input();
		SysTick_Wait1ms(20);
    if(input != 0x0F){
        if(input == 0x07){
            return '0';
        } else if(input == 0x0B){
            return '8';
        } else if(input == 0x0D){
            return '5';
        } else if(input == 0x0E){
            return '2';
        }
    }

    // Terceira coluna
    PortM_Output_teclado(0x40);
    SysTick_Wait1ms(20);

    input = PortL_Input();
		SysTick_Wait1ms(20);
    if(input != 0x0F){
        if(input == 0x07){
            return '#';
        } else if(input == 0x0B){
            return '9';
        } else if(input == 0x0D){
            return '6';
        } else if(input == 0x0E){
            return '3';
        }
    }

    // Quarta coluna
    PortM_Output_teclado(0x80);
    SysTick_Wait1ms(20);

    input = PortL_Input();
		SysTick_Wait1ms(20);
    if(input != 0x0F){
        if(input == 0x07){
            return 'D';
        } else if(input == 0x0B){
            return 'C';
        } else if(input == 0x0D){
            return 'B';
        } else if(input == 0x0E){
            return 'A';
        }
    }

    return 0;
}


//void PortM_Dir(uint32_t valor){
//    uint32_t temp;
//    //vamos zerar somente os bits menos significativos
//    //para uma escrita amig�vel nos bits 4-7
//    temp = GPIO_PORTM_DIR_R & 0x0F;
//    //agora vamos fazer o OR com o valor recebido na fun��o
//    temp = temp | valor;
//    GPIO_PORTM_DIR_R = temp; 
//}