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
; PORT A
GPIO_PORTA_LOCK_R    	EQU    	0x40058520
GPIO_PORTA_CR_R      	EQU    	0x40058524
GPIO_PORTA_AMSEL_R   	EQU    	0x40058528
GPIO_PORTA_PCTL_R    	EQU    	0x4005852C
GPIO_PORTA_DIR_R     	EQU    	0x40058400
GPIO_PORTA_AFSEL_R   	EQU    	0x40058420
GPIO_PORTA_DEN_R     	EQU    	0x4005851C
GPIO_PORTA_PUR_R     	EQU    	0x40058510
GPIO_PORTA_DATA_R    	EQU    	0x400583FC
GPIO_PORTA              EQU    	2_0000000000000001
	
; PORT B
GPIO_PORTB_LOCK_R    	EQU    	0x40059520
GPIO_PORTB_CR_R      	EQU    	0x40059524
GPIO_PORTB_AMSEL_R   	EQU    	0x40059528
GPIO_PORTB_PCTL_R    	EQU    	0x4005952C
GPIO_PORTB_DIR_R     	EQU    	0x40059400
GPIO_PORTB_AFSEL_R   	EQU    	0x40059420
GPIO_PORTB_DEN_R     	EQU    	0x4005951C
GPIO_PORTB_PUR_R     	EQU    	0x40059510
GPIO_PORTB_DATA_R    	EQU    	0x400593FC
GPIO_PORTB              EQU    	2_0000000000000010
	
; PORT J
GPIO_PORTJ_LOCK_R    	EQU    	0x40060520
GPIO_PORTJ_CR_R      	EQU    	0x40060524
GPIO_PORTJ_AMSEL_R   	EQU    	0x40060528
GPIO_PORTJ_PCTL_R    	EQU    	0x4006052C
GPIO_PORTJ_DIR_R     	EQU    	0x40060400
GPIO_PORTJ_AFSEL_R   	EQU    	0x40060420
GPIO_PORTJ_DEN_R     	EQU    	0x4006051C
GPIO_PORTJ_PUR_R     	EQU    	0x40060510
GPIO_PORTJ_DATA_R    	EQU    	0x400603FC
GPIO_PORTJ              EQU    	2_0000000100000000
								
	
; PORT P
GPIO_PORTP_LOCK_R    		EQU    	0x40065520
GPIO_PORTP_CR_R      		EQU    	0x40065524
GPIO_PORTP_AMSEL_R   		EQU    	0x40065528
GPIO_PORTP_PCTL_R    		EQU    	0x4006552C
GPIO_PORTP_DIR_R     		EQU    	0x40065400
GPIO_PORTP_AFSEL_R   		EQU    	0x40065420
GPIO_PORTP_DEN_R     		EQU    	0x4006551C
GPIO_PORTP_PUR_R     		EQU    	0x40065510
GPIO_PORTP_DATA_R    		EQU    	0x400653FC
GPIO_PORTP               	EQU    	2_0010000000000000
	
	
; PORT Q
GPIO_PORTQ_LOCK_R    		EQU    	0x40066520
GPIO_PORTQ_CR_R      		EQU    	0x40066524
GPIO_PORTQ_AMSEL_R   		EQU    	0x40066528
GPIO_PORTQ_PCTL_R    		EQU    	0x4006652C
GPIO_PORTQ_DIR_R     		EQU    	0x40066400
GPIO_PORTQ_AFSEL_R   		EQU    	0x40066420
GPIO_PORTQ_DEN_R     		EQU    	0x4006651C
GPIO_PORTQ_PUR_R     		EQU    	0x40066510
GPIO_PORTQ_DATA_R    		EQU    	0x400663FC
GPIO_PORTQ               	EQU    	2_0100000000000000
	


; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
			AREA    |.text|, CODE, READONLY, ALIGN=2
	
			EXPORT GPIO_Init
			EXPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo
			EXPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
			EXPORT PortB_Controle		; Permite chamar PortB_Output de outro arquivo
			EXPORT PortP_Controle		; Permite chamar PortP_Output de outro arquivo	
			EXPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo

