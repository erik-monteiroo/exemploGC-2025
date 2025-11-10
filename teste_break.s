.text

#	 nome COMPLETO e matricula dos componentes do grupo...
#

.GLOBL _start


_start:
	PUSHL $0
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _sum
	POPL %EDX
	PUSHL $0
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _i
	POPL %EDX
rot_01:
	PUSHL _i
	PUSHL $10
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETL  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_02
	JMP rot_04
rot_03:
	PUSHL _i
	PUSHL $1
	POPL %EBX
	POPL %EAX
	ADDL %EBX, %EAX
	PUSHL %EAX
	POPL %EDX
	MOVL %EDX, _i
	PUSHL %EDX
	POPL %EDX
	JMP rot_01
rot_04:
	PUSHL _sum
	PUSHL _i
	POPL %EBX
	POPL %EAX
	ADDL %EBX, %EAX
	PUSHL %EAX
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _sum
	POPL %EDX
	PUSHL _i
	PUSHL $4
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETE  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_05
	JMP rot_06
		# terminou o bloco...
	JMP rot_06
rot_05:
rot_06:
		# terminou o bloco...
	JMP rot_03
rot_02:
	MOVL $_str_0Len, %EDX
	MOVL $_str_0, %ECX
	CALL _writeLit
	PUSHL _i
	POPL %EAX
	CALL _write
	CALL _writeln
	MOVL $_str_1Len, %EDX
	MOVL $_str_1, %ECX
	CALL _writeLit
	PUSHL _sum
	POPL %EAX
	CALL _write
	CALL _writeln
	PUSHL $5
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _j
	POPL %EDX
rot_07:
	PUSHL _j
	PUSHL $0
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETG  %AL
	PUSHL %EAX
	POPL %EAX   # desvia se falso...
	CMPL $0, %EAX
	JE rot_08
	MOVL $_str_2Len, %EDX
	MOVL $_str_2, %ECX
	CALL _writeLit
	PUSHL _j
	POPL %EAX
	CALL _write
	CALL _writeln
	PUSHL _j
	PUSHL $2
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETE  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_10
	JMP rot_11
		# terminou o bloco...
	JMP rot_11
rot_10:
rot_11:
	PUSHL _j
	PUSHL $1
	POPL %EBX
	POPL %EAX
	SUBL %EBX, %EAX
	PUSHL %EAX
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _j
	POPL %EDX
		# terminou o bloco...
rot_09:
	JMP rot_07   # terminou cmd na linha de cima
rot_08:
	MOVL $_str_3Len, %EDX
	MOVL $_str_3, %ECX
	CALL _writeLit
	PUSHL _j
	POPL %EAX
	CALL _write
	CALL _writeln
	PUSHL $0
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _k
	POPL %EDX
rot_12:
	MOVL $_str_4Len, %EDX
	MOVL $_str_4, %ECX
	CALL _writeLit
	PUSHL _k
	POPL %EAX
	CALL _write
	CALL _writeln
	PUSHL _k
	PUSHL $2
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETE  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_15
	JMP rot_16
		# terminou o bloco...
	JMP rot_16
rot_15:
rot_16:
	PUSHL _k
	PUSHL $1
	POPL %EBX
	POPL %EAX
	ADDL %EBX, %EAX
	PUSHL %EAX
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _k
	POPL %EDX
		# terminou o bloco...
rot_14:
	PUSHL _k
	PUSHL $5
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETL  %AL
	PUSHL %EAX
	POPL %EAX    # desvia se falso...
	CMPL $0, %EAX
	JNE rot_12
rot_13:
	MOVL $_str_5Len, %EDX
	MOVL $_str_5, %ECX
	CALL _writeLit
	PUSHL _k
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
_i:	.zero 4
_j:	.zero 4
_k:	.zero 4
_sum:	.zero 4

#
# area de literais
#
__msg:
	.zero 30
__fim_msg:
	.byte 0


_str_0:
	 .ascii "apos for, i = "
_str_0Len = . - _str_0
_str_1:
	 .ascii "apos for, sum = "
_str_1Len = . - _str_1
_str_2:
	 .ascii "while j = "
_str_2Len = . - _str_2
_str_3:
	 .ascii "apos while, j = "
_str_3Len = . - _str_3
_str_4:
	 .ascii "do k = "
_str_4Len = . - _str_4
_str_5:
	 .ascii "apos do-while, k = "
_str_5Len = . - _str_5
