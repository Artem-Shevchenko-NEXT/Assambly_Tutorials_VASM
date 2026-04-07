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