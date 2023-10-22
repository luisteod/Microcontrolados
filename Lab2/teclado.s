; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
ENDERECO_BASE EQU 0x20000400
BAUNCES_AMOUNT EQU 5

PM4 EQU 2_00010000
PM5 EQU 2_00100000
PM6 EQU 2_01000000
PM7 EQU 2_10000000

PL0 EQU 2_1110 0001
PL1 EQU 2_1101 0010
PL2 EQU 2_1011 0100
PL3 EQU 2_0111 1000

TECLA_1 EQU 2_10001000
TECLA_2 EQU 2_10000100
TECLA_3 EQU 2_10000010
TECLA_A EQU 2_10000001
TECLA_4 EQU 2_01001000
TECLA_5 EQU 2_01000100
TECLA_6 EQU 2_01000010
TECLA_B EQU 2_01000001
TECLA_7 EQU 2_00101000
TECLA_8 EQU 2_00100100
TECLA_9 EQU 2_00100010
TECLA_C EQU 2_00100001
TECLA_ASTERISCO EQU 2_00011000
TECLA_0 EQU 2_00010100
TECLA_JOGO_DA_VELHA EQU 2_00010010
TECLA_D EQU 2_00010001

NULL EQU 0x00000000

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
        IMPORT PortM_Output_Teclado ; Permite chamar PortM_Output_Teclado de outro arquivo	
		IMPORT PLL_Init
		IMPORT SysTick_Init
		IMPORT SysTick_Wait
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		
									

;
; -------------------------------------------------------------------------------



; varredura de teclado
; R2 : Guarda o valor da coluna
; R3 : Guarda o valor da linha
; Args : None
; Return : R0 - O valor da tecla em ASCII (0 caso nenhuma pressionada)
varredura
    PUSH{LR}
    ; configura pino M4 como saida
    MOV R2, PM4
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R3, R0
    CMP R3, #0
    BNE decode

    ; configura pino M5 como saida
    MOV R2, PM5
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R3, R0
    CMP R3, #0
    BNE decode

    ; configura pino M6 como saida
    MOV R2, PM6
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R3, R0
    CMP R3, #0
    BNE decode

    ; configura pino M7 como saida
    MOV R2, PM7
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R3, R0
    CMP R3, #0
    BNE decode
    MOV R0, #0 ; Se nao for nenhuma tecla retorna 0
    BEQ varreduraEnd

decode
    ; L0 - L3 (COLUNAS)
    ; M4 - M7 (LINHAS)

    ; 1 = PL3 & PM7
    ; 2 = PL2 & PM7
    ; 3 = PL1 & PM7
    ; A = PL0 & PM7
    ; 4 = PL3 & PM6
    ; 5 = PL2 & PM6
    ; 6 = PL1 & PM6
    ; B = PL0 & PM6
    ; 7 = PL3 & PM5
    ; 8 = PL2 & PM5
    ; 9 = PL1 & PM5
    ; C = PL0 & PM5
    ; * = PL3 & PM4
    ; 0 = PL2 & PM4
    ; # = PL1 & PM4
    ; D = PL0 & PM4

    ORR R0, R2, R3 ; Pega resultado da linha e coluna
    
    CMP R0, NULL
    BEQ varreduraEnd

    ;0
    CMP R0, TECLA_0
    IT EQ
        MOV R0, #0x30

    ;1
    CMP R0, TECLA_1
    IT EQ
        MOV R0, #0x31
    
    ;2
    CMP R0, TECLA_2
    IT EQ
        MOV R0, #0x32
    
    ;3
    CMP R0, TECLA_3
    IT EQ
        MOV R0, #0x33
    
    ;4
    CMP R0, TECLA_4
    IT EQ
        MOV R0, #0x34
    
    ;5
    CMP R0, TECLA_5
    IT EQ
        MOV R0, #0x35
    
    ;6
    CMP R0, TECLA_6
    IT EQ
        MOV R0, #0x36
    
    ;7
    CMP R0, TECLA_7
    IT EQ
        MOV R0, #0x37
    
    ;8
    CMP R0, TECLA_8
    IT EQ
        MOV R0, #0x38
    
    ;9
    CMP R0, TECLA_9
    IT EQ
        MOV R0, #0x39
    
    ;A
    CMP R0, TECLA_A
    IT EQ
        MOV R0, #0x41
    
    ;B
    CMP R0, TECLA_B
    IT EQ
        MOV R0, #0x42
    
    ;C
    CMP R0, TECLA_C
    IT EQ
        MOV R0, #0x43
    
    ;D
    CMP R0, TECLA_D
    IT EQ
        MOV R0, #0x44
    
    ;*
    CMP R0, TECLA_ASTERISCO
    IT EQ
        MOV R0, #0x2A
    
    ;#
    CMP R0, TECLA_JOGO_DA_VELHA
    IT EQ
        MOV R0, #0x23

varreduraEnd
    POP{LR}
    BX LR





; verifica todas as linhas e retorna a linha ativa
; R7 - counter of bounces
; Returns : R0 - BIT of the line active (L0 - L3)
verifyLines
    PUSH{LR}

lineL0
    MOV R7, #0
loopL0
    BL PortL_Input_Teclado
    ;Linha L0
    CMP R0, PL0
    BNE lineL1
    ; Debounce
    MOV R0, #0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, BAUNCES_AMOUNT
    MOV R0, #2_0001
    BEQ verifyEnd
    B loopL0

lineL1
    MOV R7, #0
loopL1
    BL PortL_Input_Teclado
    ;Linha L1
    CMP R0, PL1
    BNE lineL2
    MOV R0, #0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, BAUNCES_AMOUNT
    MOV R0, #2_0010
    BEQ verifyEnd
    B loopL1

lineL2
    MOV R7, #0
loopL2
    BL PortL_Input_Teclado
    ;Linha L2
    CMP R0, PL2
    BNE lineL3
    MOV R0, #0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD  R7, #1
    CMP R7, BAUNCES_AMOUNT
    MOV R0, #2_0100
    BEQ verifyEnd
    B loopL2

lineL3
    MOV R7, #0
loopL3
    BL PortL_Input_Teclado
    ;Linha L3
    CMP R0, PL3
    MOV R0, #0 ; Se nao for nenhuma linha retorna 0
    BNE verifyEnd
    MOV R0, #0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, BAUNCES_AMOUNT
    MOV R0, #2_1000
    BEQ verifyEnd
    B loopL2

verifyEnd

    POP{LR}
    BX LR







