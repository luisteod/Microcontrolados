; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Aluno Vinicius Kamiya Svierk
; Aluno Luis Henrique


; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; Defini��es dos Registradores Gerais
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
GPIO_PORTJ_AHB_IM_R		EQU    0x40060410
GPIO_PORTJ_AHB_IS_R     EQU	   0x40060404
GPIO_PORTJ_AHB_IBE_R 	EQU	   0x40060408
GPIO_PORTJ_AHB_IEV_R 	EQU	   0x4006040C
GPIO_PORTJ_AHB_ICR_R 	EQU	   0x4006041C
GPIO_PORTJ_AHB_RIS_R    EQU	   0x40060414
GPIO_PORTJ              EQU    	2_0000000100000000

; PORT N
GPIO_PORTN_LOCK_R    	EQU    0x40064520
GPIO_PORTN_CR_R      	EQU    0x40064524
GPIO_PORTN_AMSEL_R   	EQU    0x40064528
GPIO_PORTN_PCTL_R    	EQU    0x4006452C
GPIO_PORTN_DIR_R     	EQU    0x40064400
GPIO_PORTN_AFSEL_R   	EQU    0x40064420
GPIO_PORTN_DEN_R     	EQU    0x4006451C
GPIO_PORTN_PUR_R     	EQU    0x40064510	
GPIO_PORTN_DATA_R    	EQU    0x400643FC
GPIO_PORTN_DATA_BITS_R  EQU    0x40064000
GPIO_PORTN               	EQU    2_001000000000000
	
NVIC_EN1_R                  EQU    0xE000E104
NVIC_PRI12_R                EQU    0xE000E430

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
			AREA    |.text|, CODE, READONLY, ALIGN=2
	
			EXPORT GPIO_Init
			EXPORT Interrupt_init
			EXPORT GPIOPortJ_Handler
			EXPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
			EXPORT PortM_Output_Display ; Permite chamar PortM_Output_Display de outro arquivo
			EXPORT PortM_Output_Teclado
			EXPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
			

;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; 1. Ativa o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; e ap�s isso verifica no PRGPIO se a porta est� pronta para uso.
			LDR   R0, =SYSCTL_RCGCGPIO_R			;Carrega o endere�o do registrador RCGCGPIO
			MOV   R1, #GPIO_PORTM					;Seta o bit da porta M
			ORR   R1, #GPIO_PORTL					;Seta o bit da porta L
			ORR   R1, #GPIO_PORTK					;Seta o bit da porta K
			ORR   R1, #GPIO_PORTJ
			STR   R1, [R0]							

			LDR   R0, =SYSCTL_PRGPIO_R				;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR   R2, [R0]							
			TST   R1, R2							
			BEQ   EsperaGPIO						
			
; 2. Limpar o AMSEL para desabilitar a analogica
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_AMSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_AMSEL_R
			STR   R1, [R0]
			
; 3. Limpar PCTL para selecionar o GPIO
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_PCTL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_PCTL_R
			STR   R1, [R0]

; 4. DIR para 0 se for entrada, 1 se for saida
			LDR   R0, =GPIO_PORTM_DIR_R
			MOV   R1, #2_00000111				;M2~M0 (SAIDA) - M3~M7 (ENTRADA)
			STR   R1, [R0]

			LDR   R0, =GPIO_PORTL_DIR_R
			MOV   R1, #0x00							;L3~L0 (ENTRADA)
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTK_DIR_R					;K7~K0
			MOV   R1, #2_11111111
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTJ_DIR_R					;J0 LEITURA
			MOV   R1, #0x00
			STR   R1, [R0]


; 5. Limpa os bits AFSEL
			MOV   R1, #0x00
			LDR   R0, =GPIO_PORTM_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTL_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTK_AFSEL_R
			STR   R1, [R0]
			LDR   R0, =GPIO_PORTJ_AFSEL_R
			STR   R1, [R0]

			
