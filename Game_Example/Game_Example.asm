; A=0
; BC=1/4
; DE=2/5
; HL=3/6


.equ EnemyData,0x02000100	
.equ EnemyData_X,0				;Xpos
.equ EnemyData_Y,1				;Ypos
.equ EnemyData_Spr,2			;Frame 0-1
.equ EnemyData_Sca,3			;Scale 16-64
.equ EnemyData_Speed,4			;Speed
.equ EnemyData_SpeedB,5			;time till next move
.equ EnemyData_Tick,6			;time till next frame

.equ CursorX,0x02000000			;Text Cursor
.equ CursorY,0x02000001

.equ Score,0x02000004			;Score BCD
.equ HiScore,0x02000008			;Hiscore BCD
.equ Lives,0x0200000C			;Lives
.equ SoundTimeOut,0x0200000D	;Sound Time

.equ randomseed,0x02000200		;Seed (2 bytes)



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

ShowTitle:
	bl WaitForRelease			;Wait for Fire to be released

	bl Cls						;Clear Screen
	
	mov r11,#SoundTimeOut	
	mov r0,#0
	strb r0,[r11]				;Silence sound
		
	mov r1,#9
	mov r2,#4
	bl Locate	;Locate X,Y=R1,R2
	ldr r1,atxtSuckShoot
	bl PrintString				;Show Title
	
	mov r1,#11
	mov r2,#15
	bl Locate	;Locate X,Y=R1,R2
	ldr r1,atxtHiscore
	bl PrintString				;Show Hiscore text
	
	mov r1,#11
	mov r2,#16
	bl Locate	;Locate X,Y=R1,R2
	mov r11,#HiScore			;Show Hiscore
	ldr r1,[r11]	
	bl ShowBCD					;Show BCD in R1
	
	mov r11,#EnemyData
	
	mov r0,#120					;Settings for bat sprite
	strb r0,[r11,#EnemyData_X]
	mov r0,#80
	strb r0,[r11,#EnemyData_Y]
	mov r0,#1
	strb r0,[r11,#EnemyData_Spr]
	mov r0,#48
	strb r0,[r11,#EnemyData_Sca]
	
	
TitleScreen:	
	mov r11,#EnemyData
	
	ldrb r0,[r11,#EnemyData_Spr]	
	eor r0,r0,#1				;Toggle bat frame
	strb r0,[r11,#EnemyData_Spr]

	bl ShowEnemy				;Show The Bat

	mov r0,#0x1000				;Wait a bit!
	bl DoPause
	
	bl ShowEnemy				;Remove The Bat
	
	bl ReadJoystick				;Read in the Joystick	%---1UDLR
		    ; SSBARLDU
	tst r0,#0b00010000
	bne TitleScreen				;Repeat until fire pressed
	b Gameplay

atxtSuckShoot:
	.long txtSuckShoot			;Pointers to text strings
atxtHiscore:
	.long txtHiscore

txtSuckShoot:
	 .byte "SUCK SHOOT!",255
txtHiscore:
	 .byte "HISCORE:",255
	.align 4
	
	
Gameplay:
	bl Cls						;Clear Screen
	
	mov r11,#EnemyData
	
	mov r0,#32					;Enemy Speed
	strb r0,[r11,#EnemyData_Speed]
	
	mov r11,#Score
	mov r0,#0
	str r0,[r11]				;Write 4 zeros to score
	
	mov r11,#Lives
	mov r0,#4
	strb r0,[r11]				;Player lives
	
	bl RandomizeEnemy
	
	bl UpdateScore				;Show Score/lives text
	
	mov r8,#12					;Player Xpos
	mov r9,#10					;Player Ypos
	
	STMFD sp!,{r8-r9}
		bl ShowPlayer			;Show the new sprite position
		bl ShowEnemy			;Show the enemy sprite
	LDMFD sp!,{r8-r9}		
	
	
	
InfLoop:
	mov r10,#SoundTimeOut		;Time till silenced
	ldrb r0,[r10]
	cmp r0,#0
	beq ChibiSoundUpdated
	subs r0,r0,#1
	bne ChibiSoundUpdated
	bl ChibiSound				;Mute Sound
ChibiSoundUpdated:
	strb r0,[r10]
	
	
	
	bl ReadJoystick				;Read in the Joystick	%--21UDLR
	
	STMFD sp!,{r0,r8-r9}
		bl ShowPlayer			;Remove the old player
	LDMFD sp!,{r0,r8-r9}		
	
	mov r7,#2					;Move Speed Slow
	        ; SSBARLDU
	tst r0,#0b00100000			;Fire 2
	bne NoFire2
	mov r7,#4					;Move Speed Fast
NoFire2:	

	        ; SSBARLDU
	tst r0,#0b00000001
	bne JoyNotUp
	cmp r9,#12
	bcc JoyNotUp
	sub r9,r9,r7				;Move Up
JoyNotUp:	
	        ; SSBARLDU
	tst r0,#0b00000010
	bne JoyNotDown
	cmp r9,#160-12
	bcs JoyNotDown
	add r9,r9,r7				;Move Down
JoyNotDown:	
	        ; SSBARLDU
	tst r0,#0b00000100
	bne JoyNotLeft
	cmp r8,#12
	bcc JoyNotLeft
	sub r8,r8,r7				;Move Left
JoyNotLeft:	
	        ; SSBARLDU
	tst r0,#0b00001000
	bne JoyNotRight
	cmp r8,#240-12
	bcs JoyNotRight
	add r8,r8,r7				;Move Right
JoyNotRight:	
	STMFD sp!,{r0,r8-r9}
		bl ShowPlayer			;Show the new sprite position
		bl ShowEnemy			;Remove old enemy
	LDMFD sp!,{r0,r8-r9}		
	
	
	
	
	STMFD sp!,{r8-r9}
			    ; SSBARLDU
		tst r0,#0b00010000
		bne NoFire1				;See if player shot
		
		mov r11,#SoundTimeOut
		ldrb r0,[r11]
		cmp r0,#0
		bne FireNosound			;Done make fire sound if still firing
		
		mov r0,#0b11100000
		bl ChibiSound			;Make sound R0
FireNosound:		

		mov r11,#SoundTimeOut
		mov r0,#4
		strb r0,[r11]			;Set Sound Time
	
		mov r2,r8
		mov r5,r9
		
		mov r11,#EnemyData
		ldrb r1,[r11,#EnemyData_X]	;XY of enemy
		ldrb r4,[r11,#EnemyData_Y]
				
		mov r3,#8				;Width of Range
		mov r6,#8				;Height of Range
	
		bl rangetest			;See if object XY pos r2,r5 hits 
		beq NoHit				;object r1,r4 in range r3,r6
		
		ldrb r0,[r11,#EnemyData_Speed]
		add r0,r0,#1			;Speed up next enemy
		strb r0,[r11,#EnemyData_Speed]
		
		mov r0,#0b11000001
		bl ChibiSound			;Make sound A
				
		mov r10,#Score
		ldr r1,[r10]			;Get Current Score
		mov r2,#5
		
		bl AddBCD				;R1=R1+R2
		str r1,[r10]
		
		bl UpdateScore			;Show Score/lives text

		bl RandomizeEnemy		;Hit object, so re-randomize
NoHit:
NoFire1:	

		mov r11,#EnemyData
		ldrb r0,[r11,#EnemyData_Tick]
		add r0,r0,#64			;Update Bat Frame Tick
		strb r0,[r11,#EnemyData_Tick]
		ands r0,r0,#0xF00
		beq NoEnemyHit			;If not overflowed no move yet
		
		mov r11,#EnemyData
		ldrb r0,[r11,#EnemyData_Spr]
		eor r0,r0,#1			;Toggle Bat frame
		strb r0,[r11,#EnemyData_Spr]

		
		
		ldrb r0,[r11,#EnemyData_SpeedB]
		ldrb r1,[r11,#EnemyData_Speed]
		add r0,r0,r1			;Update Bat Time
		strb r0,[r11,#EnemyData_SpeedB]
		
		ands r0,r0,#0x0F00		
		beq NoEnemyHit
		
		ldrb r0,[r11,#EnemyData_Sca]
		adds r0,r0,#8			;Make Bat Bigger
		strb r0,[r11,#EnemyData_Sca]
		
		cmp r0,#64				;Biggest?
		bcc NoEnemyHit
			bl RandomizeEnemy	;Bat bit us!
			
			mov r11,#Lives
			ldrb r0,[r11]	
			subs r0,r0,#1		;Remove 1 life
			strb r0,[r11]	
			beq GameOver		;Player dead?
			
			mov r11,#SoundTimeOut
			mov r0,#4
			strb r0,[r11]		;Set Sound Time
			
			mov r0,#0b01000001
			bl ChibiSound		;Make Bite sound
		
			bl UpdateScore		;Show Score/lives text
NoEnemyHit:		
		bl ShowEnemy			;Show Bat again
	LDMFD sp!,{r8-r9}		
	
	
	
	mov r0,#0x2F00				;Delay Loop
	bl DoPause
	
	b InfLoop					;Repeat.

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

GameOver:
	bl WaitForRelease			;Wait for Fire to be released
	
	mov r0,#0
	bl ChibiSound				;Silence sound

	bl Cls						;Clear Screen
	
	mov r1,#10
	mov r2,#4
	bl Locate	;Locate X,Y=R1,R2	
	ldr r1,atxtGameOver			;Show 'Game Over'
	bl PrintString

	mov r10,#Score
	ldr r1,[r10]				;Current Score
	mov r11,#HiScore
	ldr r0,[r11]				;High score
	
	cmp r1,r0
	bls GameOver_NoScore		;New score lower

	str r1,[r11]				;Update the highscore
	
	mov r1,#9
	mov r2,#15
	bl Locate	;Locate X,Y=R1,R2	
	ldr r1,atxtGotHiScore		;Show 'New Highscore'
	bl PrintString
	
GameOver_Wait:
	bl ReadJoystick		;Read in the Joystick	%---1UDLR
		    ; SSBARLDU
	tst r0,#0b00010000
	bne GameOver_Wait			;Repeat until fire pressed
	b ShowTitle
	
GameOver_NoScore:	
	mov r1,#10
	mov r2,#15
	bl Locate	;Locate X,Y=R1,R2	
	ldr r1,atxtNoHiScore		;Show 'You Suck!'
	bl PrintString
	b GameOver_Wait
	
atxtGameOver:
	.long txtGameOver
atxtGotHiScore:
	.long txtGotHiScore
atxtNoHiScore:
	.long txtNoHiScore
	
txtGameOver:
	.byte "GAME OVER",255
txtGotHiScore:	
	.byte "NEW HISCORE",255
txtNoHiScore:				
	.byte "YOU SUCK!",255	

	
	
UpdateScore:
	STMFD sp!,{lr}
		mov r1,#0
		mov r2,#0
		bl Locate	;Locate X,Y=R1,R2
		mov r11,#Score
		ldr r1,[r11]	
		bl ShowBCD				;Show Score TopLeft
		
		mov r1,#28
		mov r2,#0
		bl Locate	;Locate X,Y=R1,R2
		mov r11,#Lives
		ldrb r1,[r11]	
		mov r1,r1,asl #24
		mov r4,#2				;Show Lives Top Right
		bl ShowBCDalt
	LDMFD sp!,{pc}
	
DoPause:
	subs r0,r0,#1
	bne DoPause
	MOV pc,lr
	
;Xor Sprite, drawing twice will remove sprite from screen.
ShowEnemy:
	mov r11,#EnemyData
	ldrb r8,[r11,#EnemyData_X]
	ldrb r9,[r11,#EnemyData_Y]
	ldrb r10,[r11,#EnemyData_Spr]
	and r10,r10,#1				;2 frames of animation
	add r10,r10,#1				;Enemy sprites are no 1-7
	
	ldrb r0,[r11,#EnemyData_Sca]
	eor r0,r0,#0b00110000
	and r0,r0,#0b00110000		;3 sizes of bat
	add r10,r10,r0,lsr #3
	b ShowSprite
	
ShowPlayer:
	mov r10,#0					;Player cursor is sprite 0
	
ShowSprite:
	ldr r11,aSpriteInfo
	add r11,r11,r10,lsl #3
	
	ldrb r0,[r11,#4]			;Width
	mov r0,r0,lsr #1
	sub r8,r8,r0
	
	ldrb r0,[r11,#5]			;Height
	mov r0,r0,lsr #1
	sub r9,r9,r0
	
	mov r10,#0x06000000 		;VRAM base
	
	mov r1,#2					;Sprite is 8px, 2 bytes per pixel
	mul r2,r1,r8
	add r10,r10,r2				;Xpos *16
	
	mov r1,#240*2				;240 pixels per line, 2 bytes per pixel
	mul r2,r1,r9
	add r10,r10,r2				;Ypos * 240*8*2
	
	
	ldr r1,[r11]				;Sprite source Address
	
	ldrb r6,[r11,#5]			;Height
Sprite_NextLine:	
	ldrb r5,[r11,#4]			;Width (in words / pixels)

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
	
	
aSpriteInfo:
	.long SpriteInfo
	
SpriteInfo:
    .long 0x0000*2 + SpriteBase           ;SpriteAddr 0
     .byte 16,16                                    ;XY 
	 .byte 0,0
    .long 0x0100*2 + SpriteBase           ;SpriteAddr 1
     .byte 32,24                                     ;XY 
	 .byte 0,0
    .long 0x0400*2 + SpriteBase           ;SpriteAddr 2
     .byte 32,32                                     ;XY 
	 .byte 0,0
    .long 0x0800*2 + SpriteBase           ;SpriteAddr 3
     .byte 24,16                                     ;XY 
	 .byte 0,0
    .long 0x0980*2 + SpriteBase           ;SpriteAddr 4
     .byte 24,24                                     ;XY 
	 .byte 0,0
    .long 0x0BC0*2 + SpriteBase           ;SpriteAddr 5
     .byte 16,8                                      ;XY 
	 .byte 0,0
    .long 0x0C40*2 + SpriteBase           ;SpriteAddr 6
     .byte 16,16                                     ;XY 
	.byte 0,0
	
SpriteBase: 	;Smiley ( Color bits: ABBBBBGGGGGRRRRR	A=Alpha )
	.incbin "GBA_SuckShoot.RAW"

	.align 4	
	
ReadJoystick: 		;Convert ------lrDULRSsBA to SsBARLDU
	STMFD sp!,{lr}
		mov r3,#0x4000130			;Read GBA joypad
		ldrh r2,[r3];------lrDULRSsBA
		and r1,r2,#0b0000000011000000	;UD
		mov r0,r1,lsr #6
		and r1,r2,#0b0000000000100000	;L
		orr r0,r0,r1,lsr #3
		and r1,r2,#0b0000000000010000	;R
		orr r0,r0,r1,lsr #1
		and r1,r2,#0b0000000000001111	;SsBA
		orr r0,r0,r1,lsl #4
	LDMFD sp!,{pc}
	
dorangedrandom:		;return a value in R0 between R1 and R4
	STMFD sp!,{lr}
dorangedrandomB:			
		bl dorandom
		cmp	r0,r1
		blt dorangedrandomB		;Below R1
		cmp	r0,r4
		bgt dorangedrandomB		;Above R4
	LDMFD sp!,{pc}
	
WaitForRelease:	
	STMFD sp!,{lr}
		bl ReadJoystick
				; SSBARLDU
		tst r0,#0b00010000
		beq WaitForRelease			;Repeat until fire released
	LDMFD sp!,{pc}
	

RandomizeEnemy:	
	STMFD sp!,{lr}
		mov r11,#EnemyData
		
		mov r1,#16
		mov r4,#240-16
		bl dorangedrandom
		strb r0,[r11,#EnemyData_X]		;Random Xpos
	
		mov r1,#16
		mov r4,#160-16
		bl dorangedrandom
		strb r0,[r11,#EnemyData_Y]		;Random Ypos
		
		
		mov r0,#16
		strb r0,[r11,#EnemyData_Sca]	;Scale=0
		
		mov r0,#0
		strb r0,[r11,#EnemyData_SpeedB]	;Speed=0
		strb r0,[r11,#EnemyData_Spr]	;Frame=0
	LDMFD sp!,{pc}
	
	
	
;Random number Lookup tables
Randoms1:
	.byte 0x0A,0x9F,0xF0,0x1B,0x69,0x3D,0xE8,0x52,0xC6,0x41,0xB7,0x74,0x23,0xAC,0x8E,0xD5
Randoms2:
	.byte 0x9C,0xEE,0xB5,0xCA,0xAF,0xF0,0xdb,0x69,0x3D,0x58,0x22,0x06,0x41,0x17,0x74,0x83
	
	
	
	
dorandom:				;RND outputs 8bit to R0 (no input)
	STMFD sp!,{r1-r6,lr}	
		mov r10,#randomseed	
		ldrh r1,[r10]			;Load 16 bit randomseed
		add r1,r1,#1			;INC R0
		add r1,r1,#0xFFFF0000	;Ensure register wraps around 
		strh r1,[r10]								;in 16 bits
		bl dorandomword			;Get Random R3/R6
		eor r0,r6,r3	
		and r0,r0,#0xff			;Cut down to 1 byte
	LDMFD sp!,{r1-r6,pc}	
	
RseedAddr:
	.long randomseed
	
dorandomword:	;Return Random pair in R6,R3 from Seed R1
	STMFD sp!,{lr}
		mov r0,#0		
		mov r4,r1				
		and r4,r4,#0x0000FF00 		;Get top byte of seed
		mov r4,r4,ror #8			;Move to bottom byte
		bl dorandombyte1			;Get 1st byte
		STMFD sp!,{r0}	
			STMFD sp!,{r1,r4} 	
				bl dorandombyte2	;Get 2nd byte
			LDMFD sp!,{r1,r4} 
			mov r6,r0				;Store 2nd byte in R6
		LDMFD sp!,{r3}				;Store 1st byte in R3
		add r1,r1,#1				;INC seed
	LDMFD sp!,{pc}
	
	
dorandombyte1:		;Return Byte R0 from Seeds R1/R4
	STMFD sp!,{lr}
		mov r0,r1 				;Get 1st seed
dorandombyte1b:
		and r0,r0,#0x000000FF
		orr r0,r0,r0, ror #24	;Fill 2nd byte byte 0x----FF--
		
		mov r0,r0,ror #2 		;Rotate Right
		eor r0,r0,r1			;Xor 1st Seed

		and r0,r0,#0x000000FF
		orr r0,r0,r0, ror #24	;Fill 2nd byte byte 0x----FF--
		
		mov r0,r0,ror #2 		;Rotate Right
		eor r0,r0,r4 			;Xor 2nd Seed
		
		and r0,r0,#0x000000FF
		orr r0,r0,r0, ror #24	;Fill 2nd byte byte 0x----FF--
		
		mov r0,r0,ror #1		;Rotate Right
		eor r0,r0,#0b10011101 	;Xor Constant
		eor r0,r0,r1 			;Xor 1st seed
		
		and r0,r0,#0x000000FF 	;Mask 1 byte
	LDMFD sp!,{pc}

	
dorandombyte2:		;Return Byte R0 from Seeds R1/R4
	STMFD sp!,{lr}
		adr r3,Randoms1			;LUT 1
		mov r0,r4 
		eor r0,r0,#0b00001011
		and r0,r0,#0b00001111 	;Convert 2nd seed low nibble to
									;Lookup offset
		
		ldrb r2,[r3,r0]			;Get Byte from LUT 1
		bl dorandombyte1		;Use 1st generator
		
		and r0,r0,#0b00001111 	;Convert random number from 
		adr r3,randoms2 			;1st generator to Lookup
		ldrb r0,[r3,r0]			;Get Byte from LUT2
		eor r0,r0,r2			;Xor 1st lookup
		and r0,r0,#0x000000FF 	;Mask to 1 byte
	LDMFD sp!,{pc}
	
	
	
	
	
	;BCD   Show R1
	
ShowBCDalt:				
	STMFD sp!,{r0-r4, lr}		
	b ShowBCDb
ShowBCD:			
	STMFD sp!,{r0-r4, lr}		
		mov r4,#8				;Char count
ShowBCDb:	
		and r0,r1,#0xF0000000	;Get a char
		mov r1,r1,lsl #4		;Remove it from R1
		
		mov r0,r0,lsr #28		;Shift char to -------X
		add r0,r0,#48			;Convrt to ascii +'0'
		bl PrintChar
	
		subs r4,r4,#1			
		bne ShowBCDb			;Repeat
		
	LDMFD sp!,{r0-r4, pc}		
	
	;BCD   R1=R1+R2	
AddBCD:
	STMFD sp!,{r2-r12, lr}		
		mov r0,#0				;Buildup
		mov r6,#0				;Carry
		mov r8,#0				;Rotation
		mov r7,#8				;Char count
		
AddBCDb:	
		and r3,r1,#0x0000000F	;Get A nibble of BCD1
		and r4,r2,#0x0000000F	;Get A nibble of BCD2
		
		add r3,r3,r4			;BCD1=BCD1+BCD2
		add r3,r3,r6			;Carry
		
		cmp r3,#10				;Any Overflow?
		blt AddBCD_NoOverFlow
		add r3,r3,#6			;Correct overflow
AddBCD_NoOverFlow:		

		and r5,r3,#0x00000000F
		orr r0,r0,r5,lsl r8		;OR this digit into result
		
		and r6,r3,#0x0000000F0	;Get the carry
		mov r6,r6,lsr #4		;Shift Carry
		
		mov r1,r1,lsr #4		;Remove nibble of BCD1
		mov r2,r2,lsr #4		;Remove nibble of BCD2
		
		add r8,r8,#4			;Increase Destination nibble
		
		subs r7,r7,#1
		bne AddBCDb				;Repeat
		
		mov r1,r0				;Final Value
	LDMFD sp!,{r2-r12, pc}	
	


	
	
	;BCD   R1=R1-R2
SubBCD:
	STMFD sp!,{r2-r12, lr}	
		mov r0,#0				;Buildup
		mov r6,#0				;Carry
		mov r8,#0				;Rotation
		mov r7,#8				;Char count
		
SubBCDb:	
		and r3,r1,#0x0000000F	;Get A nibble of BCD1
		and r4,r2,#0x0000000F	;Get A nibble of BCD2
		
		sub r3,r3,r4			;BCD1=BCD1+BCD2
		sub r3,r3,r6			;Carry
		
		mov r6,#0				;Zero Carry
		
		cmp r3,#0
		bgt SubBCD_NoOverFlow
		sub r3,r3,#6			;Correct overflow
		and r3,r3,#0x00000000F	
		mov r6,#1				;Set Carry
SubBCD_NoOverFlow:		
		
		orr r0,r0,r3,lsl r8		;OR this digit into result
		
		mov r1,r1,lsr #4		;Remove nibble of BCD1
		mov r2,r2,lsr #4		;Remove nibble of BCD2
		
		add r8,r8,#4			;Increase Destination nibble
		
		subs r7,r7,#1
		bne SubBCDb				;Repeat
		
		mov r1,r0				;Final Value
	LDMFD sp!,{r2-r12, pc}		
	
	
ChibiSound:		;TVPPPPPP T=tone (Tone/Noise) V=Volume (Low/High) P=Pitch
;Turn on Sound
		mov r1,#0x4000000	;4000084h - SOUNDCNT_X (NR52) - Sound on/off (R/W)
		add r1,r1,#0x84
				; M---4321
		mov r2,#0b10000000
		strh r2,[r1]
		
;Branch based on sound type
		tst r0,#0b11111111
		beq ChibiSound_Silent
		
		tst r0,#0b10000000
		bne ChibiSound_Noise
		
;Volume		
		mov r1,#0x4000000	;4000062h - SOUND1CNT_H (NR11, NR12) - Channel 1 Duty/Len/Envelope (R/W)
		add r1,r1,#0x62
		
		and r2,r0,#0b01000000
		mov r2,r2,asl #8
		mov r2,r2,asl #1
				    ;VVVVDSSSWWLLLLLL - L=length W=wave pattern duty S=envelope Step D= env direction V=Volume
		orr r2,r2,#0b0111000000000000	
		strh r2,[r1]
		
;Frequency (Pitch)
		mov r1,#0x4000000	;4000064h - SOUND1CNT_X (NR13, NR14) - Channel 1 Frequency/Control (R/W)
		add r1,r1,#0x64
		
		and r2,r0,#0b00111111
		eor r2,r2,#0b00111111		;Flip pitch
		mov r2,r2,asl #4
				    ;IL---FFFFFFFFFFF
		orr r2,r2,#0b1000000000000000	;I=Init sound F=Frequency
		strh r2,[r1]
		
;Master Volume	Channel 1 on	
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b0001000101110111	;Master 2 on
		strh r2,[r1]
	MOV pc,lr
	
ChibiSound_Silent:
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b0000000000000000
		strh r2,[r1]
	MOV pc,lr

ChibiSound_Noise:

;Volume
		mov r1,#0x4000000	;4000078h - SOUND4CNT_L (NR41, NR42) - Channel 4 Length/Envelope (R/W)
		add r1,r1,#0x78
		
		and r2,r0,#0b01000000
		mov r2,r2,asl #8
		mov r2,r2,asl #1
				    ;VVVVDSSSWWLLLLLL
		orr r2,r2,#0b0111000000000000
		strh r2,[r1]
		
;Frequency (Pitch)
		mov r1,#0x4000000	;400007Ch - SOUND4CNT_H (NR43, NR44) - Channel 4 Frequency/Control (R/W)
		add r1,r1,#0x7C
		
		and r2,r0,#0b00111100
		mov r2,r2,asl #2
				    ;IL------FFFFCDDD
		orr r2,r2,#0b1000000000000000
		strh r2,[r1]
		
;Master Volume	Channel 4 on	
		mov r1,#0x4000000	;4000080h - SOUNDCNT_L (NR50, NR51) - Channel L/R Volume/Enable (R/W)
		add r1,r1,#0x80
				 ;LLLLRRRR-lll-rrr  - LR=Channel 4331 on (1=on) ... lr=master volume (7=max)
		mov r2,#0b1000100001110111	;Master 2 on
		strh r2,[r1]
	MOV pc,lr
	
	
	
		
	

	
;See if object XY pos R2,R5 hits object R1,R4 in range R3,R6
	;Return R0=1 Collision... R0!=1 means no collision
rangetest:			
	STMFD sp!,{lr}	;X Axis Check
	
		mov r0,r1 			;Pos1 Xpos
		subs r0,r0,r3		;Shift Pos1 by 'range' to the Left
		blt rangetestb		;<0
		cmp r2,r0			;Does it match Pos2?
		blt rangetestoutofrange
		
rangetestb:
		add r0,r0,r3,asl #1	;Shift Pos1 by 'range' to the Right
		cmp r0,#255
		bgt rangetestd		;>255
		cmp r2,r0			;Does it match Pos2?
		bgt rangetestoutofrange
		
rangetestd:			;Y Axis Check

		mov r0,r4 			;Pos1 Ypos
		subs r0,r0,r6		;Shift Pos1 by 'range' Up
		blt rangetestc		;<0
		cmp r5,r0 			;Does it match Pos2?
		blt rangetestoutofrange
		
rangetestc:
		add r0,r0,r6,asl #1	;Shift Pos1 by 'range' Down
		cmp r0,#255
		bgt rangeteste		;>255
		cmp r5,r0			;Does it match Pos2?
		bgt rangetestoutofrange			
rangeteste:
		movs r0,#1			;1=Collided
	LDMFD sp!,{pc}
	
rangetestoutofrange:		
		movs r0,#0			;0=No Collision
	LDMFD sp!,{pc}
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintString:					;Print 255 terminated string 
	STMFD sp!,{r0-r12, lr}
PrintStringAgain:
		ldrB r0,[r1],#1
		cmps r0,#255
		beq PrintStringDone		;Repeat until 255
		bl PrintChar 			;Print Char
		b PrintStringAgain
PrintStringDone:
	LDMFD sp!,{r0-r12, pc}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Cls:
		mov r0, #0x06000000		;Screen Ram
		mov r1, #0				;Fill Word
		mov r2, #240*160/2		;Words to fill
FillScreenLoop:
		str r1, [r0],#4		;Store+inc 2 bytes
		subs r2, r2, #1		
		bne FillScreenLoop	
	MOV pc,lr
	
	
Locate:		;X,Y = R1,R2
	STMFD sp!,{r3,lr}
		mov r3,#CursorX
		strB r1,[r3]			;X pos
		mov r3,#CursorY
		strB r2,[r3]			;Y pos
		
	LDMFD sp!,{r3,pc}
		
	
PrintChar:
	STMFD sp!,{r0-r12, lr}
	mov r4,#0
		mov r5,#0
		
		mov r3,#CursorX
		ldrB r4,[r3]			;X pos
		mov r3,#CursorY
		ldrB r5,[r3]			;Y pos
		
		mov r3,#0x06000000 		;VRAM base
		
		mov r6,#8*2				;Xpos, 2 bytes per pixel, 8 bytes per char
		mul r2,r4,r6
		add r3,r3,r2
		
		mov r4,#240*8*2			;Ypos, 240 pixels per line,
		mul r2,r5,r4				;2 bytes per pixel, 8 lines per char
		add r3,r3,r2
		
		adr r4,BitmapFont 		;Font source
		
		sub r0,r0,#32			;First Char is 32 (space)
		add r4,r4,r0,asl #3		;8 bytes per char
		
		mov r1,#8				;8 lines 
DrawLine:
		mov r7,#8 				;8 pixels per line
		ldrb r8,[r4],#1			;Load Letter
		mov r9,#0b100000000		;Mask
				
		mov r2, #0x7FFF; Color: ABBBBBGGGGGRRRRR   A=Alpha
		mov r10,#0		;Blank
DrawPixel:
		tst r8,r9				;Is bit 1?
		strneh r2,[r3]			;Yes? then fill pixel (HalfWord)
		streqh r10,[r3]			;Yes? then fill pixel (HalfWord)
		add r3,r3,#2
		mov r9,r9,ror #1		;Bitshift Mask
		subs r7,r7,#1
		bne DrawPixel			;Next Hpixel
		
		add r3,r3,#480-16	   ;Move Down a line (240 pixels *2 bytes) 
		subs r1,r1,#1								;-1 char (16 px)
		bne DrawLine			;Next Vline
		
LineDone:	
		mov r3,#CursorX
		ldrB r0,[r3]	
		add r0,r0,#1			;Move across screen
		strB r0,[r3]	
	LDMFD sp!,{r0-r12, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
BitmapFont:
        .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ;  0
        .byte 0x10,0x18,0x18,0x18,0x18,0x00,0x18,0x00     ;  1
        .byte 0x28,0x6C,0x28,0x00,0x00,0x00,0x00,0x00     ;  2
        .byte 0x00,0x28,0x7C,0x28,0x7C,0x28,0x00,0x00     ;  3
        .byte 0x18,0x3E,0x48,0x3C,0x12,0x7C,0x18,0x00     ;  4
        .byte 0x02,0xC4,0xC8,0x10,0x20,0x46,0x86,0x00     ;  5
        .byte 0x10,0x28,0x28,0x72,0x94,0x8C,0x72,0x00     ;  6
        .byte 0x0C,0x1C,0x30,0x00,0x00,0x00,0x00,0x00     ;  7
        .byte 0x18,0x18,0x30,0x30,0x30,0x18,0x18,0x00     ;  8
        .byte 0x18,0x18,0x0C,0x0C,0x0C,0x18,0x18,0x00     ;  9
        .byte 0x08,0x49,0x2A,0x1C,0x14,0x22,0x41,0x00     ; 10
        .byte 0x00,0x18,0x18,0x7E,0x18,0x18,0x00,0x00     ; 11
        .byte 0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x30     ; 12
        .byte 0x00,0x00,0x00,0x7E,0x7E,0x00,0x00,0x00     ; 13
        .byte 0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x00     ; 14
        .byte 0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x00     ; 15
        .byte 0x7C,0xC6,0xD6,0xD6,0xD6,0xC6,0x7C,0x00     ; 16
        .byte 0x10,0x18,0x18,0x18,0x18,0x18,0x08,0x00     ; 17
        .byte 0x3C,0x7E,0x06,0x3C,0x60,0x7E,0x3C,0x00     ; 18
        .byte 0x3C,0x7E,0x06,0x1C,0x06,0x7E,0x3C,0x00     ; 19
        .byte 0x18,0x3C,0x64,0xCC,0x7C,0x0C,0x08,0x00     ; 20
        .byte 0x3C,0x7E,0x60,0x7C,0x06,0x7E,0x3E,0x00     ; 21
        .byte 0x3C,0x7E,0x60,0x7C,0x66,0x66,0x3C,0x00     ; 22
        .byte 0x3C,0x7E,0x06,0x0C,0x18,0x18,0x10,0x00     ; 23
        .byte 0x3C,0x66,0x66,0x3C,0x66,0x66,0x3C,0x00     ; 24
        .byte 0x3C,0x66,0x66,0x3E,0x06,0x7E,0x3C,0x00     ; 25
        .byte 0x00,0x00,0x18,0x18,0x00,0x18,0x18,0x00     ; 26
        .byte 0x00,0x00,0x18,0x18,0x00,0x18,0x18,0x30     ; 27
        .byte 0x0C,0x1C,0x38,0x60,0x38,0x1C,0x0C,0x00     ; 28
        .byte 0x00,0x00,0x7E,0x00,0x00,0x7E,0x00,0x00     ; 29
        .byte 0x60,0x70,0x38,0x0C,0x38,0x70,0x60,0x00     ; 30
        .byte 0x3C,0x76,0x06,0x1C,0x00,0x18,0x18,0x00     ; 31
        .byte 0x7C,0xCE,0xA6,0xB6,0xC6,0xF0,0x7C,0x00     ; 32
        .byte 0x18,0x3C,0x66,0x66,0x7E,0x66,0x24,0x00     ; 33
        .byte 0x3C,0x66,0x66,0x7C,0x66,0x66,0x3C,0x00     ; 34
        .byte 0x38,0x7C,0xC0,0xC0,0xC0,0x7C,0x38,0x00     ; 35
        .byte 0x3C,0x64,0x66,0x66,0x66,0x64,0x38,0x00     ; 36
        .byte 0x3C,0x7E,0x60,0x78,0x60,0x7E,0x3C,0x00     ; 37
        .byte 0x38,0x7C,0x60,0x78,0x60,0x60,0x20,0x00     ; 38
        .byte 0x3C,0x66,0xC0,0xC0,0xCC,0x66,0x3C,0x00     ; 39
        .byte 0x24,0x66,0x66,0x7E,0x66,0x66,0x24,0x00     ; 40
        .byte 0x10,0x18,0x18,0x18,0x18,0x18,0x08,0x00     ; 41
        .byte 0x08,0x0C,0x0C,0x0C,0x4C,0xFC,0x78,0x00     ; 42
        .byte 0x24,0x66,0x6C,0x78,0x6C,0x66,0x24,0x00     ; 43
        .byte 0x20,0x60,0x60,0x60,0x60,0x7E,0x3E,0x00     ; 44
        .byte 0x44,0xEE,0xFE,0xD6,0xD6,0xD6,0x44,0x00     ; 45
        .byte 0x44,0xE6,0xF6,0xDE,0xCE,0xC6,0x44,0x00     ; 46
        .byte 0x38,0x6C,0xC6,0xC6,0xC6,0x6C,0x38,0x00     ; 47
        .byte 0x38,0x6C,0x64,0x7C,0x60,0x60,0x20,0x00     ; 48
        .byte 0x38,0x6C,0xC6,0xC6,0xCA,0x74,0x3A,0x00     ; 49
        .byte 0x3C,0x66,0x66,0x7C,0x6C,0x66,0x26,0x00     ; 50
        .byte 0x3C,0x7E,0x60,0x3C,0x06,0x7E,0x3C,0x00     ; 51
        .byte 0x3C,0x7E,0x18,0x18,0x18,0x18,0x08,0x00     ; 52
        .byte 0x24,0x66,0x66,0x66,0x66,0x66,0x3C,0x00     ; 53
        .byte 0x24,0x66,0x66,0x66,0x66,0x3C,0x18,0x00     ; 54
        .byte 0x44,0xC6,0xD6,0xD6,0xFE,0xEE,0x44,0x00     ; 55
        .byte 0xC6,0x6C,0x38,0x38,0x6C,0xC6,0x44,0x00     ; 56
        .byte 0x24,0x66,0x66,0x3C,0x18,0x18,0x08,0x00     ; 57
        .byte 0x7C,0xFC,0x0C,0x18,0x30,0x7E,0x7C,0x00     ; 58
        .byte 0x1C,0x30,0x30,0x30,0x30,0x30,0x1C,0x00     ; 59
        .byte 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x00     ; 60
        .byte 0x38,0x0C,0x0C,0x0C,0x0C,0x0C,0x38,0x00     ; 61
        .byte 0x18,0x18,0x18,0x18,0x7E,0x7E,0x18,0x18     ; 62
        .byte 0x18,0x18,0x18,0x18,0x3C,0x3C,0x18,0x18     ; 63
        .byte 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18     ; 64
        .byte 0x00,0x00,0x38,0x0C,0x7C,0xCC,0x78,0x00     ; 65
        .byte 0x20,0x60,0x7C,0x66,0x66,0x66,0x3C,0x00     ; 66
        .byte 0x00,0x00,0x3C,0x66,0x60,0x66,0x3C,0x00     ; 67
        .byte 0x08,0x0C,0x7C,0xCC,0xCC,0xCC,0x78,0x00     ; 68
        .byte 0x00,0x00,0x3C,0x66,0x7E,0x60,0x3C,0x00     ; 69
        .byte 0x1C,0x36,0x30,0x38,0x30,0x30,0x10,0x00     ; 70
        .byte 0x00,0x00,0x3C,0x66,0x66,0x3E,0x06,0x3C     ; 71
        .byte 0x20,0x60,0x6C,0x76,0x66,0x66,0x24,0x00     ; 72
        .byte 0x18,0x00,0x18,0x18,0x18,0x18,0x08,0x00     ; 73
        .byte 0x06,0x00,0x04,0x06,0x06,0x26,0x66,0x3C     ; 74
        .byte 0x20,0x60,0x66,0x6C,0x78,0x6C,0x26,0x00     ; 75
        .byte 0x10,0x18,0x18,0x18,0x18,0x18,0x08,0x00     ; 76
        .byte 0x00,0x00,0x6C,0xFE,0xD6,0xD6,0xC6,0x00     ; 77
        .byte 0x00,0x00,0x3C,0x66,0x66,0x66,0x24,0x00     ; 78
        .byte 0x00,0x00,0x3C,0x66,0x66,0x66,0x3C,0x00     ; 79
        .byte 0x00,0x00,0x3C,0x66,0x66,0x7C,0x60,0x20     ; 80
        .byte 0x00,0x00,0x78,0xCC,0xCC,0x7C,0x0C,0x08     ; 81
        .byte 0x00,0x00,0x38,0x7C,0x60,0x60,0x20,0x00     ; 82
        .byte 0x00,0x00,0x3C,0x60,0x3C,0x06,0x7C,0x00     ; 83
        .byte 0x10,0x30,0x3C,0x30,0x30,0x3E,0x1C,0x00     ; 84
        .byte 0x00,0x00,0x24,0x66,0x66,0x66,0x3C,0x00     ; 85
        .byte 0x00,0x00,0x24,0x66,0x66,0x3C,0x18,0x00     ; 86
        .byte 0x00,0x00,0x44,0xD6,0xD6,0xFE,0x6C,0x00     ; 87
        .byte 0x00,0x00,0xC6,0x6C,0x38,0x6C,0xC6,0x00     ; 88
        .byte 0x00,0x00,0x24,0x66,0x66,0x3E,0x06,0x7C     ; 89
        .byte 0x00,0x00,0x7E,0x0C,0x18,0x30,0x7E,0x00     ; 90
        .byte 0x08,0x08,0x08,0x08,0x56,0x55,0x57,0x74     ; 91
        .byte 0x18,0x04,0x08,0x1C,0x56,0x55,0x57,0x74     ; 92
        .byte 0x00,0x00,0x00,0x00,0x7E,0x7E,0xFF,0xFF     ; 93
        .byte 0x18,0x3C,0x18,0x18,0x18,0x18,0x7E,0xFF     ; 94
        .byte 0x22,0x77,0x7F,0x7F,0x3E,0x1C,0x08,0x00     ; 95
 
 	
