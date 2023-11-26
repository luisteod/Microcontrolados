#include <stdint.h>
#include "tm4c1294ncpdt.h"

//MAP TO ADC MODULE 0
#define ADC0 0x1

void adc_init(void)
{
	SYSCTL_RCGCADC_R = ADC0;
	
	while((SYSCTL_PRADC_R & ADC0) != ADC0);
	
	//seta prioridade do SS3 como maxima
	ADC0_SSPRI_R  = 0x0 << 13;
	
	//desabilita o sequenciador para a configuracao
	ADC0_ACTSS_R = 0x0;
	
	//seta a fonte de interrupcao como sendo o processador
	ADC0_EMUX_R	 = 0x0 << 15;
	
	//seta a entrada analogica como sendo a AN9, uma vez que o potenciomentro esta nessa porta
	ADC0_SSMUX3_R = 0x9;
	
	ADC0_SSCTL3_R = ADC_SSCTL3_IE0 | ADC_SSCTL3_END0;
	
	//habilita o sequenciador
	ADC0_ACTSS_R = 0x1 << 3;
}

uint32_t adc_read(void)
{
	//inicializa a conversao no SS3
	ADC0_PSSI_R = 0x8;
	
	while((ADC0_RIS_R & (0x1 << 3)) != (0x1 << 3));
	
	//limpa a flag de interrupcao apos a leitura
	ADC0_ISC_R = (0x1 << 3);
	
	return ADC0_SSFIFO3_R;	
}