; 6. Seta os bits de DEN para habilitar I/O digital
			LDR   R0, =GPIO_PORTM_DEN_R
			MOV   R1, #2_11111111							;ATIVA M7~M0 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTL_DEN_R
			MOV   R1, #2_00001111							;ATIVA L3~L0 
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTK_DEN_R
			MOV   R1, #2_11111111							;ATIVA K7~K0
			STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTJ_DEN_R
			MOV   R1, #2_00000001							;ATIVA J0
			STR   R1, [R0]
			
			
			
; 7. Habilita resistor de pull-up interno para os pinos que representam as linhas
			LDR   R0, =GPIO_PORTL_PUR_R
			MOV   R1, #2_00001111
			STR   R1, [R0]
			
			;LDR   R0, =GPIO_PORTM_PUR_R
			;MOV   R1, #2_11110000
			;STR   R1, [R0]
			
			LDR   R0, =GPIO_PORTJ_PUR_R
			MOV   R1, #2_00000001
			STR   R1, [R0]

;retorno
			BX    LR
			
Interrupt_init
			MOV	R1,#0
			LDR R0, =GPIO_PORTJ_AHB_IM_R ;DESATIVA
			STR	R1, [R0]
			
			MOV R1,	#0 
			LDR R0, =GPIO_PORTJ_AHB_IS_R ;BORDA
			STR R1,[R0]
			
			MOV R1,#0
			LDR R0, =GPIO_PORTJ_AHB_IBE_R ;UNICA
			STR R1,[R0]
			
			MOV R1,#0
			LDR R0,=GPIO_PORTJ_AHB_IEV_R ;DESCIDA
			STR R1,[R0]
			
			MOV R1,#1
			LDR R0,=GPIO_PORTJ_AHB_ICR_R ;ACK
			STR R1,[R0]
			
			MOV R1,#1
			LDR R0,=GPIO_PORTJ_AHB_IM_R ;ATIVA
			STR R1,[R0]
			
			MOV R1,#1
			LSL R1,#19
			LDR R0,=NVIC_EN1_R
			STR R1,[R0]
			
			MOV R1,#5
			LSL R1,#29
			LDR R0,=NVIC_PRI12_R	;PRIORIDADE
			STR R1,[R0]
			
			BX LR


GPIOPortJ_Handler
			NOP
InterruptEnd
			LDR R3, =GPIO_PORTJ_AHB_ICR_R
			MOV R1, #2_00000001						                                                  
			STR R1, [R3]
			
			BX LR
			
	
; -------------------------------------------------------------------------------
; -------------------------------------------------------------------------------
; Funcao PortL_Input
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: R0 --> o valor da leitura
PortL_Input
	LDR	R1, =GPIO_PORTL_DATA_R		    ;Carrega o valor do offset do data register
	LDR R0, [R1]                            ;L� no barramento de dados dos pinos [J0]
	BX LR									;Retorno

;Recebe R0 contendo o BIT da porta M a ser configurada (4 - 7)
PortM_Output_Teclado
	LDR R1, =GPIO_PORTM_DIR_R			;Para configurar como saida
	LDR R2, [R1]
	AND R2, #0x7	;Deixa o M2-M0 e elimina o restante dos bits
	ORR R0, R2
	STR R0, [R1]
	
	LDR	R1, =GPIO_PORTM_DATA_R
	MOV R0, #0							;Seta a porta M como 0		    
	STR R0, [R1]                             
	BX LR									
	
; -------------------------------------------------------------------------------
; Funcao PortM_Output_Display 
; Par�metro de entrada: R0 
; Par�metro de saida: Nada
PortM_Output_Display
	LDR	R1, =GPIO_PORTM_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_00000111                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 00001111
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o parametro de entrada
	STR R0, [R1]                            ;Escreve na porta D o barramento de dados do pino D
	BX LR									;Retorno

; -------------------------------------------------------------------------------
; Funcao PortK_Output
; Par�metro de entrada: R0 -> valor para escrever no display
; Par�metro de sa�da: Nada
PortK_Output
	LDR	R1, =GPIO_PORTK_DATA_R		    ;Carrega o valor do offset do data register
	LDR R2, [R1]
	BIC R2, #2_11111111                     ;Primeiro limpamos os dois bits do lido da porta
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta D o barramento de dados do pino D
	BX LR									;Retorno


    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo