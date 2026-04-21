TryPlaceSymbol:
	STMFD sp!,{r0-r8,r11,lr}	    ; Save all temporaries used in index math + drawing calls
		mov r9,#0					; Set default return flag to 0 (Failed/Occupied)

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
		bl DrawSymbolInCell			; Draw X/O pixels on screen

		bl ShowCursor				; XOR show cursor again
		mov r9,#1					; Set return flag to 1 (Success!)
TryPlaceSymbolDone:
	LDMFD sp!,{r0-r8,r11,pc}	; Restore registers and return
SwitchTurn:
	STMFD sp!,{r4,r11,lr}			; Save registers used for math
		mov r11,#StateBase		    ; Point to WRAM state base
		ldrb r4,[r11,#CurrentSymbol_Off] ; Read current symbol

		cmp r4,#CellX			    ; If current was X...
		moveq r4,#CellO			    ; ...next becomes O
		movne r4,#CellX			    ; Else next becomes X
		
		strb r4,[r11,#CurrentSymbol_Off] ; Save next turn symbol back to WRAM
	LDMFD sp!,{r4,r11,pc}			; Restore registers and return

DrawSymbolInCell:
	; IN: R0=CellX(0..2), R1=CellY(0..2), R2=ASCII symbol byte (eg. 'x','o','L','M')
	STMFD sp!,{r0-r9,lr}			; Save temps used for tile geometry and call setup
		mov r3,#80					; Tile width in pixels (240/3)
		mul r6,r0,r3				; r6 = cellX * 80
		add r6,r6,#FontOffsetX	    ; Move to centered character start X inside tile

		mov r3,#53					; Tile height approx (160/3)
		mul r7,r1,r3				; r7 = cellY * 53
		add r7,r7,#FontOffsetY	    ; Move to centered character start Y inside tile

		mov r0,r2					; r0 = ASCII symbol for character lookup
		mov r1,r6					; r1 = character top-left start X in pixels
		mov r2,r7					; r2 = character top-left start Y in pixels
		bl DrawScaledChar			; Render 8x8 character scaled to FontScale x FontScale pixels
	LDMFD sp!,{r0-r9,pc}			; Restore geometry registers and return

; --- Revamped from Hello_World.asm ---
DrawScaledChar:
	; IN: R0=ASCII byte, R1=StartX, R2=StartY
	STMFD sp!,{r0-r12,lr}			; Save all loop vars and temporaries used in nested loops
		adr r8,BitmapFont			; r8 points to first character (ASCII 32)
		sub r0,r0,#32				; Convert ASCII code to bitmap index base (space is first)
		mov r0,r0,lsl #3			; Multiply character index by 8 bytes per character
		add r8,r8,r0				; r8 now points to selected character row 0

		mov r6,r1					; Preserve character start X across loops and draw calls
		mov r7,r2					; Preserve character start Y across loops and draw calls

		mov r9,#0					; r9 = character row index (0..7)
DrawScaledCharRowLoop:
		ldrb r4,[r8,r9]				; Read one character row byte (8 one-bit pixels)
		mov r11,#0x80				; Bit mask starts at left-most bit 1000 0000b
		mov r12,#0					; r12 = character column index (0..7)
DrawScaledCharColLoop:
		tst r4,r11					; Test current font bit: 1 means draw this pixel block
		beq DrawScaledCharNextCol	; If bit is 0 we skip drawing and move to next bit

		mov r3,#FontScale			; FontScale is used in both X and Y multiply math
		mul r1,r12,r3				; Scaled X offset = column * FontScale
		add r1,r1,r6				; Absolute X = characterStartX + scaled X offset
		mul r2,r9,r3				; Scaled Y offset = row * FontScale
		add r2,r2,r7				; Absolute Y = characterStartY + scaled Y offset

		bl DrawScaledPixel			; Draw one chunky white pixel (FontScale x FontScale)

DrawScaledCharNextCol:
		mov r11,r11,lsr #1			; Shift mask right so we test next bit in this row byte
		add r12,r12,#1				; Move to next character column
		cmp r12,#8					; Done all 8 bits for this row?
		bcc DrawScaledCharColLoop

		add r9,r9,#1				; Move to next character row byte
		cmp r9,#8					; Done all 8 rows for this character?
		bcc DrawScaledCharRowLoop
	LDMFD sp!,{r0-r12,pc}			; Restore caller state and return

DrawScaledPixel:
	; IN: R1=XStart, R2=YStart
	STMFD sp!,{r0-r5,lr}			; Save scratch regs; keep r5/r6 style safety for nested loops
		mov r3,#0x7F00				; Build white color high bits
		add r3,r3,#0xFF			    ; White = 0x7FFF
		mov r4,#FontScale			; Horizontal width of one chunky scaled pixel
		mov r5,#FontScale			; Vertical height of one chunky scaled pixel
DrawScaledPixelRowLoop:
		bl DrawHorizontalLine		; Draw one horizontal slice of the chunky pixel
		add r2,r2,#1				; Move down one scanline inside this scaled pixel block
		subs r5,r5,#1				; Decrement remaining scanlines in this block
		bne DrawScaledPixelRowLoop
	LDMFD sp!,{r0-r5,pc}			; Restore scratch regs and return