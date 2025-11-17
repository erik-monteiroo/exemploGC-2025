.text

#	 nome COMPLETO e matricula dos componentes do grupo...
#

.GLOBL _start


_start:
	PUSHL $10
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _a
	POPL %EDX
	PUSHL $11
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _b
	POPL %EDX
	PUSHL $9
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _c
	POPL %EDX
	PUSHL _a
	PUSHL _b
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETLE %AL
	PUSHL %EAX
	PUSHL _a
	PUSHL _c
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETLE %AL
	PUSHL %EAX
	POPL %EDX
	POPL %EAX
	CMPL $0, %EAX
	MOVL $0, %EAX
	SETNE %AL
	CMPL $0, %EDX
	MOVL $0, %EDX
	SETNE %DL
	ANDL  %EDX, %EAX
	PUSHL %EAX
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _x
	POPL %EDX
	PUSHL _b
	PUSHL _c
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETLE %AL
	PUSHL %EAX
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _y
	POPL %EAX
	CMPL $0, %EAX
	JE rot_01
	PUSHL _b
	JMP rot_02
rot_01:
	PUSHL _c
rot_02:
	POPL %EDX
	MOVL $_str_0Len, %EDX
	MOVL $_str_0, %ECX
	CALL _writeLit
	PUSHL _x
	POPL %EAX
	CALL _write
	CALL _writeln
	MOVL $_str_1Len, %EDX
	MOVL $_str_1, %ECX
	CALL _writeLit
	PUSHL _y
	POPL %EAX
	CALL _write
	CALL _writeln



#
# devolve o controle para o SO (final da main)
#
	mov $0, %ebx
	mov $1, %eax
	int $0x80


#
# Funcoes da biblioteca (IO)
#


_writeln:
	MOVL $__fim_msg, %ECX
	DECL %ECX
	MOVB $10, (%ECX)
	MOVL $1, %EDX
	JMP _writeLit
_write:
	MOVL $__fim_msg, %ECX
	MOVL $0, %EBX
	CMPL $0, %EAX
	JGE _write3
	NEGL %EAX
	MOVL $1, %EBX
_write3:
	PUSHL %EBX
	MOVL $10, %EBX
_divide:
	MOVL $0, %EDX
	IDIVL %EBX
	DECL %ECX
	ADD $48, %DL
	MOVB %DL, (%ECX)
	CMPL $0, %EAX
	JNE _divide
	POPL %EBX
	CMPL $0, %EBX
	JE _print
	DECL %ECX
	MOVB $'-', (%ECX)
_print:
	MOVL $__fim_msg, %EDX
	SUBL %ECX, %EDX
_writeLit:
	MOVL $1, %EBX
	MOVL $4, %EAX
	int $0x80
	RET
_read:
	MOVL $15, %EDX
	MOVL $__msg, %ECX
	MOVL $0, %EBX
	MOVL $3, %EAX
	int $0x80
	MOVL $0, %EAX
	MOVL $0, %EBX
	MOVL $0, %EDX
	MOVL $__msg, %ECX
	CMPB $'-', (%ECX)
	JNE _reading
	INCL %ECX
	INC %BL
_reading:
	MOVB (%ECX), %DL
	CMP $10, %DL
	JE _fimread
	SUB $48, %DL
	IMULL $10, %EAX
	ADDL %EDX, %EAX
	INCL %ECX
	JMP _reading
_fimread:
	CMPB $1, %BL
	JNE _fimread2
	NEGL %EAX
_fimread2:
	RET



#
# area de dados
#
.data
#
# variaveis globais
#
_a:	.zero 4
_b:	.zero 4
_c:	.zero 4
_x:	.zero 4
_y:	.zero 4

#
# area de literais
#
__msg:
	.zero 30
__fim_msg:
	.byte 0


_str_0:
	 .ascii "me = "
_str_0Len = . - _str_0
_str_1:
	 .ascii "ma = "
_str_1Len = . - _str_1
