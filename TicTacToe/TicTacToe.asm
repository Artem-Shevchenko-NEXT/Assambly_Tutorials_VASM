; TicTacToe screen mode3
; WRAM works by making, each byte address store one game value.
.equ StateBase,0x02000000	; Base address for our WRAM 
.equ GridCellsCount,9		; 9 bytes for 3x3 logical board cells
.equ CursorX_Off,9			; Offset +9: cursor X tile index (0..2)
.equ CursorY_Off,10			; Offset +10: cursor Y tile index (0..2)
.equ CurrentSymbol_Off,11	; Offset +11: whose turn (1='x', 2='o')

.equ CellEmpty,0				; Stored value for empty tile
.equ CellX,1					; Stored value for X tile
.equ CellO,2					; Stored value for O tile

	.org  0x08000000     ; GBA ROM Address starts at 0x08000000

; --- Borrowed from Sprite_Moving.asm ---
	b	ProgramStart	;000h    4     ROM Entry Point  (32bit ARM branch opcode, eg. "B rom_start")

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

    ;		123456789012
    .ascii "LEARNASM.NET";0A0h    12    Game Title       (uppercase ascii, max 12 characters)
    .ascii "0000"	;0ACh    4     Game Code        (uppercase ascii, 4 characters)
    .ascii "00"		;0B0h    2     Maker Code       (uppercase ascii, 2 characters)
	.byte 0x96		;0B2h    1     Fixed value      (must be 96h, required!)
	.byte 0			;0B3h    1     Main unit code   (00h for current GBA models)
	.byte 0			;0B4h    1     Device type      (usually 00h) (bit7=DACS/debug related)
	.space 7		;0B5h    7     Reserved Area    (should be zero filled)
	.byte 0			;0BCh    1     Software version (usually 00h)
	.byte 0			;0BDh    1     Complement check (header checksum, required!)
	.word 0			;0BEh    2     Reserved Area    (should be zero filled)
	.long 0			;0C0h    4     RAM Entry Point  (32bit ARM branch opcode, eg. "B ram_start")
	.byte 0			;0C4h    1     Boot mode        (init as 00h - BIOS overwrites this value!)
	.byte 0			;0C5h    1     Slave ID Number  (init as 00h - BIOS overwrites this value!)
	.space 26		;0C6h    26    Not used         (seems to be unused)
	.long 0			;0E0h    4     JOYBUS Entry Pt. (32bit ARM branch opcode, eg. "B joy_start")

ProgramStart:
	mov sp,#0x03000000			; Init Stack Pointer 

	bl ScreenInit				; Enter Mode 3 and clear screen
	bl InitGameState			; Clear board memory and set first turn
	bl DrawGrid					; Draw static 3x3 grid lines
	bl ShowCursor				; XOR draw the cursor at starting tile [0,0]

TurnLoop:
	bl WaitVBlankStart			; Sync update to VBlank to avoid visible tearing
	bl ReadJoystick				; Read input in project format: SSBARLDU (0 means pressed)

	tst r0,#0b00000100			; bit2 = LEFT
	bne TurnCheckRight
	bl MoveLeft					; Move one tile left if inside bounds
	bl WaitForReleaseAny		; wait until direction/A released
	b TurnLoop

TurnCheckRight:
	tst r0,#0b00001000			; bit3 = RIGHT
	bne TurnCheckUp
	bl MoveRight				; Move one tile right if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop  

TurnCheckUp:
	tst r0,#0b00000001			; bit0 = UP
	bne TurnCheckDown           
	bl MoveUp					; Move one tile up if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop

TurnCheckDown:
	tst r0,#0b00000010			; bit1 = DOWN
	bne TurnCheckA
	bl MoveDown					; Move one tile down if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop

TurnCheckA:
	tst r0,#0b00010000			; bit4 = A button (place symbol)
	bne TurnLoop
	bl TryPlaceSymbol			; Try write X/O on selected tile (ignored if occupied)
	bl WaitForReleaseAny		; release press
	b TurnLoop

