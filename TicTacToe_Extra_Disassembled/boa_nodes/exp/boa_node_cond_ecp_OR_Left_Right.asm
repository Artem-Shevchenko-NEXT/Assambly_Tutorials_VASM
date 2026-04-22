	; r0 format: SSBARLDU (0 means pressed)
	; RIGHT bit3 mask=0b00001000, LEFT bit2 mask=0b00000100

	tst r0,#0b00001000			; RIGHT pressed?
	beq 2f						; yes -> condition true
	tst r0,#0b00000100			; LEFT pressed?
	beq 2f						; yes -> condition true
	b 1f						; neither pressed -> fallthrough to next elif
2:
	; condition true, continue into action block directly