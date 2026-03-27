	.equ JoyData,RamArea+4	;4 bytes
	
	
	.equ PenData,RamArea+8	;8 Bytes X,Y
	
	;.arm                 ; Use arm instruction set.
    ; header...
    .org  0x08000000     ; GBA ROM Address starts at 0x08000000       
	.equ ProgBase,0;0x08000000
    ;.section text			

	.equ ramarea, 0x02000000
	
	.equ userram, 0x02000000
	
	.equ CursorX,ramarea+32

	.equ MonitorWidth,6
 
;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start") 
    b	GbaStart

	.equ CursorX,ramarea+32
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

GbaStart:
	
;.equ Bmp256, 1	;256 color mode - GBA only	
	
	bl ScreenInit
Again:	
	bl cls

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Risc OS	

	.ifdef BuildROS
	
		mov r0,#129		;Read a key
		mov r1,#16		;Wait Length L Byte (00-FF)
		mov r2,#0		;Wait Length H Byte (Max 7F)
		SWI 0x6			;OSByte
		
		mov r0,r1		;R1=Ascii key press
		bl MonitorR0

;Up Test
		mov r0,#129		;Test a key
		mov r1,#255^57	;Key 57=UP (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte
		
		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32
		moveq r0,#85	;U
		bl PrintChar
		
;Down Test
		mov r0,#129		;Test a key
		mov r1,#255^41	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte

		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;D
		moveq r0,#68	;Move if Equal
		bl PrintChar
		
;Left Test
		mov r0,#129		;Test a key
		mov r1,#255^25	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte

		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;L
		moveq r0,#76	;Move if Equal
		bl PrintChar

;Right Test
		mov r0,#129		;Test a key
		mov r1,#255^121	;Key 41=DOWN (255 xor key)
		mov r2,#255		;255=No Wait
		SWI 0x6			;OSByte
		
		cmp r1,#255		;255=Pressed 0=Unpressed
		mov r0,#32		;R
		moveq r0,#82	;Move if Equal
		bl PrintChar	
		
	.endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GBA
	
	.ifdef BuildGBA
	
		mov r3,#0x4000130	;GBA Keys 
		ldrh r0,[r3]		;------LRDULRSsBA
		bl MonitorR0		

		mov r1,#5
Delay:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		beq Delay			;Wait for Vblank End
Delay2:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		bne Delay2			;Wait for Vblank Start
		subs r1,r1,#1
		bne delay
	.endif

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	NDS
		
	.ifdef BuildNDS
		mov r3,#0x4000130	;GBA Keys 
		ldrh r0,[r3]		;------LRDULRSsBA
		bl MonitorR0		
	
		mov r3,#joyData	;Extra NDS buttons only accessible via ARM7 (done by arm7 program)
		ldrh r0,[r3]	;--------HP--D-YX
		bl MonitorR0
		
		bl newline
		
		mov r3,#PenData		;NDS Pen X
		ldr r0,[r3]
		bl MonitorR0
		
		mov r3,#PenData+4	;NDS Pen Y
		ldr r0,[r3]
		bl MonitorR0
 
		mov r1,#5
Delay:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		beq Delay			;Wait for Vblank End
Delay2:
		mov r0,#0x4000004
		ldrh r0,[r0]
		ands r0,r0,#1
		bne Delay2			;Wait for Vblank Start
		subs r1,r1,#1
		bne delay
	.endif
	
	b Again
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



MonitorR0:	
	STMFD sp!,{lr}			;Push Regs
		bl ShowHex32	
		mov r0,#32 					;Ascii Space
		bl PrintChar
	LDMFD sp!,{pc}			;Pop Regs and return	

	
	.incbin "V1_Monitor.asm"
	.incbin "V1_BitmapMemory_ref.asm"

BitmapFont:
	.incbin "Font96.FNT"
	
SpriteTest:
