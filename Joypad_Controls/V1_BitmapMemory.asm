
NewLine:
	STMFD sp!,{r0-r12, lr}
		mov r3,#CursorX
		mov r0,#0
		strB r0,[r3]	;X
		
		mov r3,#CursorY
		ldrB r0,[r3]	;Y
		add r0,r0,#1
		strB r0,[r3]	;Y
	LDMFD sp!,{r0-r12, pc}

	
	
PrintChar:
	STMFD sp!,{r0-r12, lr}
		mov r4,#0
		mov r5,#0
		
		mov r3,#CursorX
		ldrB r4,[r3]	;X
		mov r3,#CursorY
		ldrB r5,[r3]	;Y
		
		mov r3,#0x06000000 ; VRAM
		
		mov r6,#16			;Xpos 
		mul r2,r4,r6
		add r3,r3,r2
		
		mov r4,#240*8*2		;Ypos 
		mul r2,r5,r4
		add r3,r3,r2
		
		adr r4,BitmapFont 	;Font source
		sub r0,r0,#32		;First Char is 32 (Space)
		add r4,r4,r0,asl #3	;8 bytes per char
		
		mov r1,#8			;8 lines 
DrawLine:
		mov r7,#8 			;8 pixels per line
		ldrb r8,[r4],#1		;Load Letter
		mov r9,#0b100000000	;Mask

				;  ABBBBBGGGGGRRRRR	A=Alpha
		mov r2, #0b1111111101000000
		
DrawPixel:
		tst r8,r9			;Is bit 1?
		strneh r2,[r3]		;Yes? then fill pixel
		add r3,r3,#2
		mov r9,r9,ror #1	;Bitshift Mask
		subs r7,r7,#1
		bne DrawPixel		;Next Hpixel
		
		add r3,r3,#480-16	;Move Down a line
		subs r1,r1,#1
		bne DrawLine		;Next Vline
		
		mov r3,#CursorX
		ldrB r0,[r3]	
		add r0,r0,#1		;Move across screen
		strB r0,[r3]	
	LDMFD sp!,{r0-r12, pc}

	
	
	
GetScreenPos: ;R1,R2 = X,Y
	STMFD sp!,{r2}
		STMFD sp!,{r1}
			mov r10,#0x06000000 ; VRAM
			mov r1,#240*2		;Ypos 
			mul r2,r1,r2
		LDMFD sp!,{r1}	
		add r10,r10,r1
	add r10,r10,r2
	LDMFD sp!,{r2}
	MOV pc,lr
	
	

GetNextLine:
	add r10,r10,#240*2			;240 - 2 bytes per pixel
	MOV pc,lr
	
ScreenInit:
;Turn on the screen - ScreenMode 3 - 240x160 16 bit color
	STMFD sp!,{r0-r12, lr}
		mov r4,#0x04000000  	;DISPCNT -LCD Control
		mov r2,#0x403    		;4= Layer 2 on / 3= ScreenMode 3
		str	r2,[r4]         	
	
		bl cls
		
	LDMFD sp!,{r0-r12, pc}
	
SetPalette:					;Not needed for 16bpp
	STMFD sp!,{r0-r12, lr}
		mov r11,#0x05000000  ; palette register address
		add r11,r11,r0,asl #1

		;bl monitor
		mov r2,r1,asl #11				;B
				 ;----GGGGRRRRBBBB
		mov r3,#0b0111100000000000
		and r2,r2,r3
		mov r5,r2
		;bl monitor
		
		mov r2,r1,lsr #3			;R
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000000000011110
		and r2,r2,r3
		orr r5,r5,r2
		;bl monitor
		
		mov r2,r1,lsr #2			;G
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000001111000000
				  
		and r2,r2,r3
		orr r5,r5,r2
		
		strH r5,[r11]	;-BBBBBGGGGGRRRRR
		;b infloop
	LDMFD sp!,{r0-r12, pc}	
	
cls:
	mov r3,#CursorX
	mov r0,#0
	strB r0,[r3]	;X
	mov r3,#CursorY
	strB r0,[r3]	;Y
	

		;Fill the screen	
		mov r0, #0x06000000		;Screen Ram
				;  ABBBBBGGGGGRRRRR	A=Alpha
		mov r1, #0b1000000010001010
		add r1,r1,#0x808A0000
		mov r2, #256*192/2

FillScreenLoop:
		str r1, [r0],#4		;Store+inc 2 bytes
		subs r2, r2, #1		
		bne FillScreenLoop	
	MOV pc,lr