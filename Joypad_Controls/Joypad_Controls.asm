.equ JoyData,RamArea+4	;4 bytes
.equ PenData,RamArea+8	;8 Bytes X,Y

.org  0x08000000     ; GBA ROM Address starts at 0x08000000       
.equ ProgBase,0;0x08000000

.equ ramarea, 0x02000000
.equ userram, 0x02000000

.equ CursorX,ramarea+32
.equ MonitorWidth,6

;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start") 
b	GbaStart

.equ CursorY,ramarea+33

;004h    156   Nintendo Logo    (compressed bitmap, required!)
.byte 0xC8,0x60,0x4F,0xE2,0x01,0x70,0x8F,0xE2,0x17,0xFF,0x2F,0xE1,0x12,0x4F,0x11,0x48     ; C
.byte 0x12,0x4C,0x20,0x60,0x64,0x60,0x7C,0x62,0x30,0x1C,0x39,0x1C,0x10,0x4A,0x00,0xF0     ; D
.byte 0x14,0xF8,0x30,0x6A,0x80,0x19,0xB1,0x6A,0xF2,0x6A,0x00,0xF0,0x0B,0xF8,0x30,0x6B     ; E
.byte 0x80,0x19,0xB1,0x6B,0xF2,0x6B,0x00,0xF0,0x08,0xF8,0x70,0x6A,0x77,0x6B,0x07,0x4C     ; F
.byte 0x60,0x60,0x38,0x47,0x07,0x4B,0xD2,0x18,0x9A,0x43,0x07,0x4B,0x92,0x08,0xD2,0x18     ; 10
.byte 0x0C,0xDF,0xF7,0x46,0x04,0xF0,0x1F,0xE5,0x00,0xFE,0x7F,0x02,0xF0,0xFF,0x7F,0x02     ; 11
.byte 0xF0,0x01,0x00,0x00,0xFF,0x01,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00     ; 12
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 13
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00     ; 14
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1A,0x9E,0x7B,0xEB     ; 15

;0A0h    12    Game Title       (uppercase ascii, max 12 characters)	
.ascii "LEARNASM.NET"
;0ACh    4     Game Code        (uppercase ascii, 4 characters)
.ascii "0000"			;Code
;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
.byte "GB"				;Maker
;0B2h    1     Fixed value      (must be 96h, required!)
.byte 0x96
;0B3h    1     Main unit code   (00h for current GBA models)
.byte 0x00
;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
.byte 0x00
;0B5h    7     Reserved Area    (should be zero filled)
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00
;0BCh    1     Software version (usually 00h)
.byte 0x00
;0BDh    1     Complement check (header checksum, required!)
.byte 0x00
;0BEh    2     Reserved Area    (should be zero filled)
.byte 0x00,0x00
;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
.byte 0x00,0x00,0x00,0x00
;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
.byte 0x00
;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
.byte 0x00
;0C6h    26    Not used         (seems to be unused)
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")
.byte 0x00,0x00,0x00,0x00

GbaStart:
	bl ScreenInit
Again:	
	bl cls

	; Read Joypad State
	mov r3,#0x4000130	; GBA Keys (KEYINPUT register) at 0x04000130
	ldrh r0,[r3]		; ------LRDULRSsBA (inverted, 0=pressed)
	bl MonitorR0		

	mov r1,#5
Delay:
	mov r0,#0x4000004	; DISPSTAT (Display Status register) at 0x04000004
	ldrh r0,[r0]
	ands r0,r0,#1		; Bit 0 is VBlank status
	beq Delay			; Wait for VBlank End (wait until bit 0 is 1)
Delay2:
	mov r0,#0x4000004	; DISPSTAT
	ldrh r0,[r0]
	ands r0,r0,#1
	bne Delay2			; Wait for VBlank Start (wait until bit 0 is 0)
	subs r1,r1,#1
	bne Delay
	
	b Again

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Monitor & Output Registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MonitorR0:	
	STMFD sp!,{lr}			;Push Regs
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{pc}			;Pop Regs and return	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; V1_Monitor.asm (Inlined & GBA-Refactored)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
		
		mov r0,#82 ; R
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
		and r0,r2,#0x0F ; r3
		cmp r0,#10
		addge r0,r0,#7
		add r0,r0,#48
		bl PrintChar	
	LDMFD sp!,{r0-r12, pc}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; V1_BitmapMemory.asm (16-bit color, Inlined & Refactored)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

		mov r2,r1,asl #11				;B
				 ;----GGGGRRRRBBBB
		mov r3,#0b0111100000000000
		and r2,r2,r3
		mov r5,r2
		
		mov r2,r1,lsr #3			;R
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000000000011110
		and r2,r2,r3
		orr r5,r5,r2
		
		mov r2,r1,lsr #2			;G
				 ;----GGGGRRRRBBBB
		mov r3,#0b0000001111000000
				  
		and r2,r2,r3
		orr r5,r5,r2
		
		strH r5,[r11]	;-BBBBBGGGGGRRRRR
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Binary Includes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BitmapFont:
	.incbin "Font96.FNT"

SpriteTest:
