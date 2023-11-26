#ifndef ADC_H
#define ADC_H

#define VALOR_MAX_ADC 0xFFF

void adc_init(void);
uint32_t adc_read(void);

#endif
