; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
ENDERECO_BASE_SENHA EQU 0x20000400
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
		IMPORT SysTick_Wait1ms
        IMPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		IMPORT PortK_Output			; Permite chamar PortK_Output de outro arquivo
		IMPORT PortM_Output			; Permite chamar PortM_Output de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		
;“Cofre aberto, digite nova senha para fechar o cofre”.
cofre_aberto = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x61, 0x62, 0x65, 0x72, 0x74, 0x6F, 0x2C, 0x20, 0x64, 0x69, 0x67, 0x69, 0x74, 0x65, 0x20, 0x6E, 0x6F, 0x76, 0x61, 0x20, 0x73, 0x65, 0x6E, 0x68, 0x61, 0x20, 0x00

;"Cofre fechando..."
cofre_fechando = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x66, 0x65, 0x63, 0x68, 0x61, 0x6E, 0x64, 0x6F, 0x00

;"Cofre fechado!"
cofre_fechado = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x66, 0x65, 0x63, 0x68, 0x61, 0x64, 0x6F, 0x21, 0x00

;estados do cofre -> R7
;0x0 = aberto
;0x1 = fechando
;0x2 = fechado

;estados do LCD -> R8
;0x0 = parado
;0x1 = correndo


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	
	mov r7, #0x1
	mov r8, #0x0
	mov r10, #1    ;equivale à linha atual
	mov r11, #0 ;equivale à coluna atual da linha
	
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
	
	cmp r7, #0x0
	beq Cofre_Aberto
	
	cmp r7, #0x1
	beq Cofre_Fechando
	
	cmp r7, #0x2
	beq Cofre_Fechado

MainLoop	
	BL LCD_Update
	B MainLoop
	
LCD_Update
	push{lr}
	; ve se o letreiro esta em modo parado
	cmp r8, #0x0
	beq mantem_parado
	
	movs r0, #0x18
	bl LCD_SendCommand
	bl Delay_40us
	movs r0, #200
	bl SysTick_Wait1ms
    
mantem_parado
	pop{lr}
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
	;mov r0, #200
	;BL SysTick_Wait1ms
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
	add r11, #1
    POP{LR}
    BX LR

; Função Cofre_Aberto
; Rotina que envia a mensagem inicial de cofre aberto para o LCD 
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Cofre_Aberto
	LDR R5, =cofre_aberto
	BL STRING_TO_LCD
	B MainLoop
	
; Função Cofre_Fechando
; Rotina que envia a mensagem de cofre fechando para o LCD quando o sistema recebe uma senha
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Cofre_Fechando
	LDR R5, =cofre_fechando
	BL STRING_TO_LCD
	mov r0, #5000
	bl SysTick_Wait1ms
	movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand
	bl Delay_1640us
	mov r11, #0
	b Cofre_Fechado
	
; Função Cofre_Fechado
; Rotina que envia a mensagem de cofre fechado para o LCD
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Cofre_Fechado
	LDR R5, =cofre_fechado
	BL STRING_TO_LCD
	B MainLoop
	
; Função STRING_TO_LCD
; Rotina para enviar uma string para o LCD
; Parâmetro de entrada: R5 - o rótulo contendo a mensagem a ser enviada
; Parâmetro de saída: Não tem
STRING_TO_LCD
	PUSH{LR}
	mov r6, #0
iterateLoop
	b test_end_line

;envia normalmente a informacao contida na string
continue_sendData
	ldrb r0, [r5, r6]  
	cmp r0, #0         
	beq end_word       
	bl  LCD_SendData
	bl Delay_40us
	add r6, #1
	b iterateLoop

;verifica se a linha terminou utilizando um contador auxiliar em r11
test_end_line
	cmp r11, #0x10
	beq atualiza_modo
	b continue_sendData

;quando chega no final da linha, faz com que a mensagem se desloque para a esquerda quando um novo caractere eh inserido
atualiza_modo
	movs r0, #0x07
	movs r8, #0x1
	bl LCD_SendCommand
	bl Delay_40us

;atualiza a flag de linha, para fazer o letreiro correr
	mov r10, #2
	b continue_sendData

;quando a palavra acaba, shifta o display se o LCD esta em modo letreiro, ou mantem ele parado
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

Delay_1s

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
