; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait1ms
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo
		IMPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
		IMPORT PortB_Controle		; Permite chamar PortB_Output de outro arquivo
		IMPORT PortP_Controle		; Permite chamar PortP_Output de outro arquivo	
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
									
; Decodificaçao para os displays de 7 segmentos de 0 a F
DISPLAY_NUMBERS   DCB   0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL SysTick_Wait1ms
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
;	R0		PARAMETRO DAS FUNCOES DE GPIO
;	R1		AUX DAS FUNCOES GPIO
;	R2		AUX DAS FUNCOES GPIO
;	R3		AUX GERAL
;	R4		ESTADO DOS BOTOES
;	R5		NUMERO TABUADA 
;	R6		FATOR TABUADA
;	R7		RESULTADO TABUADA
;	R8		ALGARISMO DA DEZENA
;	R9		ALGARISMO DA UNIDADE


	
	MOV R4, #2_00000011				;ESTADO DOS BOTOES
	MOV R5, #2_00000001         ;REGISTRADOR 5 QUE GUARDA O NUMERO ATUAL
	MOV R6, #2_00000001			;REGISTRADOR 6 QUE GUARDA O FATOR MULTIPLICATIVO ATUAL  I.E. 1X1
	MUL R7, R5, R6				;REGISTRADOR 7 QUE GUARDA A MULTIPLICACAO
	
MainLoop
	BL PortJ_Input				;Chama a subrotina que lê o estado das chaves e coloca o resultado em R0
	CMP R0, R4					
	BEQ PROCESS
	BIC R3, R4, R0				
	;R4 PODE SER 00 01 10 11
	;R0 PODE SER 00 01 10 11    SOMENTE MUDA QUANDO É DE 1 PARA 0, OU SEJA, 11 PARA 01 OU 11 PARA 10
	;                           SE MUDA DE 01 PARA 11 OU 10 PARA 11, NAO MUDA NADA
Verifica_SW1	
	CMP R3, #2_00000001			 ;Verifica se somente a chave SW1 está pressionada
	BNE Verifica_SW2             ;Se o teste falhou, pula
	
	MOV R3, R5
	ADD R3, R3, #1
	CMP R3, #2_00001001
	ITE EQ
		MOVEQ R5, #2_00000001
		MOVNE R5, R3
	
	MOV R6, #2_00000001
	 
	B PROCESS

	
Verifica_SW2	
	CMP R3, #2_00000010			 ;Verifica se somente a chave SW2 está pressionada
	BNE PROCESS
	
	MOV R3, R6
	ADD R3, R3, #1
	CMP R3, #2_00001010
	ITE EQ
		MOVEQ R6, #2_00000001
		MOVNE R6, R3
		
	B PROCESS


; -------------------------------------------------------------------------------
; Função PROCESS
; Faz a multiplicação dos números
; Parâmetro de entrada: R5 -> NUMERO ATUAL, R6 -> FATOR MULT ATUAL
; Parâmetro de saída: R9 -> ALGARISMO DA UNIDADE DO RESULTADO, R8 -> ALGARISMO DA DEZENA DA UNIDADE
PROCESS
	MOV R4, R0
	MUL R7, R5, R6
	MOV R3, #10
	UDIV R8, R7, R3 ;ATUALIZA ALGARISMO DEZENA
	MUL R3, R3, R8
	SUB R9, R7, R3 ;ATUALIZA ALGARISMO UNIDADE

; -------------------------------------------------------------------------------
; UPDATE
; Faz a atualização dos LEDS e dos DISPLAYS
; R9 -> ALGARISMO DA UNIDADE DO RESULTADO, R8 -> ALGARISMO DA DEZENA DA UNIDADE
UPDATE
	MOV R0, R8
	BL UPDATE_D1	;D1 DISPLAY DO ALGARISMO DA DEZENA	
	MOV R0, R9
	BL UPDATE_D2	;D2 DISPLAY DO ALGARISMO DA UNIDADE	
	B MainLoop

; -------------------------------------------------------------------------------
; Função UPDATE_D1
; Atualiza o algarismo da dezena CONTROLE PB4
; Parâmetro de entrada: R0 -> VALOR EM DECIMAL PARA APRESENTAR NO DISPLAY
; Parâmetro de saída: Nada
UPDATE_D1
	PUSH {LR}
	
	LDR  R11, =DISPLAY_NUMBERS
	LDRB R10, [R11, R0]
	
	AND R0, R10, #2_11110000
	BL PortA_Output
	AND R0, R10, #2_00001111
	BL PortQ_Output

	MOV R0, #2_00010000		; ATIVA Pino 4 Port B -> PINO DO DISPLAY1
	BL PortB_Controle			; Habilita o Port B
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	MOV R0, #0
	BL PortB_Controle			; Desabilita o Port P
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	
	POP {LR}
	BX LR	
	
	
; -------------------------------------------------------------------------------
; Função UPDATE_D2
; Atualiza o algarismo da unidade CONTROLE PB5
; Parâmetro de entrada: R0 -> VALOR EM DECIMAL PARA APRESENTAR NO DISPLAY
; Parâmetro de saída: Nada
UPDATE_D2
	PUSH {LR}
	
	LDR  R11, =DISPLAY_NUMBERS
	LDRB R10, [R11, R0]
	
	AND R0, R10, #2_11110000
	BL PortA_Output
	AND R0, R10, #2_00001111
	BL PortQ_Output

	MOV R0, #2_00100000		; ATIVA Pino 5 Port B -> PINO DO DISPLAY2
	BL PortB_Controle			; Habilita o Port B
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	MOV R0, #0
	BL PortB_Controle			; Desabilita o Port P
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	
	POP {LR}
	BX LR	

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
