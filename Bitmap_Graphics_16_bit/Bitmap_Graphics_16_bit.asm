; ==============================================================================
; GBA 16-bit Bitmap Graphics Tutorial
; Target: Nintendo Game Boy Advance (GBA)
; CPU: ARM7TDMI
; Assembler: VASM (Standard Syntax)
; ==============================================================================

; ==============================================================================
;                                 Header
; ==============================================================================
	.org  0x08000000     ; GBA ROM Address starts at 0x08000000       
	.equ ProgBase,0;0x08000000

	.equ ramarea, 0x02000000  ; WRAM (On-board 256K Work RAM)
	.equ userram, 0x02000000
	
	.equ CursorX,ramarea+32   ; RAM addresses for text monitor
	.equ CursorY,ramarea+33
	.equ MonitorWidth,6
 
;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start") 
	b	GbaStart

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
	;		123456789012
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


; ==============================================================================
;                              Main Entry Point
; ==============================================================================
GbaStart:
	; Initialize the Screen Mode
	bl ScreenInit
	
	; Draw the register monitor (for debugging/tutorial purpose)
	bl Monitor
	
	; ----------------------------------------------------
	; Draw Sprite Data to Screen
	; ----------------------------------------------------
	mov r1,#20				; X position
	mov r2,#100				; Y position
	bl GetScreenPos			; Calculate screen VRAM address for X/Y
							; Returned in r10
	
	ldr r1,SpriteAddress	; Load the pointer to SpriteData
	mov r6,#48				; Sprite Height in pixels
Sprite_NextLine:	
	mov r5,#48				; Width in pixels 
	
	STMFD sp!,{r10}			; Backup current line's starting screen address
Sprite_NextByte:
		ldrH r0,[r1],#2		; Read 16-bit pixel from ROM (Sprite Data)
		strH r0,[r10],#2	; Write 16-bit pixel to VRAM
		
		subs r5,r5,#1		; Decrement width counter
		bne Sprite_NextByte	; Repeat if not zero
		
	LDMFD sp!,{r10}			; Restore line's starting screen address
	bl GetNextLine			; Move VRAM pointer down to the next row (Y+1)
	
	subs r6,r6,#1			; Decrement height counter
	bne Sprite_NextLine		; Repeat if not zero
	; ----------------------------------------------------

	; Print Hello World String
	ldr r1,HelloWorldAddress
	bl PrintString

	; Dump Memory (Show some memory at the "infloop" label)
	adr	r0,infloop			; Address to dump
	mov r1,#2				; Number of Lines
	bl MemDump
	
infloop:
	b infloop				; Infinite Loop (End of program)

; ==============================================================================
;                                  Strings
; ==============================================================================
PrintString:
	STMFD sp!,{r0-r12, lr}
PrintStringAgain:
		ldrB r0,[r1],#1		; Load one character
		cmps r0,#255		; Check if termination character (255)
		beq PrintStringDone
		bl PrintChar 		; Print it to VRAM
		b PrintStringAgain
PrintStringDone:
	LDMFD sp!,{r0-r12, pc}

; ==============================================================================
;                           Data Definitions
; ==============================================================================
	.align 4
HelloWorldAddress:
	.long HelloWorld
	
HelloWorld:
	.byte "Hello World",255

	.align 4
SpriteAddress:
	.long SpriteTest

SpriteTest:
	.incbin "Sprite_16bpp.RAW" ; ARGB 16bpp raw sprite data (converted NDS sprite)

BitmapFont:
	.incbin "Font96.FNT"

; ==============================================================================
;                           Graphics Routines
; ==============================================================================

NewLine:
	STMFD sp!,{r0-r12, lr}
		mov r3,#CursorX
		mov r0,#0
		strB r0,[r3]		; Reset CursorX to 0
		
		mov r3,#CursorY
		ldrB r0,[r3]	
		add r0,r0,#1		; Increment CursorY
		strB r0,[r3]	
	LDMFD sp!,{r0-r12, pc}
	
PrintChar:
	STMFD sp!,{r0-r12, lr}
		mov r4,#0
		mov r5,#0
		
		mov r3,#CursorX
		ldrB r4,[r3]		; Get Cursor X
		mov r3,#CursorY
		ldrB r5,[r3]		; Get Cursor Y
		
		mov r3,#0x06000000 	; VRAM Base Address (Mode 3)
		
		mov r6,#16			; Font Character Width (8 pixels * 2 bytes/pixel)
		mul r2,r4,r6		; X Offset
		add r3,r3,r2
		
		mov r4,#240*8*2		; Font Character Height (Row length * 8 pixels * 2 bytes/pixel)
		mul r2,r5,r4		; Y Offset
		add r3,r3,r2
		
		adr r4,BitmapFont 	; Load Font source address
		sub r0,r0,#32		; First Character in font is ASCII 32 (Space)
		add r4,r4,r0,asl #3	; 8 bytes per character in font mapping
		
		mov r1,#8			; 8 lines per character
DrawLine:
		mov r7,#8 			; 8 pixels per line
		ldrb r8,[r4],#1		; Load the bitmap row for the given character
		mov r9,#0b10000000	; Pixel mask to read left alignment
		
		; Font color
		;         ABBBBBGGGGGRRRRR (A=Alpha)
		mov r2, #0b1111111101000000 
		
