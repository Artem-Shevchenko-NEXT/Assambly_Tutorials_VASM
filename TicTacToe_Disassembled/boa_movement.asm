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
