	; Condition: InputLeft() AND InputRight()
	; r0 format: SSBARLDU (0 = pressed)
	; Left  = bit2 (mask 0b00000100)
	; Right = bit3 (mask 0b00001000)

	tst r0,#0b00000100			; Left pressed?
	bne 1f						; if not pressed, condition false
	tst r0,#0b00001000			; Right pressed?
	bne 1f						; if not pressed, condition false
	; if both are pressed, fall through into action block