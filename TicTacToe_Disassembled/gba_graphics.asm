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

PlotWhitePixel:
	; IN: R1=X, R2=Y
	STMFD sp!,{r0-r3,lr}			; Save scratch regs used by color/address calc
		mov r3,#0x7F00				; Build white color high bits
		add r3,r3,#0xFF			    ; White color = 0x7FFF
		bl GetScreenPos			    ; Convert (X,Y) to VRAM pointer r10
		strh r3,[r10]				; Write one white pixel
	LDMFD sp!,{r0-r3,pc}			; Restore scratch regs and return

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