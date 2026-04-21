	tst r0,#0b00010000			; bit4 = A button (place symbol)
	bne TurnLoop
	bl TryPlaceSymbol
	bl WaitForReleaseAny
	cmp r9,#1
	beq TurnLoopExit
	b TurnLoop
TurnLoopExit:
