;Text after semicolon is comments, you don't need to type it in
	.org  0x08000000  		   	;GBA Rom Base
;Header
	b	ProgramStart			;Jump to our program
	.space 178					;Logo (omitted) + Program name
	.byte 0x96					;Fixed value
	.space 49					;Dummy Header 
	
ProgramStart:
	mov sp,#0x03000000			;Init Stack Pointer
	
	mov r4,#0x04000000  		;DISPCNT -LCD Control
	mov r2,#0x403    			;4= Layer 2 on / 3= ScreenMode 3
	str	r2,[r4]         	
	
	mov r8,#10					;Xpos
	mov r9,#10					;Ypos
	
	bl ShowSprite				;Show the sprite starting position
	
InfLoop:
	mov r3,#0x4000130			;Read GBA joypad
	ldrh r0,[r3]		
	            ;------lrDULRSsBA
	and r0,r0,#0b0000000011110000
	cmp r0,#0b0000000011110000
	beq InfLoop
	
	bl ShowSprite				;Remove the old sprite
	         ;------lrDULRSsBA
	tst r0,#0b0000000001000000
	bne JoyNotUp
	cmp.b r9,#0
	beq JoyNotUp
	sub.b r9,r9,#1				;Move Up
JoyNotUp:	
			 ;------lrDULRSsBA
	tst r0,#0b0000000010000000
	bne JoyNotDown
	cmp.b r9,#19
	beq JoyNotDown
	add.b r9,r9,#1				;Move Down
JoyNotDown:	
	         ;------lrDULRSsBA
	tst r0,#0b0000000000100000
	bne JoyNotLeft
	cmp.b r8,#0
	beq JoyNotLeft
	sub.b r8,r8,#1				;Move Left
JoyNotLeft:	
			 ;------lrDULRSsBA
	tst r0,#0b0000000000010000
	bne JoyNotRight
	cmp.b r8,#29
	beq JoyNotRight
	add.b r8,r8,#1				;Move Right
JoyNotRight:	

	bl ShowSprite				;Show the new sprite position

	mov r0,#0x8FFF				;Delay Loop
Delay:	
	subs r0,r0,#1
	bne Delay
	b InfLoop					;Repeat.
	
;Xor Sprite, drawing twice will remove sprite from screen.
ShowSprite:
	mov r10,#0x06000000 		;VRAM base
	
	mov r1,#16					;Sprite is 8px, 2 bytes per pixel
	mul r2,r1,r8
	add r10,r10,r2				;Xpos *16
	
	mov r1,#240*2*8				;240 pixels per line, 2 bytes per pixel
	mul r2,r1,r9
	add r10,r10,r2				;Ypos * 240*8*2
	
	ldr r1,SpriteAddress		;Sprite Address
	mov r6,#8					;Height
Sprite_NextLine:	
	mov r5,#8					;Width (in words / pixels)

	STMFD sp!,{r10}
Sprite_NextByte:
		ldrH r3,[r1],#2			;Must write 16/32bit per VRAM write 
		ldrH r2,[r10]
		eor r3,r3,r2			;Eor Word from screen
		strH r3,[r10],#2
		
		subs r5,r5,#1			;X Loop
		bne Sprite_NextByte
	LDMFD sp!,{r10}		
	add r10,r10,#240*2			;240 - 2 bytes per pixel
	subs r6,r6,#1
	bne Sprite_NextLine			;Y loop
	mov pc,lr
	
SpriteAddress:
	.long SpriteTest			;Address of Sprite
	
SpriteTest: 	;Smiley ( Color bits: ABBBBBGGGGGRRRRR	A=Alpha )
	.word 0x8000,0x8000,0x83FF,0x83FF,0x83FF,0x83FF,0x8000,0x8000 ;  0
	.word 0x8000,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x8000 ;  1
	.word 0x83FF,0x83FF,0x801F,0x83FF,0x83FF,0x801F,0x83FF,0x83FF ;  2
	.word 0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF ;  3
	.word 0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF,0x83FF ;  4
	.word 0x83FF,0x83FF,0xFFE0,0x83FF,0x83FF,0xFFE0,0x83FF,0x83FF ;  5
	.word 0x8000,0x83FF,0x83FF,0xFFE0,0xFFE0,0x83FF,0x83FF,0x8000 ;  6
	.word 0x8000,0x8000,0x83FF,0x83FF,0x83FF,0x83FF,0x8000,0x8000 ;  7

	
	