;--------------------------------------------------------------------------------
; Função GPIO_Init
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
GPIO_Init
;=====================
; 1. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; e após isso verifica no PRGPIO se a porta está pronta para uso.
			LDR   R0, =SYSCTL_RCGCGPIO_R			;Carrega o endereço do registrador RCGCGPIO
			MOV   R1, #GPIO_PORTA					;Seta o bit da porta A
			ORR   R1, #GPIO_PORTB					;Seta o bit da porta B
			ORR   R1, #GPIO_PORTJ					;Seta o bit da porta J
			ORR   R1, #GPIO_PORTP					;Seta o bit da porta P
			ORR   R1, #GPIO_PORTQ					;Seta o bit da porta Q
			STR   R1, [R0]							

			LDR   R0, =SYSCTL_PRGPIO_R				;Carrega o endereço do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR   R2, [R0]							
			TST   R1, R2							
			BEQ   EsperaGPIO						
			
; 2. Limpar o AMSEL para desabilitar a analógica
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTA_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTB_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTP_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTQ_AMSEL_R
			STR   R1, [R0]
			
; 3. Limpar PCTL para selecionar o GPIO
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTA_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTB_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTP_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTQ_PCTL_R
			STR   R1, [R0]

; 4. DIR para 0 se for entrada, 1 se for saída
			LDR   R0, =GPIO_PORTA_DIR_R
			MOV   R1, #2_11110000						;A7~A4 SAIDA
			STR   R1, [R0]
	
			LDR   R0, =GPIO_PORTQ_DIR_R
			MOV   R1, #2_00001111							;Q3~Q0 SAIDA
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTJ_DIR_R					;J0/J1 LEITURA
			MOV   R1, #0x00
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTP_DIR_R
			MOV   R1, #2_00100000							;P5
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTB_DIR_R
			MOV   R1, #2_00110000							;B4~B5
			STR   R1, [R0]

; 5. Limpa os bits AFSEL
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTA_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTB_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTP_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTQ_AFSEL_R
			STR   R1, [R0]
			
; 6. Seta os bits de DEN para habilitar I/O digital
			LDR   R0, =GPIO_PORTA_DEN_R
			MOV   R1, #2_11110000							;ATIVA A7~A4 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTQ_DEN_R
			MOV   R1, #2_00001111							;ATIVA Q3~Q0 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTJ_DEN_R
			MOV   R1, #2_00000011							;ATIVA J1/J0
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTP_DEN_R
			MOV   R1, #2_00100000							;ATIVA P5
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTB_DEN_R
			MOV   R1, #2_00110000							;ATIVA B5/B4
			STR   R1, [R0]
			
			
; 7. Habilita resistor de pull-up interno para os botões
			LDR   R0, =GPIO_PORTJ_PUR_R
			MOV   R1, #2_00000011
			STR   R1, [R0]

;retorno
			BX    LR
			
			
; -------------------------------------------------------------------------------
; Função ReadPort_J
; Parâmetro de entrada: Não tem
; Parâmetro de saída: R0 --> o valor da leitura
PortJ_Input
	LDR	R1, =GPIO_PORTJ_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;Lê no barramento de dados dos pinos [J0]
	BX LR									;Retorno


; -------------------------------------------------------------------------------
; Função WritePort_A
; Parâmetro de entrada: R0 -> valor para escrever no display
; Parâmetro de saída: Nada
PortA_Output
	LDR	R1, =GPIO_PORTA_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_11110000                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 00001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta A o barramento de dados do pino A4 a A7
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Função WritePort_Q
; Parâmetro de entrada: R0 -> valor para escrever no display
; Parâmetro de saída: Nada
PortQ_Output
	LDR	R1, =GPIO_PORTQ_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_00001111                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 00001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta Q o barramento de dados do pino Q0 a Q3
	BX LR									;Retorno


; -------------------------------------------------------------------------------
; Função WritePort_B
; Parâmetro de entrada: R0 -> valor do bit para ser setado
; Parâmetro de saída: Nada
PortB_Controle
	LDR	R1, =GPIO_PORTB_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_00110000                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta B o barramento de dados do pino B4 e B5
	BX LR									;Retorno


; -------------------------------------------------------------------------------
; Função WritePort_P
; Parâmetro de entrada: R0 -> valor do bit para ser setado
; Parâmetro de saída: Nada
PortP_Controle
	LDR	R1, =GPIO_PORTP_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_00100000                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11011111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parâmetro de entrada
	STR R0, [R1]                            ;Escreve na porta P o barramento de dados do pino P5
	BX LR									;Retorno



    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo