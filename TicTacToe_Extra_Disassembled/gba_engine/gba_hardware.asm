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