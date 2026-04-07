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