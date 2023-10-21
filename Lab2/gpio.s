; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Aluno Matheus Augusto Burda


; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
; ========================
; Definições dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
;PORT K
; K7~K0 BARRAMENTO DE DADOS
GPIO_PORTK_LOCK_R    	EQU    	0x40061520
GPIO_PORTK_CR_R      	EQU    	0x40061524
GPIO_PORTK_AMSEL_R   	EQU    	0x40061528
GPIO_PORTK_PCTL_R    	EQU    	0x4006152C
GPIO_PORTK_DIR_R     	EQU    	0x40061400
GPIO_PORTK_AFSEL_R   	EQU    	0x40061420
GPIO_PORTK_DEN_R     	EQU    	0x4006151C
GPIO_PORTK_PUR_R     	EQU    	0x40061510
GPIO_PORTK_DATA_R    	EQU    	0x400613FC
GPIO_PORTK              EQU    	2_0000001000000000
	
;PORT M
; M7~M4 VARREDURA DAS COLUNAS DO TECLADO, INICIALIZADOS COMO ENTRADAS PARA ALTA IMPEDANCIA/SAIDAS
; M2 ENABLE DO LCD
; M1 RW 0 = ESCRITA, 1 = LEITURA
; M0 RS 0 = INSTRUCAO, 1 = DADO
GPIO_PORTM_LOCK_R    	EQU    	0x40063520
GPIO_PORTM_CR_R      	EQU    	0x40063524
GPIO_PORTM_AMSEL_R   	EQU    	0x40063528
GPIO_PORTM_PCTL_R    	EQU    	0x4006352C
GPIO_PORTM_DIR_R     	EQU    	0x40063400
GPIO_PORTM_AFSEL_R   	EQU    	0x40063420
GPIO_PORTM_DEN_R     	EQU    	0x4006351C
GPIO_PORTM_PUR_R     	EQU    	0x40063510
GPIO_PORTM_DATA_R    	EQU    	0x400633FC
GPIO_PORTM              EQU    	2_0000100000000000
	
;PORT L
; L3 ~L0 VARREDURA DAS LINHAS DO TECLADO, INICIALIZADOS COMO ENTRADA
GPIO_PORTL_LOCK_R    	EQU    	0x40062520
GPIO_PORTL_CR_R      	EQU    	0x40062524
GPIO_PORTL_AMSEL_R   	EQU    	0x40062528
GPIO_PORTL_PCTL_R    	EQU    	0x4006252C
GPIO_PORTL_DIR_R     	EQU    	0x40062400
GPIO_PORTL_AFSEL_R   	EQU    	0x40062420
GPIO_PORTL_DEN_R     	EQU    	0x4006251C
GPIO_PORTL_PUR_R     	EQU    	0x40062510 ;NECESSITA RESISTOR DE PULLUP INTERNO ATIVO
GPIO_PORTL_DATA_R    	EQU    	0x400623FC
GPIO_PORTL              EQU    	2_0000010000000000
	

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
			AREA    |.text|, CODE, READONLY, ALIGN=2
	
			EXPORT GPIO_Init
			EXPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
			EXPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
			EXPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo

;--------------------------------------------------------------------------------
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
GPIO_Init
;=====================
; 1. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; e após isso verifica no PRGPIO se a porta está pronta para uso.
			LDR   R0, =SYSCTL_RCGCGPIO_R			;Carrega o endereço do registrador RCGCGPIO
			MOV   R1, #GPIO_PORTM					;Seta o bit da porta M
			ORR   R1, #GPIO_PORTL					;Seta o bit da porta L
			ORR   R1, #GPIO_PORTK					;Seta o bit da porta K
			STR   R1, [R0]							

			LDR   R0, =SYSCTL_PRGPIO_R				;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR   R2, [R0]							
			TST   R1, R2							
			BEQ   EsperaGPIO						
			
; 2. Limpar o AMSEL para desabilitar a analógica
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_AMSEL_R
			STR   R1, [R0]
			
; 3. Limpar PCTL para selecionar o GPIO
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_PCTL_R
			STR   R1, [R0]

; 4. DIR para 0 se for entrada, 1 se for saída
			LDR   R0, =GPIO_PORTM_DIR_R
			MOV   R1, #2_00000111				;M2~M0 SAIDA
			STR   R1, [R0]
	
			LDR   R0, =GPIO_PORTL_DIR_R
			MOV   R1, #0x00							;L3~L0
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTK_DIR_R					;K7~K0
			MOV   R1, #2_11111111
			STR   R1, [R0]


; 5. Limpa os bits AFSEL
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_AFSEL_R
			STR   R1, [R0]

			
; 6. Seta os bits de DEN para habilitar I/O digital
			LDR   R0, =GPIO_PORTM_DEN_R
			MOV   R1, #2_11111111							;ATIVA M7~M0 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTL_DEN_R
			MOV   R1, #2_00001111							;ATIVA L3~L0 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTK_DEN_R
			MOV   R1, #2_11111111									;ATIVA K7~K0
			STR   R1, [R0]
			
			
			
; 7. Habilita resistor de pull-up interno para os pinos que verificam as linhas e colunas
			LDR   R0, =GPIO_PORTL_PUR_R
			MOV   R1, #2_00001111
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTM_PUR_R
			MOV   R1, #2_11110000
			STR   R1, [R0]

;retorno
			BX    LR
			
			
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; Função PortL_Input
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
PortL_Input
	LDR	R1, =GPIO_PORTL_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos [J0]
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Função PortM_Output 
; Parâmetro de entrada: R0 
; Parâmetro de saída: Nada
PortM_Output
	LDR	R1, =GPIO_PORTM_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_00000111                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 00001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta D o barramento de dados do pino D
	BX LR									;Retorno


; -------------------------------------------------------------------------------
; Função PortK_Output
; Parâmetro de entrada: R0 -> valor para escrever no display
; Parâmetro de saída: Nada
PortK_Output
	LDR	R1, =GPIO_PORTK_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_11111111                     ;Primeiro limpamos os dois bits do lido da porta
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta D o barramento de dados do pino D
	BX LR									;Retorno


    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo