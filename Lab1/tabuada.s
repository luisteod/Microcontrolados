; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait1ms
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortQ_Output			; Permite chamar PortQ_Output de outro arquivo
		IMPORT PortA_Output			; Permite chamar PortA_Output de outro arquivo
		IMPORT PortB_Controle		; Permite chamar PortB_Output de outro arquivo
		IMPORT PortP_Controle		; Permite chamar PortP_Output de outro arquivo	
		IMPORT PortJ_Input          ; Permite chamar PortJ_Input de outro arquivo
									
; Decodifica�ao para os displays de 7 segmentos de 0 a 9
; DCB expression => A quoted string. The characters of the string are loaded into consecutive bytes of store at DISPLAY_NUMBERS
DISPLAY_NUMBERS   DCB   2_00111111, 2_00000110, 2_01011011, 2_01001111, 2_01100110, 2_01101101, 2_01111101, 2_00000111, 2_01111111, 2_01100111
;0011 1111 	0 -> a b c d e f 
;0000 0110  1 -> b c 
;0101 1011  2 -> a b d e g 
;0100 1111  3 -> a b c d g
;0110 0110  4 -> b c f g
;0110 1101  5 -> a c d f g
;0111 1101  6 -> a c d e f g
;0000 0111  7 -> a b c
;0111 1111  8 -> a b c d e f g
;0110 0111  9 -> a b c f g
;
; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
;	R0		PARAMETRO DAS FUNCOES DE GPIO
;	R1		AUX GERAL
;   R2		AUX GERAL
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
	BL PortJ_Input				;Chama a subrotina que l� o estado das chaves e coloca o resultado em R0
	CMP R0, R4					
	BEQ PROCESS
	BIC R3, R4, R0				
	;R4 PODE SER 00 01 10 11
	;R0 PODE SER 00 01 10 11    SOMENTE MUDA QUANDO � DE 1 PARA 0, OU SEJA, 11 PARA 01 OU 11 PARA 10
	;                           SE MUDA DE 01 PARA 11 OU 10 PARA 11, NAO MUDA NADA
Verifica_SW1	
	CMP R3, #2_00000001			 ;Verifica se somente a chave SW1 est� pressionada
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
	CMP R3, #2_00000010			 ;Verifica se somente a chave SW2 est� pressionada
	BNE PROCESS
	
	MOV R3, R6
	ADD R3, R3, #1
	CMP R3, #2_00001010
	ITE EQ
		MOVEQ R6, #2_00000001
		MOVNE R6, R3
		
	B PROCESS


; -------------------------------------------------------------------------------
; Fun��o PROCESS
; Faz a multiplica��o dos n�meros
; Par�metro de entrada: R5 -> NUMERO ATUAL, R6 -> FATOR MULT ATUAL
; Par�metro de sa�da: R9 -> ALGARISMO DA UNIDADE DO RESULTADO, R8 -> ALGARISMO DA DEZENA DA UNIDADE
PROCESS
	MOV R4, R0
	MUL R7, R5, R6
	MOV R3, #10
	UDIV R8, R7, R3 ;ATUALIZA ALGARISMO DEZENA
	MUL R2, R3, R8
	SUB R9, R7, R2 ;ATUALIZA ALGARISMO UNIDADE

; -------------------------------------------------------------------------------
; UPDATE
; Faz a atualiza��o dos LEDS e dos DISPLAYS
; R9 -> ALGARISMO DA UNIDADE DO RESULTADO, R8 -> ALGARISMO DA DEZENA DA UNIDADE
UPDATE
	MOV R0, R8
	BL UPDATE_D1	;D1 DISPLAY DO ALGARISMO DA DEZENA	
	MOV R0, R9
	BL UPDATE_D2	;D2 DISPLAY DO ALGARISMO DA UNIDADE	
	MOV R0, R5
	BL UPDATE_LED
	B MainLoop

