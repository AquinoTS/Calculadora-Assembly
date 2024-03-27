TITLE Julia Duran, Thayná Aquino. RA_22009210, RA_22002057

.MODEL SMALL
.DATA 
    SB DB 10,'     SEJA BEM VINDO AO PROGRAMA!!!!!     ',10,'$'
    OP db 10,'  Escolha qual operacao desejada *,/,+,-: ','$'
    msg1 db 10,'  Entre com o primeiro num (entre 0 e 9): ','$'
    msg2 db 10,'  Entre com o segundo num (entre 0 e 9): ','$'
    resultado  db 10, '  O resultado: ','$'
    DESEJA DB 10,'  Deseja reiniciar o programa? (se sim digite s): ','$'
    IMP DB 10,'  Conta impossivel dividendo igual a ZERO!',10,'$'
    resultado_quoci db 10,'  O quociente eh: ','$'
    resultado_rest db 10,'  O resto eh: ','$'
    operacao_N db 10,13,'  Operacao escolhida nao eh valida.',10,'$'

.CODE
main proc
    MOV AX,@DATA    ;Iniciando a data
    MOV DS,AX

    MOV AX,03
    INT 10H     ;Comando para a limpeza do terminal visualmente.

    LEA DX,SB   ;imprime mensagem para recebimento do usuario
    CALL impressao_s

INICIO:     ;Caso deseje voltar do inicio.
    XOR AX,AX   ;zera registradores para iniciar programa
    XOR BX,BX
    XOR CX,CX

    MOV AH,02   ;pula linha
    MOV DL,10
    INT 21H

ERRO:
;Recebendo os numeros e imprimindo a mensagem para o usuario.
    LEA DX,msg1
    CALL COLLHE_INFO
    SUB AL,30H
    MOV BL,AL

    LEA DX,OP
    CALL COLLHE_INFO
    MOV CL,AL

;Recebendo os numeros e imprimindo a mensagem para o usuario.
    LEA DX,msg2
    CALL COLLHE_INFO
    SUB AL,30H
; Comparacoes para saber qual operacao fazer.
    CMP CL,43
    JZ SOMA
    CMP CL,45
    JZ SUBT
    CMP CL,42
    JZ MULTI
    CMP CL,47
    JZ DIVI

;caso a operacao escolhida nao exista o programa volta
    LEA DX,operacao_N
    CALL impressao_S
    jmp ERRO

SOMA: ADD BL,AL ;Soma.
    
    JMP IMPRIME1

SUBT:   ;Subtracao.
    NEG AL
    ADD BL,AL

    JNC IMPRIME2
    JC IMPRIME1

MULTI: CALL MULTIPLICA   ;Chama a funcao que faz a multiplicacao.
       JMP IMPRIME1


DIVI:   CMP AL, 00H   ;Chama a funcao que faz a divisao.
        JZ IMPOSSIVEL
        CALL divis
        JMP IMPRIME3
        
IMPOSSIVEL: LEA DX,IMP      ;Bloco de salto criado com o intuito de indicar quando a operacao é impossivel.
            CALL impressao_s
            JMP SAI

IMPRIME3: CALL IMPRIME_DV   ;imprime resulatados da divisao
            JMP SAI

IMPRIME1: CALL IMPRIME  
            JMP SAI

IMPRIME2: CALL IMPRIME_NEG      ;imprime numeros negativos
            JMP SAI
SAI:
    LEA DX,DESEJA   ;Reiniciar o programa.
    CALL COLLHE_INFO
    CMP AL,'s'
    JNE FIM
    JMP INICIO
FIM:
    MOV AH,4CH 
    INT 21H
MAIN ENDP

IMPRIME proc
;Passa o numero para AL, zera o excesso, divide por 10 e imprime separado cada digito.
    LEA DX,resultado
    MOV AH,09H
    INT 21H

    MOV AL,BL
    XOR AH,AH
    MOV BL,10
    DIV BL      ;separa dezena da unidade

    MOV BX,AX
    MOV DL,BL   ;imprime o quociente (dezena)
    OR DL,30H   ;Transforma o numero em digito novamente.
    MOV AH,02
    INT 21H

    MOV DL,BH      ;imprime o resto da div (unidade)
    OR DL,30H    ;Transforma o numero em digito novamente.
    INT 21H
    
    RET
IMPRIME ENDP

IMPRIME_NEG proc
;Impressao para numeros negativos.
;Passa o numero para AL, zera o excesso, divide por 10 e imprime separado.
    LEA DX,resultado
    MOV AH,09H
    INT 21H
    MOV DL,45   ;Impressao do sinal de menos.
    MOV AH,02
    INT 21H
    NEG BL      ;Nega novamente o numero para impressao correta.
    MOV AL,BL   
    XOR AH,AH   ;passa tudo para ax para q o comando div funcione 
    MOV BL,10
    DIV BL
    MOV BX,AX
    MOV DL,BL   ;imprime o quociente (dezena)
    OR DL,30H   ;Transforma numero em digito novamente.
    MOV AH,02
    INT 21H

    MOV DL,BH   ;imprime o resto da div (unidade)
    OR DL,30H    
    INT 21H

    RET

IMPRIME_NEG ENDP

COLLHE_INFO proc
    MOV AH,09H  ;Funcao para colher as informacoes que o usuario inserir.
    INT 21H
    MOV AH,01H
    INT 21H

    RET
COLLHE_INFO ENDP

MULTIPLICA proc
    XOR CL,CL   ;Zera CL para receber o resultado.
    VOLTA:
    TEST BL,01H    ;Verifica se o ultimo digito eh 1 ou 0.
    JZ PULA
    ADD CL,AL
    PULA:
    SHL AL,1
    SHR BL,1   ;Desloca o multiplicando e o multiplicador em direcao opostas para que todos
    JNZ VOLTA  ;os digitos sejam multiplicados.
    MOV BL,CL

    RET
MULTIPLICA ENDP

IMPRIME_DV proc
;Impressao expecifica para a divisao.
    LEA DX,resultado_quoci
    MOV AH,09H
    INT 21H
    MOV DL,CL
    OR DL,30H   ;Transforma num em digito novamente.
    MOV AH,02
    INT 21H
    LEA DX,resultado_rest
    MOV AH,09H
    INT 21H
    MOV DL,BL
    OR DL,30H   ;Transforma num em digito novamente.
    MOV AH,02
    INT 21H

    RET
IMPRIME_DV ENDP

divis proc
        MOV CH,5    ; ocorrem 5 repeticoes
        XOR CL,CL   ;Algoritmo que faz a divisao.
        SHL AL,4    
VOLTAD:
        SHL CL,1    ;Deslocando o divisor para a direita e o quociente para a esquerda,
        SUB BL,AL   ;conseguiremos fazer o teste se a subtracao eh possivel ao fazer a sua divisao.
        JS NEGATIVO ;caso o resultado seja negativo retorna '0' caso seja positivo retorna '1', para o quociente
        OR CL,1
        JMP FIMD
NEGATIVO:
        OR CL,0
        ADD BL,AL
FIMD:
        SHR AL,1 
        DEC CH
        CMP CH,0
        JNZ VOLTAD

        RET

divis ENDP

impressao_S proc
;Impressao simples.
        MOV AH,09
        INT 21H
        RET
impressao_S ENDP


END MAIN
