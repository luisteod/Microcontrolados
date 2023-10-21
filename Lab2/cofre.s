; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
ENDERECO_BASE EQU 0x20000400
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
		IMPORT SysTick_Wait
		IMPORT SysTick_Wait1ms
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		
;�Cofre aberto, digite nova senha para fechar o cofre�.
;cofre aberto = cfr abt
COFRE_ABERTO DCB 0x43, 0x66, 0x72, 0x20 ,0x61,0x62,0x74,0x2C, 0x00

;digite nova senha = dgt nv snh
DIGITE_NOVA_SENHA DCB 0x64, 0x67, 0x74, 0x20, 0x6E, 0x76, 0x20, 0x73, 0x6E, 0x68, 0x00
;

init_string = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x61, 0x62, 0x65, 0x72, 0x74, 0x6F, 0x2C, 0x20, 0x64, 0x69, 0x67, 0x69, 0x74, 0x65, 0x20, 0x6E, 0x6F, 0x76, 0x61, 0x20, 0x73, 0x65, 0x6E, 0x68, 0x61, 0x20, 0x00
; -------------------------------------------------------------------------------
; Fun��o main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
	mov r10, #1    ;equivale � linha atual
	mov r11, #0 ;equivale � coluna atual da linha
	
LCD_Init
    movs r0, #0x38      
    bl  LCD_SendCommand
	bl Delay_40us

    movs r0, #0x0C      ; Display ON/OFF Control (Display on, Cursor off, Blinking off)
    bl  LCD_SendCommand
	bl Delay_40us

    movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand
	bl Delay_1640us

    movs r0, #0x06    ; Entry Mode Set (Increment cursor, no display shift)
    bl  LCD_SendCommand
	bl Delay_40us

    movs r0, #0x80
    bl  LCD_SendCommand
	bl Delay_40us
	
    BL Cofre_Aberto



MainLoop
	mov r10, #1
	
	BL LCD_Update
	B MainLoop
	
LCD_Update
	push{lr}
	
    bl Cofre_Aberto
	pop{lr}
	BX LR

; Fun��o LCD_SendCommand
; Rotina para enviar um comando para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Par�metro de entrada: R0 - Comando a ser enviado
; Par�metro de sa�da: N�o tem
LCD_SendCommand
	PUSH{LR}
	
    ;Colocar o comando nos pinos de dados do LCD
	BL PortK_Output
	
	; Configurar RS (Register Select) para 0 (comando) e RW (Read/Write) para 0 (escrita)
    MOV R1, #2_00000000
	
    ; E (Enable) para 1 (ativa��o do comando)
	ORR R0, R1, #2_00000100
	BL PortM_Output
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output
	
	BL Delay_40us

    POP{LR}
    BX LR


; Fun��o LCD_SendData
; Rotina para enviar um dado para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Par�metro de entrada: R0 - Comando a ser enviado
; Par�metro de sa�da: N�o tem
LCD_SendData
	PUSH{LR}
	
    ;Colocar o comando nos pinos de dados do LCD
	BL PortK_Output
	mov r0, #200
	BL SysTick_Wait1ms
	; Configurar RS (Register Select) para 1 (Dado) e RW (Read/Write) para 0 (escrita)
    MOV R1, #2_00000001
	
    ; E (Enable) para 1 (ativa��o do comando)
	ORR R0, R1, #2_00000100
	BL PortM_Output
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output
	
	BL Delay_40us
	add r11, #1
    POP{LR}
    BX LR

; Fun��o Cofre_Aberto
; Rotina que envia a mensagem "COFRE ABERTO" para o LCD se o cofre estiver aberto
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
Cofre_Aberto
	PUSH{LR}
	
	LDR R5, =init_string
	BL STRING_TO_LCD
	
	POP{LR}
	
	BX LR
	

; Fun��o STRING_TO_LCD
; Rotina para enviar uma string para o LCD
; Par�metro de entrada: R5 - o r�tulo contendo a mensagem a ser enviada
; Par�metro de sa�da: N�o tem
STRING_TO_LCD
	PUSH{LR}
	mov r6, #0
iterateLoop
	b test_end_line

continue_sendData
	ldrb r0, [r5, r6]  
	cmp r0, #0         
	beq end_word       
	bl  LCD_SendData
	bl Delay_40us
	add r6, #1
	b iterateLoop

test_end_line
	cmp r11, #0x10
	beq atualiza_modo
	b continue_sendData

atualiza_modo
	movs r0, #0x07
	bl LCD_SendCommand
	bl Delay_40us
	
	mov r10, #2
	b continue_sendData
	
end_word
	movs r0, #0x18
	bl LCD_SendCommand
	bl Delay_40us
	movs r0, #200
	bl SysTick_Wait1ms
	b end_word
	POP{LR}
	BX LR

; Fun��o Delay_10us
; Rotina de atraso de aproximadamente 10 microssegundos
; Pode variar dependendo da frequ�ncia do clock do sistema
; � utilizado temporizador systickwait para criar o atraso
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
Delay_10us
	PUSH{LR}
    
	MOV R0, #0x320  ; 800 ciclos de clock
	BL SysTick_Wait
	
    POP{LR}
    BX LR

; Fun��o Delay_40us
; Rotina de atraso de aproximadamente 40 microssegundos
; Pode variar dependendo da frequ�ncia do clock do sistema
; � utilizado temporizador systickwait para criar o atraso
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
Delay_40us
	PUSH{LR}

	MOV R0, #0xc80  ; 3200 ciclos de clock
	BL SysTick_Wait
	
    POP{LR}
    BX LR

; Fun��o Delay_1640us
; Rotina de atraso de aproximadamente 1640 microssegundos
; Pode variar dependendo da frequ�ncia do clock do sistema
; � utilizado temporizador systickwait para criar o atraso
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
Delay_1640us
	PUSH{LR}
	MOV r1, #41 ;esperar 40us 41 vezes
delay_loop
	
	BL Delay_40us
	SUBS r1, r1, #1
	BNE delay_loop

    POP{LR}
    BX LR

Delay_1s

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
