; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
ENDERECO_BASE EQU 0x20000400
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
		IMPORT SysTick_Wait
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		
;“Cofre aberto, digite nova senha para fechar o cofre”.
;
COFRE DCB 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20 , 0x00
ABERTO DCB 0x61, 0x62, 0x65, 0x72, 0x74, 0X6F, 0x00
;
; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
LCD_Init
	PUSH{LR}
    movs r0, #0x38      
    bl  LCD_SendCommand

    movs r0, #0x0C      ; Display ON/OFF Control (Display on, Cursor off, Blinking off)
    bl  LCD_SendCommand

    movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand

    movs r0, #0x06      ; Entry Mode Set (Increment cursor, no display shift)
    bl  LCD_SendCommand

    movs r0, #0x80
    bl  LCD_SendCommand

    BL Cofre_Aberto



MainLoop
	BL LCD_Update
	BL Delay_40us
	B MainLoop
	
LCD_Update
	movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand
	bl Delay_1640us
	
	bl Cofre_Aberto
	
	BX LR

; Função LCD_SendCommand
; Rotina para enviar um comando para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Parâmetro de entrada: R0 - Comando a ser enviado
; Parâmetro de saída: Não tem
LCD_SendCommand
	PUSH{LR}
	
    ;Colocar o comando nos pinos de dados do LCD
	BL PortK_Output
	
	; Configurar RS (Register Select) para 0 (comando) e RW (Read/Write) para 0 (escrita)
    MOV R1, #2_00000000
	
    ; E (Enable) para 1 (ativação do comando)
	ORR R0, R1, #2_00000100
	BL PortM_Output
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output
	
	BL Delay_40us
	BL Delay_40us
	
    POP{LR}
    BX LR


; Função LCD_SendData
; Rotina para enviar um dado para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Parâmetro de entrada: R0 - Comando a ser enviado
; Parâmetro de saída: Não tem
LCD_SendData
	PUSH{LR}
    ;Colocar o comando nos pinos de dados do LCD
	BL PortK_Output
	
	; Configurar RS (Register Select) para 1 (Dado) e RW (Read/Write) para 0 (escrita)
    MOV R1, #2_00000001
	
    ; E (Enable) para 1 (ativação do comando)
	ORR R0, R1, #2_00000100
	BL PortM_Output
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output
	
	BL Delay_40us
	BL Delay_40us
    POP{LR}
    BX LR

; Função Cofre_Aberto
; Rotina que envia a mensagem "COFRE ABERTO" para o LCD se o cofre estiver aberto
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Cofre_Aberto
	PUSH{LR}
	
	LDR R5, =COFRE
	BL STRING_TO_LCD
	POP{LR}
	
	BX LR
	

; Função STRING_TO_LCD
; Rotina para enviar uma string para o LCD
; Parâmetro de entrada: R5 - o rótulo contendo a mensagem a ser enviada
; Parâmetro de saída: Não tem
STRING_TO_LCD
	PUSH{LR}
	mov r6, #0
iterateLoop
	ldrb r0, [r5, r6]  
	cmp r0, #0         
	beq end_word       
	bl  LCD_SendData     
	add r6, #1
	b   iterateLoop

end_word
	POP{LR}
	BX LR















; Função Delay_10us
; Rotina de atraso de aproximadamente 10 microssegundos
; Pode variar dependendo da frequência do clock do sistema
; é utilizado temporizador systickwait para criar o atraso
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Delay_10us
	PUSH{LR}
    
	MOV R0, #0x320  ; 800 ciclos de clock
	BL SysTick_Wait
	
    POP{LR}
    BX LR

; Função Delay_40us
; Rotina de atraso de aproximadamente 40 microssegundos
; Pode variar dependendo da frequência do clock do sistema
; é utilizado temporizador systickwait para criar o atraso
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Delay_40us
	PUSH{LR}

	MOV R0, #0xc80  ; 3200 ciclos de clock
	BL SysTick_Wait
	
    POP{LR}
    BX LR

; Função Delay_1640us
; Rotina de atraso de aproximadamente 1640 microssegundos
; Pode variar dependendo da frequência do clock do sistema
; é utilizado temporizador systickwait para criar o atraso
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Delay_1640us
	PUSH{LR}
	MOV r1, #41 ;esperar 40us 41 vezes
delay_loop
	
	BL Delay_40us
	SUBS r1, r1, #1
	BNE delay_loop

    POP{LR}
    BX LR

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
