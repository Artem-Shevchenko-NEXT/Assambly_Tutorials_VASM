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