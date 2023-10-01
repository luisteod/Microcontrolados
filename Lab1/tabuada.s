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
									

; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
	MOV R5, #2_00000001         ;REGISTRADOR QUE GUARDA O NUMERO ATUAL
	MOV R6, #2_00000001			;REGISTRADOR QUE GUARDA O FATOR MULTIPLICATIVO ATUAL
	
	MOV R0, #2_00100000			;A sa�da dos leds � sempre ativa
	BL PortP_Controle
	
	B PISCA_LED
	
	MOV R0, R5
	BL PortA_Output				;Inicializa o n�mero como 1
	BL PortQ_Output				;Inicializa o fator multiplicativo como 1  i.e. 1x1
	
MainLoop
	B PISCA_LED
	BL ATIVA_LED
	BL PortJ_Input				;Chama a subrotina que l� o estado das chaves e coloca o resultado em R0
	
Verifica_SW1
	CMP	R0, #2_00000001			;Se o SW1 est� pressionado
	BEQ MUDA_NUMERO				;muda o n�mero

Verifica_SW2
	CMP R0, #2_00000010			;Se o SW2 est� pressionado
	BEQ MUDA_FATOR				;muda o fator multiplicativo
	
	B MainLoop					;Volta pro MainLoop


;===========================TESTE
PISCA_LED
	MOV R1, R6				 
	ADD R1, #1
	CMP R1, #2_00001010
	ITE EQ
		MOVEQ R6, #2_00000000
		MOVNE R6, R1
	MOV R0, R6				 ;Setar o par�metro de entrada da fun��o setando o BIT1
	BL PortA_Output				 ;Chamar a fun��o para acender o LED1
	MOV R0, #500                ;Chamar a rotina para esperar 0,5s
	BL SysTick_Wait1ms
	MOV R0, R6					 ;Setar o par�metro de entrada da fun��o apagando o BIT1
	BL PortQ_Output				 ;Chamar a rotina para apagar o LED
	MOV R0, #500                ;Chamar a rotina para esperar 0,5
	BL SysTick_Wait1ms	
	B MainLoop
;==================================================================================================================
MUDA_NUMERO
	MOV R1, R5					;Coloca o n�mero atual no registrador R1
	ADD R1, #1					;Pr�ximo n�mero
	
	CMP R1, #2_00001001
	ITE EQ
		MOVEQ R5, #2_00000001
		MOVNE R5, R1
	
	MOV R6, #2_00000000
	
	B CALCULA_TABUADA			;Se o n�mero mudar, reinicia a tabuada
	
MUDA_FATOR
	MOV R1, R6				 
	ADD R1, #1
	CMP R1, #2_00001010
	ITE EQ
		MOVEQ R6, #2_00000000
		MOVNE R6, R1
		
	B CALCULA_TABUADA			;Se o FATOR multiplicativo mudar, recalcula a tabuada


;--------------------------------------------------------------------------------
; Fun��o ATIVA_LED
; Par�metro de entrada: R5 --> O NUMERO ATUAL
; Par�metro de sa�da: N�o tem
ATIVA_LED
	PUSH{LR}
	MOV R0, #1000
	BL SysTick_Wait1ms
	MOV R0, R5					;Manda o n�mero atual para a sa�da dos LEDS
	BL PortA_Output
	BL PortQ_Output
	POP{LR}
	BX LR

;--------------------------------------------------------------------------------
; Fun��o CALCULA_TABUADA
; Par�metro de entrada: R5 --> O NUMERO ATUAL, R6 --> O FATOR ATUAL
; Par�metro de sa�da: N�o tem
CALCULA_TABUADA
	MUL R1,R5,R6
	BL CONVERT_BINARY_BCD    	;USA O VALOR DA TABUADA EM BINARIO NO R1 E DEVOLVE EM BCD NO R2
	BL ATIVA_DISPLAY1			
	BL ATIVA_DISPLAY2
	B MainLoop
	
;--------------------------------------------------------------------------------
; Fun��o CONVERT_BINARY_BCD
; Par�metro de entrada: R1 --> A RESPOSTA DA TABUADA EM BINARIO
; Par�metro de sa�da: R2 --> ALGARISMO MAIS SIGNIFICATIVO, R1 --> ALGARISMO MENOS SIGNIFICATIVO
CONVERT_BINARY_BCD
		PUSH{LR}
		MOV     R2, #0         ;INICIALIZA O RESULTADO BCD COM 0
LOOPBCD
        CMP     R1, #0         ;VE SE O BINARIO JA CHEGOU NO FIM
        BEQ     Done           ;SE � ZERO ACABOU
        ADD     R2, R2, #1     ;INCREMENTA O RESULTADO EM BCD
        SUBS    R1, R1, #10    ;SUBTRAI 10 DO NUMERO BINARIO
        BCS     LOOPBCD           ; If carry flag is set, continue looping
Done
		POP{LR}
		BX LR
		
; -------------------------------------------------------------------------------
; Fun��o ATIVA_DISPLAY1
; Par�metro de entrada: R2 --> O ALGARISMO CORRESPONDENTE 
; Par�metro de sa�da: N�o tem
ATIVA_DISPLAY1
	PUSH{LR}
	MOV R0, #1000
	BL SysTick_Wait1ms
	MOV R0, #2_00010000
	BL PortB_Controle      	;Se vai mudar o n�mero, ativa o transistor do DS1	
	MOV R0, R2
	BL PortA_Output
	BL PortQ_Output
	POP{LR}
	BX LR
	
; -------------------------------------------------------------------------------
; Fun��o ATIVA_DISPLAY2
; Par�metro de entrada: R1 --> O ALGARISMO CORRESPONDENTE
; Par�metro de sa�da: N�o tem
ATIVA_DISPLAY2
	PUSH{LR}
	MOV R0, #1000
	BL SysTick_Wait1ms
	MOV R0, #2_00001000		;Se vai mudar o fator multiplicativo, ativa o transistor do DS2
	BL PortB_Controle
	MOV R0, R1
	BL PortA_Output
	BL PortQ_Output
	POP{LR}
	BX LR
	
	
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