InitGameState:
	STMFD sp!,{r0-r3,lr}			; Save registers + return address (lr)
		mov r11,#StateBase		    ; r11 points to first state byte in WRAM
		mov r0,#0					; r0 holds value 0 (empty)
		mov r1,#GridCellsCount	    ; r1 is loop counter for 9 grid cells
InitGameStateLoop:
		strb r0,[r11],#1			; Write empty cell, then advance pointer by 1 byte
		subs r1,r1,#1				; Decrement remaining cells
		bne InitGameStateLoop

		mov r0,#0					; Reuse 0 for cursor initialization
		strb r0,[r11]				; Write CursorX = 0 at offset +9
		strb r0,[r11,#1]			; Write CursorY = 0 at offset +10

		mov r0,#CellX				; First turn starts as X
		strb r0,[r11,#2]			; Write CurrentSymbol = X at offset +11
	LDMFD sp!,{r0-r3,pc}			; Restore registers and return

DrawGrid:
	STMFD sp!,{r0-r5,lr}			; Save working registers used by repeated draw calls
		mov r3,#0x7F00				; Build white color constant high bits
		add r3,r3,#0xFF			    ; White color = 0x7FFF

		mov r1,#80				; Vertical separator #1 X position
		mov r2,#0				; Start at top row
		mov r4,#160				; Full screen height in pixels
		bl DrawVerticalLine		; Draw x=80 line

		mov r1,#160				; Vertical separator #2 X position
		mov r2,#0				; Start at top row
		mov r4,#160				; Full screen height
		bl DrawVerticalLine		; Draw x=160 line

		mov r1,#0				; Horizontal line starts at left edge
		mov r2,#53				; Horizontal separator #1 Y position
		mov r4,#240				; Full screen width in pixels
		bl DrawHorizontalLine	; Draw y=53 line

		mov r1,#0				; Horizontal line starts at left edge
		mov r2,#106				; Horizontal separator #2 Y position
		mov r4,#240				; Full screen width
		bl DrawHorizontalLine	; Draw y=106 line
	LDMFD sp!,{r0-r5,pc}			; Restore and return

DrawVerticalLine:
	; IN: R1=X, R2=YStart, R3=Color, R4=Height
	STMFD sp!,{r0-r6,lr}		; Save loop helpers and return address
		bl GetScreenPos			; Convert (X,YStart) into VRAM pointer r10
		mov r6,r4				; r6 counts remaining pixels in this column
DrawVerticalLineLoop:
		strh r3,[r10]				; Write one 16-bit pixel color to VRAM
		add r10,r10,#240*2		    ; Move down exactly one scanline (480 bytes)
		subs r6,r6,#1				; Decrement remaining height
		bne DrawVerticalLineLoop
	LDMFD sp!,{r0-r6,pc}			; Restore and return

DrawHorizontalLine:
	; IN: R1=XStart, R2=Y, R3=Color, R4=Width
	STMFD sp!,{r0-r6,lr}		; Save loop helpers and return address
		bl GetScreenPos			; Convert (XStart,Y) into VRAM pointer r10
		mov r6,r4				; r6 counts remaining pixels in this row
DrawHorizontalLineLoop:
		strh r3,[r10],#2			; Write one pixel, then move right by 2 bytes
		subs r6,r6,#1				; Decrement remaining width
		bne DrawHorizontalLineLoop
	LDMFD sp!,{r0-r6,pc}			; Restore and return

MoveLeft:
	STMFD sp!,{r0-r2,lr}			; Save temporary registers + return address
		mov r11,#StateBase		    ; Point to WRAM game state base
		ldrb r0,[r11,#CursorX_Off]	; Read current cursor X tile index
		cmp r0,#0					; Checks if were at left boundary?
		beq MoveLeftDone
		bl ShowCursor			    ; XOR hide old cursor (draw same sprite again)
		mov r11,#StateBase		    ; Reload base after subroutine calls
		ldrb r0,[r11,#CursorX_Off]	; Read X again
		sub r0,r0,#1				; X = X - 1 (move one tile left)
		strb r0,[r11,#CursorX_Off]	; Write updated X back to WRAM
		bl ShowCursor			    ; XOR show cursor at new location
MoveLeftDone:
	LDMFD sp!,{r0-r2,pc}			; Restore registers and return

MoveRight:
	; Same logic as MoveLeft, but boundary is x=2 and update is X = X + 1.
	STMFD sp!,{r0-r2,lr}			; Save temporary registers + return address
		mov r11,#StateBase		    ; Point to WRAM game state
		ldrb r0,[r11,#CursorX_Off]	; Read cursor X
		cmp r0,#2					; Checks if were at right boundary?
		beq MoveRightDone
		bl ShowCursor			    ; Remove the old cursor
		mov r11,#StateBase
		ldrb r0,[r11,#CursorX_Off]
		add r0,r0,#1				; X = X + 1
		strb r0,[r11,#CursorX_Off]	; Save new X
		bl ShowCursor			    ; Show the new cursor position
MoveRightDone:
	LDMFD sp!,{r0-r2,pc}			; Restore registers and return

MoveUp:
	; Same logic as MoveLeft, but operating on Y with top boundary y=0.
	STMFD sp!,{r0-r2,lr}			; Save temporary registers + return address
		mov r11,#StateBase		    ; Point to WRAM game state
		ldrb r0,[r11,#CursorY_Off]	; Read cursor Y
		cmp r0,#0					; Checks if were at top boundary?
		beq MoveUpDone
		bl ShowCursor			    ; Remove the old cursor
		mov r11,#StateBase
		ldrb r0,[r11,#CursorY_Off]
		sub r0,r0,#1				; Y = Y - 1
		strb r0,[r11,#CursorY_Off]	; Save new Y
		bl ShowCursor			    ; Show the new cursor position
MoveUpDone:
	LDMFD sp!,{r0-r2,pc}			; Restore registers and return

MoveDown:
	; Same logic as MoveLeft, but boundary is y=2 and update is Y = Y + 1.
	STMFD sp!,{r0-r2,lr}			; Save temporary registers + return address
		mov r11,#StateBase		    ; Point to WRAM game state
		ldrb r0,[r11,#CursorY_Off]	; Read cursor Y
		cmp r0,#2					; Checks if were at bottom boundary?
		beq MoveDownDone
		bl ShowCursor			    ; Remove the old cursor
		mov r11,#StateBase
		ldrb r0,[r11,#CursorY_Off]
		add r0,r0,#1				; Y = Y + 1
		strb r0,[r11,#CursorY_Off]	; Save new Y
		bl ShowCursor			    ; Show the new cursor position
MoveDownDone:
	LDMFD sp!,{r0-r2,pc}			; Restore registers and return

TryPlaceSymbol:
	STMFD sp!,{r0-r8,r11,lr}	    ; Save all temporaries used in index math + drawing calls
		mov r11,#StateBase		    ; Point to WRAM state base
		ldrb r6,[r11,#CursorX_Off]	; r6 = cursor X tile (0..2)
		ldrb r7,[r11,#CursorY_Off]	; r7 = cursor Y tile (0..2)

		add r5,r7,r7,lsl #1		    ; r5 = y + (y<<1) = y*3
		add r5,r5,r6				; r5 = y*3 + x (final 1D board index 0..8)

		ldrb r3,[r11,r5]			; Read current board value at selected tile
		cmp r3,#CellEmpty			; Is tile empty?
		bne TryPlaceSymbolDone		; Option 2: ignore A-press on occupied tile

		bl ShowCursor			    ; XOR hide cursor before drawing X/O

		mov r11,#StateBase		    ; Reload WRAM state base
		ldrb r4,[r11,#CurrentSymbol_Off]	; r4 = current symbol (X or O)
		strb r4,[r11,r5]			; Save logical symbol in board memory

		mov r0,r6					; r0 = tile X for renderer
		mov r1,r7					; r1 = tile Y for renderer
		mov r2,r4					; r2 = symbol value for renderer
		bl DrawSymbolInCell		; Draw X/O pixels on screen

		cmp r4,#CellX			; If current was X...
		moveq r4,#CellO			; ...next becomes O
		movne r4,#CellX			; Else next becomes X
		mov r11,#StateBase		; Reload WRAM state base
		strb r4,[r11,#CurrentSymbol_Off]	; Save next turn symbol

		bl ShowCursor			; XOR show cursor again
TryPlaceSymbolDone:
	LDMFD sp!,{r0-r8,r11,pc}	; Restore registers and return

DrawSymbolInCell:
	; IN: R0=CellX(0..2), R1=CellY(0..2), R2=Symbol(1='x',2='o')
	STMFD sp!,{r0-r9,lr}			; Save temps used for geometry math
		mov r3,#80					; Tile width in pixels (240/3)
		mul r6,r0,r3				; r6 = cellX * 80
		add r6,r6,#26			    ; Move inside tile to symbol start X

		mov r3,#53					; Tile height approx (160/3)
		mul r7,r1,r3				; r7 = cellY * 53
		add r7,r7,#12			    ; Move inside tile to symbol start Y

		cmp r2,#CellX				; Branch by symbol type
		beq DrawSymbolAsX

DrawSymbolAsO:
		mov r3,#0x7F00				; Build white color high bits
		add r3,r3,#0xFF			    ; White = 0x7FFF

		mov r1,r6					; Start X of top edge
		mov r2,r7					; Start Y of top edge
		mov r4,#28				    ; Edge width
		bl DrawHorizontalLine	    ; Top stroke line 1

		mov r1,r6					; Start X of top edge
		add r2,r7,#1				; Next row (thickness = 2)
		mov r4,#28				    ; Edge width
		bl DrawHorizontalLine	    ; Top stroke line 2

		mov r1,r6					; Start X of bottom edge
		add r2,r7,#26			    ; Bottom row 1
		mov r4,#28				    ; Edge width
		bl DrawHorizontalLine	    ; Bottom stroke line 1

		mov r1,r6					; Start X of bottom edge
		add r2,r7,#27			    ; Bottom row 2
		mov r4,#28				    ; Edge width
		bl DrawHorizontalLine	    ; Bottom stroke line 2

		mov r1,r6					; Left edge X
		add r2,r7,#2				; Start below top thickness
		mov r4,#24				    ; Side height
		bl DrawVerticalLine		    ; Left stroke line 1

		add r1,r6,#1				; Left edge X+1 (thickness = 2)
		add r2,r7,#2				; Same side start Y
		mov r4,#24				    ; Side height
		bl DrawVerticalLine		    ; Left stroke line 2

		add r1,r6,#26			    ; Right edge X
		add r2,r7,#2				; Side start Y
		mov r4,#24				    ; Side height
		bl DrawVerticalLine		    ; Right stroke line 1

		add r1,r6,#27			    ; Right edge X+1 (thickness = 2)
		add r2,r7,#2				; Side start Y
		mov r4,#24				    ; Side height
		bl DrawVerticalLine		    ; Right stroke line 2
		b DrawSymbolDone

DrawSymbolAsX:
		mov r4,#0					; r4 is loop counter i, starting from 0
DrawSymbolAsXLoop:
		add r1,r6,r4				; Main diagonal X = startX + i
		add r2,r7,r4				; Main diagonal Y = startY + i
		bl PlotWhitePixel		    ; Draw main diagonal pixel

		mov r8,#27					; Last offset index in 28-pixel span
		sub r8,r8,r4				; r8 = 27 - i for anti-diagonal
		add r1,r6,r8				; Anti-diagonal X = startX + (27 - i)
		add r2,r7,r4				; Anti-diagonal Y = startY + i
		bl PlotWhitePixel		    ; Draw anti-diagonal pixel

		add r4,r4,#1				; i++
		cmp r4,#28					; Continue until i reaches 28
		bcc DrawSymbolAsXLoop

DrawSymbolDone:
	LDMFD sp!,{r0-r9,pc}			; Restore geometry registers and return

PlotWhitePixel:
	; IN: R1=X, R2=Y
	STMFD sp!,{r0-r3,lr}			; Save scratch regs used by color/address calc
		mov r3,#0x7F00				; Build white color high bits
		add r3,r3,#0xFF			    ; White color = 0x7FFF
		bl GetScreenPos			    ; Convert (X,Y) to VRAM pointer r10
		strh r3,[r10]				; Write one white pixel
	LDMFD sp!,{r0-r3,pc}			; Restore scratch regs and return

ShowCursor:
	STMFD sp!,{r0-r7,r8-r10,lr}	; Save caller state; ShowSprite uses several temp regs
		mov r11,#StateBase		; Point to WRAM game state
		ldrb r0,[r11,#CursorX_Off]	; Read logical cursor X tile (0..2)
		ldrb r1,[r11,#CursorY_Off]	; Read logical cursor Y tile (0..2)

		mov r2,#80					; Tile width in pixels
		mul r8,r0,r2				; Pixel X base = tileX * 80
		add r8,r8,#40			    ; Move to tile center X

		mov r2,#53					; Tile height in pixels
		mul r9,r1,r2				; Pixel Y base = tileY * 53
		add r9,r9,#26			    ; Move to tile center Y

		sub r8,r8,#4			; Convert center X -> sprite top-left X (8x8 sprite)
		sub r9,r9,#4			; Convert center Y -> sprite top-left Y

		bl ShowSprite			; XOR draw/erase cursor sprite at (r8,r9)
	LDMFD sp!,{r0-r7,r8-r10,pc}	; Restore caller state and return

; --- Borrowed from Sprite_Moving.asm ---
;Xor Sprite, drawing twice will remove sprite from screen.
ShowSprite:
	STMFD sp!,{r1-r7,r10,lr}	; Save all regs this routine mutates
	mov r10,#0x06000000 		; VRAM base address (Mode 3)

	mov r1,#2					; 2 bytes per 16-bit pixel
	mul r2,r1,r8				; r2 = x * 2 bytes
	add r10,r10,r2				; Move pointer to requested X position

	mov r1,#240*2				; One scanline = 240 pixels * 2 bytes
	mul r2,r1,r9				; r2 = y * 480 bytes
	add r10,r10,r2				; Move pointer to requested Y position

	ldr r1,SpriteAddress		; r1 points to sprite pixel data
	mov r6,#8					; Height loop count (8 rows)
Sprite_NextLine:
	mov r5,#8					; Width loop count (8 pixels per row)

	STMFD sp!,{r10}				; Save row start address before horizontal loop
Sprite_NextByte:
		ldrH r3,[r1],#2			; Read next sprite pixel and advance source pointer
		ldrH r2,[r10]			; Read current destination pixel from VRAM
		eor r3,r3,r2			; XOR sprite with screen pixel
		strH r3,[r10],#2		; Write XOR result and move right one pixel

		subs r5,r5,#1			; Decrement remaining pixels in this row
		bne Sprite_NextByte
	LDMFD sp!,{r10}				; Restore row start pointer
	add r10,r10,#240*2			; Move down one full scanline (480 bytes)
	subs r6,r6,#1				; Decrement remaining rows
	bne Sprite_NextLine			;Y loop
	LDMFD sp!,{r1-r7,r10,pc}	; Restore all and return

SpriteAddress:
	.long CursorSprite			;Address of Sprite

; White cursor border, transparent center (0x0000)
CursorSprite:
	.word 0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7FFF
	.word 0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF,0x7FFF

; --- Borrowed from Game_Example.asm ---
ReadJoystick:		
	STMFD sp!,{lr}				; Save return address (routine uses BL-style return)
		mov r3,#0x4000130			; KEYINPUT register address
		ldrh r2,[r3]				; Raw bits:  (0 = pressed)
		and r1,r2,#0b0000000011000000	; Extract Up/Down bits
		mov r0,r1,lsr #6			; Place U/D into output bits 0..1
		and r1,r2,#0b0000000000100000	; Extract Left bit
		orr r0,r0,r1,lsr #3		; Place L into output bit 2
		and r1,r2,#0b0000000000010000	; Extract Right bit
		orr r0,r0,r1,lsr #1		; Place R into output bit 3
		and r1,r2,#0b0000000000001111	; Extract SsBA bits
		orr r0,r0,r1,lsl #4		; Place SsBA into output bits 4..7
	LDMFD sp!,{pc}				; Return with normalized SSBARLDU in r0

; --- Borrowed from Game_Example.asm (button release pattern) ---
; --- Input format relies on ReadJoystick mapping from Game_Example.asm ---
WaitForReleaseAny:
	STMFD sp!,{lr}				; Save return address while we poll in a loop
WaitForReleaseAnyLoop:
		bl ReadJoystick			    ; Read current normalized input bits
		and r1,r0,#0b00011111		; Isolate RLDU+A bits only (bits 0..4)
		cmp r1,#0b00011111		    ; All 1 means all released (active-low scheme)
		bne WaitForReleaseAnyLoop	;Repeat until RLDU+A released
	LDMFD sp!,{pc}				    ; Return once release condition is met

; --- Borrowed/Adapted from Joypad_Controls.asm (VBlank) ---
; --- Integrated with button processing flow from Game_Example.asm ---
WaitVBlankStart:
	STMFD sp!,{r0-r1,lr}			; Save temporary regs used for register polling
Delay:
	mov r0,#0x4000004			; DISPSTAT register address
	ldrh r1,[r0]				; Read LCD status flags
	ands r1,r1,#1				; Test VBlank flag (bit0)
	bne Delay				    ; Stay here while currently in VBlank
Delay2:
	mov r0,#0x4000004			; DISPSTAT register address
	ldrh r1,[r0]				; Read LCD status again
	ands r1,r1,#1				; Test VBlank flag (bit0)
	beq Delay2				    ; Wait until next VBlank begins
	LDMFD sp!,{r0-r1,pc}		; Restore regs and return

; --- Borrowed from Bitmap_Graphics_16_bit.asm ---
GetScreenPos:
	; IN: R1 = X, R2 = Y
	; OUT: R10 = Screen Address
	STMFD sp!,{r2}				; Save original r2 because we reuse it for math
		STMFD sp!,{r1}			; Save original r1 because we reuse it for math
			mov r10,#0x06000000 ; Start from Mode 3 VRAM base
			mov r1,#240*2		; Bytes per scanline (240 pixels * 2 bytes)
			mul r2,r1,r2		; r2 = Y offset in bytes
		LDMFD sp!,{r1}			; Restore X value
		add r10,r10,r1,lsl #1   ; Add X offset in bytes (X*2)
	add r10,r10,r2				; Add Y offset in bytes
	LDMFD sp!,{r2}				; Restore original r2
	MOV pc,lr

; --- Borrowed from Bitmap_Graphics_16_bit.asm ---
ScreenInit:
	STMFD sp!,{r0-r12, lr}		; Save broad register set used in init path
		mov r4,#0x04000000  	; DISPCNT register address
		mov r2,#0x403    		; Mode3 + BG2 enable
		str	r2,[r4]				; Write display mode configuration

		bl cls					; Clear framebuffer to black

	LDMFD sp!,{r0-r12, pc}		; Restore and return

; --- Borrowed from Bitmap_Graphics_16_bit.asm (black background adapted) ---
cls:
	mov r0, #0x06000000			; Destination pointer = Mode 3 VRAM base
	mov r1, #0x00000000			; Fill value = black (two black pixels per 32-bit write)
	mov r2, #240*160/2			; Number of 32-bit writes to cover full screen

FillScreenLoop:
		str r1, [r0],#4			; Write two pixels, then advance pointer by 4 bytes
		subs r2, r2, #1			; Decrement remaining write count
		bne FillScreenLoop
	MOV pc,lr