; -------------------------------------------------------------------------------
; Fun��o UPDATE_LED
; Escreve nos leds 1~8 o numero atual da cuja tabuada est� sendo feita
; Par�metro de entrada: R0 -> numero atual
; Par�metro de sa�da: Nada
UPDATE_LED
	PUSH {LR}
	
	MOV R2, #0
	MOV R3, R0		; COPIA O NUMERO ATUAL

CARREGA_LEDS
	CMP R3, #0		;NUMERO ATUAL CHEGOU AO FIM
	ITTTT NE
		LSLNE R2, R2, #1	; JOGA OS BITS PRA ESQUERDA
		ADDNE R2, R2, #1	; ACIONA O NOVO ULTIMO BIT COMO 1
		SUBNE R3, R3, #1	; DIMINUI UM DO NUMERO ATUAL
		BNE CARREGA_LEDS	; ex: se o numero atual for 3
							;	  r3 = 3 -> acende 1 led, r3 = 2, r2 = 1
							;     r3 = 2 -> acende 2 led, r3 = 1, r2 = 11	
							;     r3 = 1 -> acende 3 led, r3 = 0, r2 = 111
							; 	  cai fora 
	MOV R0, R2
	BL PortA_Output
	BL PortQ_Output
	
	MOV R0, #2_00100000		; Ativa o pino 5 do Port P
	BL CONTROLE_LEDS
	
	POP {LR}
	BX LR	
	
; -------------------------------------------------------------------------------
; Fun��o UPDATE_D1
; Atualiza o algarismo da dezena CONTROLE PB4
; Par�metro de entrada: R0 -> VALOR EM BINARIO PARA APRESENTAR NO DISPLAY1
; Par�metro de sa�da: Nada
UPDATE_D1
	PUSH {LR}
	
	LDR  R1, =DISPLAY_NUMBERS
	LDRB R2, [R1, R0]  ;R0 � UM OFFSET NO VETOR ONDE COME�A DISPLAY NUMBERS
						;DESSA FORMA, LE-SE O BINARIO DECODIFICADO PARA LIGAR OS LEDS DO DISPLAY7SEG
	
	MOV R0, R2
	BL PortA_Output
	BL PortQ_Output

	MOV R0, #2_00010000		; ATIVA Pino 4 Port B -> PINO DO DISPLAY1
	BL CONTROLE_DISPLAY	
	
	POP {LR}
	BX LR	
	
	
; -------------------------------------------------------------------------------
; Fun��o UPDATE_D2
; Atualiza o algarismo da unidade CONTROLE PB5
; Par�metro de entrada: R0 -> VALOR EM BINARIO PARA APRESENTAR NO DISPLAY2
; Par�metro de sa�da: Nada
UPDATE_D2
	PUSH {LR}
	
	LDR  R1, =DISPLAY_NUMBERS
	LDRB R2, [R1, R0]
	
	MOV R0, R2
	BL PortA_Output
	BL PortQ_Output

	MOV R0, #2_00100000		; ATIVA Pino 5 Port B -> PINO DO DISPLAY2
	BL CONTROLE_DISPLAY	
	
	POP {LR}
	BX LR	

; -------------------------------------------------------------------------------
; Fun��o CONTROLE_DISPLAY
; Atualiza o controle do display para que os valores passem e logo desativa
; Par�metro de entrada: R0 -> Port a ser habilitada
; Par�metro de sa�da: Nada
CONTROLE_DISPLAY
	PUSH{LR}
	BL PortB_Controle			; Habilita o Port B
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	MOV R0, #0
	BL PortB_Controle			; Desabilita o Port B
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	POP{LR}
	BX LR
; -------------------------------------------------------------------------------
; Fun��o CONTROLE_LEDS
; Atualiza o controle dos LEDS para que os valores passem e logo desativa
; Par�metro de entrada: R0 -> Port a ser habilitada
; Par�metro de sa�da: Nada
CONTROLE_LEDS
	PUSH{LR}
	BL PortP_Controle			; Habilita o Port P
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	MOV R0, #0
	BL PortP_Controle			; Desabilita o Port P
	MOV R0, #1
	BL SysTick_Wait1ms		; Aguarda 1ms
	POP{LR}
	BX LR

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