DrawPixel:
		tst r8,r9			; Is bit set?
		strneh r2,[r3]		; Yes? then fill pixel in VRAM with color
		add r3,r3,#2		; Move VRAM ptr 2 bytes (1 pixel) right
		mov r9,r9,ror #1	; Bitshift Mask to next bit
		subs r7,r7,#1		; Decrease X-Counter
		bne DrawPixel		; Next horizontal pixel
		
		add r3,r3,#480-16	; Move down one line (240px * 2 - 16 bytes for drawn text)
		subs r1,r1,#1		; Decrease Y-Counter
		bne DrawLine		; Next vertical line
		
		mov r3,#CursorX
		ldrB r0,[r3]	
		add r0,r0,#1		; Move cursor horizontally for next character
		strB r0,[r3]	
	LDMFD sp!,{r0-r12, pc}

GetScreenPos: 
	; IN: R1 = X, R2 = Y
	; OUT: R10 = Screen Address
	STMFD sp!,{r2}
		STMFD sp!,{r1}
			mov r10,#0x06000000 ; VRAM Mode 3 Base Address
			mov r1,#240*2		; Ypos multiplier (240 pixels * 2 bytes)
			mul r2,r1,r2		; Total Y Offset
		LDMFD sp!,{r1}	
		add r10,r10,r1,lsl #1   ; X offset in bytes = X * 2 
	add r10,r10,r2
	LDMFD sp!,{r2}
	MOV pc,lr

GetNextLine:
	; IN: R10 = Current VRAM Address
	; OUT: R10 = Address directly below
	add r10,r10,#240*2			; Move down 1 screen row (240px * 2 Bytes = 480 Bytes)
	MOV pc,lr
	
ScreenInit:
	; Turn on the screen - ScreenMode 3 - 240x160 16 bit color
	STMFD sp!,{r0-r12, lr}
		mov r4,#0x04000000  	; DISPCNT (LCD Control register)
		mov r2,#0x403    		; Bit 8,9,10 = BG2 enable (0x400) | Mode 3 (0x3)
		str	r2,[r4]         	
	
		bl cls					; Clear the screen buffer
		
	LDMFD sp!,{r0-r12, pc}
	
cls:
	; Reset Custom Cursor
	mov r3,#CursorX
	mov r0,#0
	strB r0,[r3]	; X=0
	mov r3,#CursorY
	strB r0,[r3]	; Y=0
	
	; Fill the screen	
	mov r0, #0x06000000			; Screen Ram (Mode 3 Base)
			;      ABBBBBGGGGGRRRRR	A=Alpha
	mov r1, #0b1000000010001010
	add r1,r1,#0x808A0000		; Duplicate 16-bit color to fill as 32-bit blocks
	
	mov r2, #240*160/2			; Total loops needed for GBA (240*160 pixels / 2 pixels per write)

FillScreenLoop:
		str r1, [r0],#4			; Store 32-bits (2 pixels) + increment 4 bytes
		subs r2, r2, #1		
		bne FillScreenLoop	
	MOV pc,lr

; ==============================================================================
;                        Monitor & Debug Routines
; ==============================================================================
MemDump:				
	STMFD sp!,{r0-r12, lr}
		mov r4,r0
		
		mov r0,r4
		bl ShowHex32
		mov r0,#58 				; ':'
		bl PrintChar
		bl NewLine

MemDumpNextLine:
		mov r3,#0
MemDumpAgain:			
		ldrb r0,[r4,r3]
		bl ShowHex
		
		mov r0,#32 				; space
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
		movlt r0,#46 			; '.' Filter unprintable
		cmp r0,#128
		movgt r0,#46 			; '.' Filter unprintable
		
		bl PrintChar
	LDMFD sp!,{r0-r12, pc}		
		
Monitor:
	STMFD sp!,{r0-r15}
	mov r5,sp
	
	mov r3,#0 					; Start Register
	mov r4,#0					; Stack Offsets
NextReg:
	bl ShowReg					; 1st column
	
	mov r0,#32
	bl PrintChar

	add r4,r4,#8*4				; 2nd column
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
		mov r0,#76 				; 'L'
		bl PrintChar
		mov r0,#82 				; 'R'
		bl PrintChar
	b ShowRegB
	
ShowRegSP:		
		mov r0,#83 				; 'S'
		bl PrintChar
		mov r0,#80 				; 'P'
		bl PrintChar
	b ShowRegB
	
ShowRegPC:		
		mov r0,#80 				; 'P'
		bl PrintChar
		mov r0,#67 				; 'C'
		bl PrintChar	
	b ShowRegB
	
ShowReg:			
	STMFD sp!,{r0-r12, lr}
		cmp r3,#15
		beq ShowRegPC
		cmp r3,#14
		beq ShowRegLR
		cmp r3,#13
		beq ShowRegSP
		
		mov r0,#82 				; 'R' (Ascii 82)
		bl PrintChar
		
		mov r2,r3 
		bl ShowHexChar
ShowRegB:		
		mov r0,#58 				; ':'
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
		and r0,r2,#0x0F
		cmp r0,#10
		addge r0,r0,#7
		add r0,r0,#48
		bl PrintChar	
	LDMFD sp!,{r0-r12, pc}
