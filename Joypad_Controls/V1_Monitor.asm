	;mov	r0,#userram		;Address
	;mov r1,#2				;Lines
	;bl MemDump
MemDump:				
	STMFD sp!,{r0-r12, lr}
		mov r4,r0
		

		mov r0,r4
		bl ShowHex32
		mov r0,#58 ; :
		bl PrintChar
		bl NewLine

MemDumpNextLine:
		mov r3,#0
MemDumpAgain:			
		ldrb r0,[r4,r3]
		bl ShowHex
		
		mov r0,#32 ; space
		bl PrintChar
		
		add r3,r3,#1
		cmp r3,#MonitorWidth
		bne MemDumpAgain
		
		mov r3,#0
MemDumpAgainB:
		mov r0,#0
		ldrb r0,[r4,r3]
		bl PrintCharSafe
		add r3,r3,#1
		cmp r3,#MonitorWidth
		bne MemDumpAgainB
		add r4,r4,r3
		bl NewLine
		
		subs r1,r1,#1
		bne MemDumpNextLine
		
	LDMFD sp!,{r0-r12, pc}		
PrintCharSafe:
	STMFD sp!,{r0-r12, lr}
		cmp r0,#32
		movlt r0,#46 ;'.'
		cmp r0,#128
		movgt r0,#46 ;'.'
		
		bl printchar
	LDMFD sp!,{r0-r12, pc}		
	
	
Monitor:
	STMFD sp!,{r0-r15}
	mov r5,sp
	
	
	mov r3,#0 ; 0
	mov r4,#0
NextReg:
	bl ShowReg				;1st column
	
	mov r0,#32
	bl PrintChar
	.ifndef BuildROS
		add r4,r4,#8*4		;2nd column
		add r3,r3,#8
		bl ShowReg
		
		sub r4,r4,#8*4
		sub r3,r3,#8
		
		bl NewLine
		add r4,r4,#4
		add r3,r3,#1
		cmp r3,#8
		bne NextReg
	.else
		add r4,r4,#5*4		;2nd column
		add r3,r3,#5
		bl ShowReg
		
		mov r0,#32
		bl PrintChar
		
		add r4,r4,#5*4
		add r3,r3,#5
		bl ShowReg
		
		sub r4,r4,#10*4		;3rd column
		sub r3,r3,#10
		
		bl NewLine
		add r4,r4,#4
		add r3,r3,#1
		cmp r3,#5
		bne NextReg
		
		add r4,r4,#10*4		;Last reg
		add r3,r3,#10
		bl ShowReg
		bl NewLine
	.endif
	LDMFD sp!,{r0-r14}
	add sp,sp,#4
	mov pc,lr
	
	
	
ShowRegLR:		
		mov r0,#76 ; L
		bl PrintChar
		
		mov r0,#82 ; R
		bl PrintChar
	b ShowRegB

	
ShowRegSP:		
		mov r0,#83 ; S
		bl PrintChar
		
		mov r0,#80 ; P
		bl PrintChar
	b ShowRegB
	
ShowRegPC:		
		mov r0,#80 ; P
		bl PrintChar
		
		mov r0,#67 ; C
		bl PrintChar	
	b ShowRegB
	
ShowReg:					;ShowReg R3
	STMFD sp!,{r0-r12, lr}
		cmp r3,#15
		beq ShowRegPC
		
		cmp r3,#14
		beq ShowRegLR
		cmp r3,#13
		beq ShowRegSP
		
		
		mov r0,#82 ; D
		bl PrintChar
		
		mov r2,r3 ; 0
		bl ShowHexChar
ShowRegB:		
		mov r0,#58 ; :
		bl PrintChar
		
		ldr r0,[r5,r4]
		bl ShowHex32
	LDMFD sp!,{r0-r12, pc}		
ShowHex32:
	STMFD sp!,{r0-r12, lr}
		mov r2,r0,ror #28
		bl ShowHexChar	
		mov r2,r0,ror #24
		bl ShowHexChar	
		mov r2,r0,ror #20
		bl ShowHexChar	
		mov r2,r0,ror #16
		bl ShowHexChar	
		mov r2,r0,ror #12
		bl ShowHexChar	
		mov r2,r0,ror #8
		bl ShowHexChar	
		mov r2,r0,ror #4
		bl ShowHexChar	
		mov r2,r0
		bl ShowHexChar	
	LDMFD sp!,{r0-r12, pc}		
ShowHex:
	STMFD sp!,{r0-r12, lr}
		mov r2,r0,ror #4
		bl ShowHexChar	
		mov r2,r0
		bl ShowHexChar	
	LDMFD sp!,{r0-r12, pc}		
	
ShowHexChar:
	STMFD sp!,{r0-r12, lr}
		;mov r3,
		and r0,r2,#0x0F ; r3
		cmp r0,#10
		addge r0,r0,#7
		add r0,r0,#48
		bl PrintChar	
	LDMFD sp!,{r0-r12, pc}	
	