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
	PUSHL _i
	PUSHL $5
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETE  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_05
	JMP rot_07
		# terminou o bloco...
	JMP rot_06
rot_05:
rot_06:
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
	PUSHL _sum
	PUSHL $25
	POPL %EAX
	POPL %EDX
	CMPL %EAX, %EDX
	MOVL $0, %EAX
	SETG  %AL
	PUSHL %EAX
	POPL %EAX
	CMPL $0, %EAX
	JE rot_07
	JMP rot_08
		# terminou o bloco...
	JMP rot_08
rot_07:
rot_08:
		# terminou o bloco...
	JMP rot_03
rot_02:
	MOVL $_str_0Len, %EDX
	MOVL $_str_0, %ECX
	CALL _writeLit
	PUSHL _sum
	POPL %EAX
	CALL _write
	CALL _writeln
	PUSHL $4
	POPL %EDX
	PUSHL %EDX
	MOVL %EDX, _j
	POPL %EDX
rot_09:
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
	JE rot_10
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
	JE rot_12
	JMP rot_14
		# terminou o bloco...
