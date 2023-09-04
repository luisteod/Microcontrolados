; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
LettersBegin EQU 0x20000400
LettersEnd EQU 0x20000419
Result EQU 0x20000500

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
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
		

; -------------------------------------------------------------------------------
; Fun��o main()
Start  
; Comece o c�digo aqui <======================================================

	;MOV R0, #65
	;MOV R1, #0x1B001B00
	;;Salvar no registrador R2 o valor 0x1234.5678
	;MOV R2, #0x5678
	;MOVT R2, #0x1234
	;;Guardar na posi��o de mem�ria 0x2000.0040 o valor de R0
	;LDR R8, =0x20000040
	;STR R0, [R8]
	;;Guardar na posi��o de mem�ria 0x2000.0044 o valor de R1
	;LDR R8, =0x20000044
	;STR R1, [R8]
	;;Guardar na posi��o de mem�ria 0x2000.0048 o valor de R2
	;ADD R8,	#4
	;STR R2, [R8]
	;;Guardar na posi��o de mem�ria 0x2000.004C o n�mero 0xF0001
	;ADD R8,	#4
	;LDR R9, =0xF0001
	;STR R9, [R8]
	;;Guardar na posi��o de mem�ria 0x2000.0046 o byte 0xCD, sem sobrescrever os outros bytes da WORD
    ;;Ler o conte�do da mem�ria cuja posi��o 0x2000.0040 e guardar no R7
	;;Ler o conte�do da mem�ria cuja posi��o 0x2000.0048 o guardar R8
    ;;Copiar para o R9 o conte�do de R7.
	
	;;a) Realizar a opera��o l�gica AND do valor 0xF0 com o valor bin�rio
	;;01010101 e salvar o resultado em R0. Utilizar o sufixo �S� para atualizar os
	;;flags.
	;MOV R0, #0xF0
	;ANDS R0, R0, #2_01010101
	;;b) Realizar a opera��o l�gica AND do valor 11001100 bin�rio com o valor
	;;bin�rio 00110011 e salvar o resultado em R1. Utilizar o sufixo �S� para atualizar
	;;os flags.
	;MOV R0, #2_11001100
	;ANDS R1,R0, #2_00110011
	;;c) Realizar a opera��o l�gica OR do valor 10000000 bin�rio com o valor
	;;bin�rio 00110111 e salvar o resultado em R2. Utilizar o sufixo �S� para atualizar
	;;os flags.
	;;d) Realizar a opera��o l�gica AND do valor 0xABCDABCD com o valor
	;;0xFFFF0000 (sem usar LDR) e salvar o resultado em R3. Utilizar o sufixo �S�
	;;para atualizar os flags. Utilizar a instru��o BIC.
	
	
	;;a) Realizar o deslocamento l�gico em 5 bits do n�mero 701 para a direita com o flag �S�;
	;MOV R0, #701
	;LSRS R0, R0, #5
	;;b) Realizar o deslocamento l�gico em 4 bits do n�mero -32067 para a direita com o flag
	;;�S�; (Usar o MOV para o n�mero positivo e depois NEG para negativar)
	;MOV R0, #32067
	;NEG R0, R0
	;LSRS R0, R0, #4
	;;c) Realizar o deslocamento aritm�tico em 3 bits do n�mero 701 para a direita com o flag
	;;�S�;
	;MOV R0,	#701
	;ASRS R0, R0, #3
	;;d) Realizar o deslocamento aritm�tico em 5 bits do n�mero -32067 para a direita com o
	;;flag �S�;
	;;e) Realizar o deslocamento l�gico em 8 bits do n�mero 255 para a esquerda com o flag
	;;�S�;
	;;f) Realizar o deslocamento l�gico em 18 bits do n�mero -58982 para a esquerda com o
	;;flag �S�;
	;;g) Rotacionar em 10 bits o n�mero 0xFABC1234;
	;;h) Rotacionar em 2 bits com o carry o n�mero 0x00004321; (Realizar duas vezes)



	;;a) Adicionar os n�meros 101 e 253 atualizando os flags;
	;MOV R0,#101
	;ADDS  R1,R0,#253
	;;b) Adicionar os n�meros 1500 e 40543 sem atualizar os flags;
	;;c) Subtrair o n�mero 340 pelo n�mero 123 atualizando os flags;
	;;d) Subtrair o n�mero 1000 pelo n�mero 2000 atualizando os flags;
	;;e) Multiplicar o n�mero 54378 por 4; (Essa opera��o � semelhante a qual?)
	;;f) Multiplicar com o resultado em 64 bits os n�meros 0x11223344 e 0x44332211
	;;g) Dividir o n�mero 0xFFFF7560 por 1000 com sinal;
	;;h) Dividir o n�mero 0xFFFF7560 por 1000 sem sinal;
	;	
	;;a) Mova o valor 10 para o registrador R0
	;MOV R0, #10
	;;b) Teste se o registrador � maior ou igual que 9
	;CMP R0,  #9
	;;c) Crie um bloco com If-Then com 3 execu��es condicionais
	;;	- Se sim, salve o n�mero 50 no R1
	;;	- Se sim, adicione 32 com o R1 e salve o resultado em R2
	;;	- Se n�o, salve o n�mero 75 no R3
	;ITTE HS
	;	MOVHS R1, #50
	;	ADDHS R2, R1, #32
	;	MOVLO R3,#75
	;			
	;;d) Agora verifique se o registrador � maior ou igual a 11 e execute novamente o passo

	;cmp r0, #11

	;itte hs
	;	movhs r1, #50
	;	addhs r2,r1, #32
	;	movlo r3,#75
	;	
	;;a) Mover o valor 10 para o registrador R0
	;MOV R0, #10
	;;b) Mover o valor 0xFF11CC22 para o registrador R1
	;LDR R1, =0xFF11CC22
	;;c) Mover o valor 1234 para o registrador R2
	;MOV R2, #1234
	;;d) Mover o valor 0x300 para o registrador R3
	;MOV R3, #0x300
	;;e) Empurrar para a pilha o R0
	;PUSH {R0}
	;;f) Empurrar para a pilha os R1, R2 e R3
	;PUSH {R3,R2,R1}
	;;g) Visualizar a pilha na mem�ria (o topo da pilha est� em 0x2000.0400)
	;;VISUALIZAMOS
	;;h) Mover o valor 60 para o registrador R1
	;MOV R1, #60
	;;i) Mover o valor 0x1234 para o registrador R2
	;MOV R2, #0x1234
	;;j) Desempilhar corretamente os valores para os registradores R0, R1, R2 e R3

	;	
	;;a) Mover para o R0 o valor 10
	;MOV R0, #10
	;;b) Somar R0 com 5 e colocar o resultado em R0
	;pula
	;ADD R0, R0, #5
	;;c) Enquanto a resposta n�o for 50 somar mais 5
	;CMP R0, #50
	;BLT pula

	;CMP R0, #50
	;BLEQ func
	;B nao_func


	;;d) Quando a resposta for 50 chamar uma fun��o que:
	;func
	;;d.1) Copia o R0 para R1
	;MOV R1, R0
	;;d.2) Verifica se R1 � menor que 50
	;CMP R1, #50
	;;d.3) Se for menor que 50 incrementa, caso contr�rio modifica para -50
	;ITE LT
	;	ADDLT R1, #1
	;	MOVGE R1, #50
	;	NEG R1, R1
	;BX LR
	;;e) Depois que retornar da fun��o coloque uma instru��o NOP
	;nao_func
	;NOP
	;;f) Acrescente uma instru��o para ficar travado na �ltima linha de execu��o.
	;	
	;NOP
	
	

	
	LDR R0, =STRING1

next_char
	LDRB R1,[R0]
	
	CMP R1,#0
	BEQ fim
	
	MOV R2, #0x41
compare
	CMP R1, R2
	BEQ count
	ADD R2,#1
	CMP R2,#0x5B	
	BMI compare	;Equanto n�o acabar o alfabeto, compare
	
	ADD R0, #1	;Endere�o do pr�x byte
	B next_char
	
count
	
fim
	NOP
	
STRING1 DCB "PARATUDO", 0	
    ALIGN                           ; garante que o fim da se��o est� alinhada 
	
    END                             ; fim do arquivo
