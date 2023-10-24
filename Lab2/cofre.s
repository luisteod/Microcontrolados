; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
ENDERECO_BASE_SENHA EQU 0x20000400
ENDERECO_SENHA_INSERIDA EQU 0x20000425
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
		IMPORT PortM_Output_Display		; Permite chamar PortM_Output de outro arquivo
		IMPORT PortL_Input          ; Permite chamar PortL_Input de outro arquivo
		IMPORT varredura
		
;“Cofre aberto, digite nova senha para fechar o cofre”.
cofre_aberto = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x61, 0x62, 0x65, 0x72, 0x74, 0x6F, 0x00; 0x2C, 0x20, 0x64, 0x69, 0x67, 0x69, 0x74, 0x65, 0x20, 0x6E, 0x6F, 0x76, 0x61, 0x20, 0x73, 0x65, 0x6E, 0x68, 0x61, 0x20, 0x00

;"Cofre fechando..."
cofre_fechando = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x66, 0x65, 0x63, 0x68, 0x61, 0x6E, 0x64, 0x6F, 0x00

;"Cofre fechado!"
cofre_fechado = 0x43, 0x6F, 0x66, 0x72, 0x65, 0x20, 0x66, 0x65, 0x63, 0x68, 0x61, 0x64, 0x6F, 0x21, 0x00


;"Senha:"
senha = 0x53, 0x65, 0x6E, 0x68, 0x61, 0x3A, 0x00

;"Mestra:"
mestra = 0x4d, 0x65, 0x73, 0x74, 0x72, 0x61, 0x3a, 0x00
;estados do cofre -> R9
;0x0 = aberto
;0x1 = fechando
;0x2 = fechado

;estados do LCD -> R8
;0x0 = parado
;0x1 = correndo

;digito_atual_senha -> R6
;0x0, 0x1, 0x2, 0x3


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                 ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init
	BL GPIO_Init                ;Chama a subrotina que inicializa os GPIO
	BL LCD_Init
	mov r10, #0x0
	mov r9, #0x0
	mov r8, #0x0
	B MainLoop
	
LCD_Init
	push{lr}
    movs r0, #0x38      
    bl  LCD_SendCommand
	bl Delay_40us

    movs r0, #0x0D      ; Display ON/OFF Control (Display on, Cursor off, Blinking off)
    bl  LCD_SendCommand
	bl Delay_40us
	
	movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand
	bl Delay_1640us

    movs r0, #0x06    ; Entry Mode Set (Increment cursor, no display shift)
    bl  LCD_SendCommand
	bl Delay_40us
	
	BL LCD_Update_linha1
	BL LCD_Update_linha2
	pop{lr}
	bx lr

MainLoop
	cmp r9, #0x0
	beq aberto
	
	bl varredura
	cmp r0, #0x0
	beq MainLoop
	
	cmp r0, #0x23
	bleq confere_senha
	
	bl armazena_senha_conf
	mov r0, #'*'
	bl LCD_SendData
	mov r0, #1000
	bl SysTick_Wait1ms
	B MainLoop
	
aberto
	BL varredura
	cmp r0, #0x0
	beq MainLoop
	
	cmp r0, #0x23
	beq salva_senha
	
	bl armazena_senha_temp
	mov r0, #'*'
	bl LCD_SendData
	mov r0, #1000
	bl SysTick_Wait1ms
	B MainLoop

; Função LCD_Update_linha1
; Rotina para enviar um comando para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Parâmetro de entrada: R0 - Comando a ser enviado
; Parâmetro de saída: Não tem
LCD_Update_linha1
	push{lr}

	mov r0, #0x80
	bl  LCD_SendCommand
	bl Delay_40us
	; ve se o letreiro esta em modo parado
	cmp r9, #0x0
	beq Cofre_Aberto
	
	cmp r9,#0x1
	beq Cofre_Fechado
	
	b Cofre_Fechando

Cofre_Aberto
	LDR R5, =cofre_aberto
	BL STRING_TO_LCD
	B continue_l1

Cofre_Fechando
	LDR R5, =cofre_fechando
	BL STRING_TO_LCD
	mov r0, #5000
	bl SysTick_Wait1ms
	movs r0, #0x01      ; Clear Display
    bl  LCD_SendCommand
	bl Delay_1640us

Cofre_Fechado
	LDR R5, =cofre_fechado
	BL STRING_TO_LCD
	

continue_l1
	pop{lr}
	bx lr
  
; Função LCD_Update_linha2
; Rotina para enviar um comando para o LCD, utiliza os pinos de controle M2-ENABLE, M1-RW, M0-RS
; Parâmetro de entrada: R0 - Comando a ser enviado
; Parâmetro de saída: Não tem
LCD_Update_linha2
	push{lr}
	mov r0, #0xc0
    bl  LCD_SendCommand
	bl Delay_40us

	LDR R5, =senha
	BL STRING_TO_LCD
	
	pop{lr}
	bx lr

armazena_senha_conf
	push{lr}
	cmp r10, #0x4
	beq reinicia
	ldr r1, =ENDERECO_BASE_SENHA
	strb r0, [r1,r10]
	add r10, #1
	b volta
	
;funcao armazena_senha
armazena_senha_temp
	push{lr}
	cmp r10, #0x4
	beq reinicia
	ldr r2, =ENDERECO_SENHA_INSERIDA
	strb r0, [r2, r10]
	add r10, #1

volta
	pop{lr}
	bx lr
	
reinicia
	BL LCD_Init
	mov r10, #0x1
	b volta
;entrada

salva_senha
	push{lr}
	mov r2, #0x0
	mov r9, #0x2
	mov r10, #0x0
	ldr r1, =ENDERECO_BASE_SENHA
	STRB r2,[r1, #0x0]
	strb r2,[r1, #0x1]
	strb r2,[r1, #0x2]
	strb r2,[r1, #0x3]
	BL LCD_Init
	pop{lr}
	bx lr


confere_senha
	push{lr}

	ldr r1, =ENDERECO_BASE_SENHA
	ldr r2, =ENDERECO_SENHA_INSERIDA
	
	ldrb r3,[r1, #0x0]
	ldrb r4,[r2, #0x0]
	cmp r3, r4
	bne senha_invalida
	
	ldrb r3,[r1, #0x1]
	ldrb r4,[r2, #0x1]
	cmp r3, r4
	bne senha_invalida
	
	ldrb r3,[r1, #0x2]
	ldrb r4,[r2, #0x2]
	cmp r3, r4
	bne senha_invalida
	
	ldrb r3,[r1, #0x3]
	ldrb r4,[r2, #0x3]
	cmp r3, r4
	bne senha_invalida
	
	mov r9, #0x0
	BL LCD_Init
	mov r10, #0x0
	pop{lr}
	bx lr

senha_invalida
	push{lr}
	nop
	pop{lr}
	bx lr
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
	BL PortM_Output_Display
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output_Display
	
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
	BL PortM_Output_Display
    
    ; Atraso pequeno (10us) para permitir que o comando seja processado
	BL Delay_10us
	
    ; Desativar E (Enable)
	AND R0, R1, #2_11111011
	BL PortM_Output_Display
	
	BL Delay_40us
	add r11, #1
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
	bl Delay_40us
	add r6, #1
	b iterateLoop


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