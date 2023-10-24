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

; colunas (joga coluna como saida)
PM4 EQU 0x10
PM5 EQU 0x20
PM6 EQU 0x40
PM7 EQU 0x80

; linhas (ve qual linha tem 0)
PL0 EQU 0xE ;1110
PL1 EQU 0xD ;1101 
PL2 EQU 0xB ;1011 
PL3 EQU 0x7 ;0111 

TECLA_1 EQU 0x11
TECLA_2 EQU 0x21
TECLA_3 EQU 0x41
TECLA_A EQU 0x81
TECLA_4 EQU 0x12
TECLA_5 EQU 0x22
TECLA_6 EQU 0x42
TECLA_B EQU 0x82
TECLA_7 EQU 0x14
TECLA_8 EQU 0x24
TECLA_9 EQU 0x44
TECLA_C EQU 0x84
TECLA_ASTERISCO EQU 0x18
TECLA_0 EQU 0x28
TECLA_JOGO_DA_VELHA EQU 0x48
TECLA_D EQU 0x88

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

        EXPORT varredura            ; Permite chamar a fun��o varredura a partir de
									
		; Se chamar alguma fun��o externa
        IMPORT PortM_Output_Teclado ; Permite chamar PortM_Output_Teclado de outro arquivo
	    IMPORT PortL_Input
		IMPORT SysTick_Wait
	
		
									

;
; -------------------------------------------------------------------------------



; varredura de teclado
; R11 : Guarda o valor da coluna
; R12 : Guarda o valor da linha
; Args : None
; Return : R0 - O valor da tecla em ASCII (0 caso nenhuma pressionada)
varredura
    PUSH{LR}
    ; configura pino M4 como saida
    MOV R11, #PM4
	MOV R0, R11
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R12, R0
    CMP R12, #0
    BNE decode

    ; configura pino M5 como saida
    MOV R11, #PM5
	MOV R0, R11
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R12, R0
    CMP R12, #0
    BNE decode

    ; configura pino M6 como saida
    MOV R11, #PM6
	MOV R0, R11
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R12, R0
    CMP R12, #0
    BNE decode

    ; configura pino M7 como saida
    MOV R11, #PM7
	MOV R0, R11	
    BL PortM_Output_Teclado
    BL verifyLines
    MOV R12, R0
    CMP R12, #0
    BNE decode
    MOV R0, #0 ; Se nao for nenhuma tecla retorna 0
    BEQ varreduraEnd

decode
    ; L0 - L3 (LINHAS)
    ; M4 - M7 (COLUNAS)

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

    ORR R0, R11, R12 ; Pega resultado da linha e coluna
    
    CMP R0, #NULL
    BEQ varreduraEnd

    ;0
    CMP R0, #TECLA_0
    IT EQ
        MOVEQ R0, #0x30

    ;1
    CMP R0, #TECLA_1
    IT EQ
        MOVEQ R0, #0x31
    
    ;2
    CMP R0, #TECLA_2
    IT EQ
        MOVEQ R0, #0x32
    
    ;3
    CMP R0, #TECLA_3
    IT EQ
        MOVEQ R0, #0x33
    
    ;4
    CMP R0, #TECLA_4
    IT EQ
        MOVEQ R0, #0x34
    
    ;5
    CMP R0, #TECLA_5
    IT EQ
        MOVEQ R0, #0x35
    
    ;6
    CMP R0, #TECLA_6
    IT EQ
        MOVEQ R0, #0x36
    
    ;7
    CMP R0, #TECLA_7
    IT EQ
        MOVEQ R0, #0x37
    
    ;8
    CMP R0, #TECLA_8
    IT EQ
        MOVEQ R0, #0x38
    
    ;9
    CMP R0, #TECLA_9
    IT EQ
        MOVEQ R0, #0x39
    
    ;A
    CMP R0, #TECLA_A
    IT EQ
        MOVEQ R0, #0x41
    
    ;B
    CMP R0, #TECLA_B
    IT EQ
        MOVEQ R0, #0x42
    
    ;C
    CMP R0, #TECLA_C
    IT EQ
        MOVEQ R0, #0x43
    
    ;D
    CMP R0, #TECLA_D
    IT EQ
        MOVEQ R0, #0x44
    
    ;*
    CMP R0, #TECLA_ASTERISCO
    IT EQ
        MOVEQ R0, #0x2A
    
    ;#
    CMP R0, #TECLA_JOGO_DA_VELHA
    IT EQ
        MOVEQ R0, #0x23

varreduraEnd
    POP{LR}
    BX LR




; ---------------------------------------------------------------------
; verifica todas as linhas e retorna a linha ativa
; R7 - counter of bounces
; Returns : R0 - BIT of the line active (L0 - L3)
verifyLines
    PUSH{LR}

lineL0
    MOV R7, #0
loopL0
    BL PortL_Input
    ;Linha L0
    CMP R0, #PL0
    BNE lineL1
    ; Debounce
    LDR R0, =0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, #BAUNCES_AMOUNT
    MOV R0, #0x1
    BEQ verifyEnd
    B loopL0

lineL1
    MOV R7, #0
loopL1
    BL PortL_Input
    ;Linha L1
    CMP R0, #PL1
    BNE lineL2
    LDR R0, =0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, #BAUNCES_AMOUNT
    MOV R0, #0x2
    BEQ verifyEnd
    B loopL1

lineL2
    MOV R7, #0
loopL2
    BL PortL_Input
    ;Linha L2
    CMP R0, #PL2
    BNE lineL3
    LDR R0, =0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD  R7, #1
    CMP R7, #BAUNCES_AMOUNT
    MOV R0, #0x4
    BEQ verifyEnd
    B loopL2

lineL3
    MOV R7, #0
loopL3
    BL PortL_Input
    ;Linha L3
    CMP R0, #PL3
	IT NE
		MOVNE R0, #0 ; Se nao for nenhuma linha retorna 0
    BNE verifyEnd
    LDR R0, =0xC3500 ; Configura systick para 10ms
    BL SysTick_Wait
    ADD R7, #1
    CMP R7, #BAUNCES_AMOUNT
    MOV R0, #0x8
    BEQ verifyEnd
    B loopL3

verifyEnd

    POP{LR}
    BX LR

	ALIGN 
	END





