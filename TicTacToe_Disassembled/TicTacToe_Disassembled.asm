; --- COMPILER GENERATED MAIN FILE --- 

; 1. Load Constants & WRAM mapping (grid a = (3,3))
.include "boa_grid_config.asm"

; 2. Load the GBA Boot Header
.include "gba_header.asm"

; --- MAIN BOA EXECUTION BLOCK; --- 
; Maps to def Turn(symbol) and the while selecting loop

ProgramStart:
	mov sp,#0x03000000			; Init Stack Pointer 

	bl ScreenInit				; Enter Mode 3 and clear screen
	bl InitGameState			; Clear board memory and set first turn
	bl DrawGrid					; Draw static 3x3 grid lines
	bl ShowCursor				; XOR draw the cursor at starting tile [0,0]

TurnLoop:
	bl WaitVBlankStart			; Sync update to VBlank to avoid visible tearing
	bl ReadJoystick				; Read input in project format: SSBARLDU (0 means pressed)

	tst r0,#0b00000100			; bit2 = LEFT
	bne TurnCheckRight
	bl MoveLeft					; Move one tile left if inside bounds
	bl WaitForReleaseAny		; wait until direction/A released
	b TurnLoop

TurnCheckRight:
	tst r0,#0b00001000			; bit3 = RIGHT
	bne TurnCheckUp
	bl MoveRight				; Move one tile right if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop  

TurnCheckUp:
	tst r0,#0b00000001			; bit0 = UP
	bne TurnCheckDown           
	bl MoveUp					; Move one tile up if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop

TurnCheckDown:
	tst r0,#0b00000010			; bit1 = DOWN
	bne TurnCheckA
	bl MoveDown					; Move one tile down if inside bounds
	bl WaitForReleaseAny		; release press
	b TurnLoop

TurnCheckA:
	tst r0,#0b00010000			; bit4 = A button (place symbol)
	bne TurnLoop
	bl TryPlaceSymbol			; Try write X/O on selected tile (ignored if occupied)
	bl WaitForReleaseAny		; release press
	cmp r9,#1					; Did we successfully place a symbol?

	beq TurnLoopExit			; YES: Exit the "while selecting" loop!
	b TurnLoop
TurnLoopExit:
	bl SwitchTurn				; Explicitly switch the turn
	b TurnLoop					; Restart the loop for the next player
; ---  INCLUDED COMPILED LIBRARIES AND BOA LOGIC  --- 

; ---
; Functionality: Initializes the WRAM memory to 0 (empty cells) and 
;                renders the static 3x3 grid lines onto the screen
; Boa Mapping:   Triggered by the setup phase of `grid a = (3,3)`
.include "boa_grid_funcs.asm"
;                                                               ---

; ---
; Functionality: Contains boundary checking (0 to 2) and coordinate 
;                updates for the logical grid, plus cursor redrawing
; Boa Mapping:   Maps directly to the Tile Operations in BNF Syntax
;                and movement logic
.include "boa_movement.asm"
;                                                               ---

; ---
; Functionality: Converts 2D grid coordinates to a 1D WRAM array index,
;                checks if a tile is occupied, updates the WRAM state, 
;                and calculates the pixel geometry to draw 'X' or 'O'
; Boa Mapping:   Maps to `Draw(symbol)` and the turn switching logic
.include "boa_drawing.asm"
;                                                               ---

; ---
; Functionality: Generic hardware rendering logic (DrawVerticalLine, 
;                DrawHorizontalLine, PlotWhitePixel, ShowSprite)
; Boa Mapping:   No direct mapping. Supports the graphical 
;                operations required by the Boa drawing files
.include "gba_graphics.asm"
;                                                               ---

; ---
; Functionality: Core GBA system routines. Enters Mode 3, waits for 
;                VBlank to prevent screen tearing, and polls the KEYINPUT 
;                register (0x4000130) for button presses.
; Boa Mapping:   No direct mapping. Supports the input evaluation 
;                in the if/elif chains
.include "gba_hardware.asm"
;                                                               ---