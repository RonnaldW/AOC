org 100h

;Imprime mensagem para o valor de a
mov dx, offset msg1
mov ah, 9
int 21h

;faz a leitura do valor de a
call scan_num
mov [a], cx

;Pula Linha
putc 0Dh
putc 0Ah

;Imprime mensagem para o valor de b
mov dx, offset msg2
mov ah, 9
int 21h

;faz a leitura do valor de b
call scan_num
mov [b], cx

;Pula Linha
putc 0Dh
putc 0Ah

;Imprime mensagem para o valor de c
mov dx, offset msg3
mov ah, 9
int 21h

;faz a leitura do valor de c
call scan_num
mov [c], cx

; Pula Linha
putc 0Dh
putc 0Ah

;Imprime o valor de a
;mov dx, offset msg4
;mov ah, 9
;int 21h
;mov ax, [a]
;call print_num

;Pula Linha
putc 0Dh
putc 0Ah

;Imprime o valor de b
;mov dx, offset msg5
;mov ah, 9
;int 21h
;mov ax, [b]
;call print_num

; Pula Linha
putc 0Dh
putc 0Ah

;Imprime o valor de c
;mov dx, offset msg6
;mov ah, 9
;int 21h
;mov ax, [c]
;call print_num

;Pula Linha
putc 0Dh
putc 0Ah

;a > b / a < b
mov ax, [a]
cmp ax, [b]
jg comp_bc
jl comp_ac

;a <> c
comp_ac:
mov ax, [c]
cmp ax, [a]
jg  soma_bc
jl  soma_ac


;b <> c
comp_bc:
mov ax, [b]
cmp ax, [c]
jg soma_ab
jl soma_ac 


;soma 
soma_ab:
mov ax, [a]
add ax, [b]
mov [soma], ax
jmp fim

;soma 
soma_bc:
mov ax, [b]
add ax, [c]
mov [soma], ax
jmp fim

;soma 
soma_ac:
mov ax, [a]
add ax, [c]
mov [soma], ax
jmp fim


fim:
;Imprime a soma dos valores
mov dx, offset msg4
mov ah, 9
int 21h

;Pula Linha
putc 0Dh
putc 0Ah

;print da soma
mov ax, [soma]
call print_num


ret

msg1 db "Digite o valor de a: $"
msg2 db "Digite o valor de b: $"
msg3 db "Digite o valor de c: $"
msg4 db "A soma dos maiores valores e: $"


; Variaveis
a dw ?
b dw ?
c dw ?
soma dw ?


;;Aproveitando algumas partes e macros que tinham na pratica 2 e 3 do professor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Essas funções são copiadas de emu8086.inc. ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; esta macro imprime um caractere em AL e avança  
; a posição atual do cursor:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

; obtém o número SIGNED de vários dígitos do teclado,  
; e armazena o resultado no registrador CX:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; redefinir flag:
        MOV     CS:make_minus, 0

next_digit:

        ; obtém um caractere do teclado  
        ; e armazena em AL:
        MOV     AH, 00h
        INT     16h
        ; e imprime-o:
        MOV     AH, 0Eh
        INT     10h

        ; verifica o sinal de MENOS:
        CMP     AL, '-'
        JE      set_minus

        ; verifica a tecla ENTER:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressionado?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove o último dígito por
        MOV     AX, CX                  ; divisão:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-resto).
        MOV     CX, AX
        PUTC    ' '                     ; limpar posição.
        PUTC    8                       ; backspace novamente.
        JMP     next_digit
backspace_checked:


        ; permitir apenas dígitos:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; limpar o último caractere não dígito inserido.
        PUTC    8       ; backspace novamente.     
        JMP     next_digit ; aguarde a próxima entrada.      
ok_digit:


        ; multiplica CX por 10 (na primeira vez, o resultado é zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; verifica se o número é grande demais
        ; (o resultado deve ser de 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; converte do código ASCII:
        SUB     AL, 30h

        ; adiciona AL a CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, caso o resultado seja grande demais.
        ADD     CX, AX
        JC      too_big2    ; pula se o número for grande demais.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restaura o valor salvo antes de adicionar.
        MOV     DX, 0       ; DX estava zero antes do backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; inverte o último DX:AX = AX*10, faz AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; limpar o último dígito inserido.
        PUTC    8       ; backspace novamente.     
        JMP     next_digit ; aguarde pelo Enter/Backspace.
        
        
stop_input:
        ; verifica a flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; usado como uma flag.
SCAN_NUM        ENDP

; este procedimento imprime o número em AX,
; usado com PRINT_NUM_UNS para imprimir números assinados:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; verifica o SINAL de AX,
        ; torna absoluto se for negativo:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

; este procedimento imprime um número sem sinal
; em AX (não apenas um único dígito)
; os valores permitidos variam de 0 a 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag para evitar imprimir zeros antes do número:
        MOV     CX, 1

        ; (o resultado de "/ 10000" é sempre menor ou igual a 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX é zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; verifica o divisor (se for zero, vai para end_print):
        CMP     BX,0
        JZ      end_print

        ; evitar imprimir zeros antes do número:
        CMP     CX, 0
        JE      calc
        ; se AX<BX, o resultado da DIV será zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; define a flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=resto).

        ; imprime o último dígito
        ; AH é sempre ZERO, então é ignorado
        ADD     AL, 30h    ; converte para código ASCII.
        PUTC    AL

        MOV     AX, DX  ; obtém o resto da última divisão.

skip:
        ; calcula BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=resto).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP

ten             DW      10      ; usado como multiplicador/divisor por SCAN_NUM & PRINT_NUM_UNS.

