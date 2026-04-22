; --- Compiler To-Be Generated Main File --- 

; 1. Load Constants & WRAM mapping (grid a = (3,3))
.include "boa_lib/boa_grid_config.asm"

; 2. Load the GBA Boot Header
.include "gba_engine/gba_header.asm"

; --- Global Setup --- 
; The Python script calls grid a = (3,3) and Turn('X') globally.
; These are the standard library function calls right here.

	bl ScreenInit				; Enter Mode 3 and clear screen
	bl InitGameState			; Clear board memory and set first turn
	bl DrawGrid					; Draw static 3x3 grid lines
	bl ShowCursor				; XOR draw the cursor at starting tile [0,0]

; ---
; Functionality: The start of the main game loop. Waits for VBlank 
;                and reads the hardware keypad state.
; Boa Mapping:   `while selecting:`
.include "boa_nodes/boa_node_while_start.asm"
;                                                               ---

; ---
; Functionality: Specific condition representing an 'If' condition and its body.
; Boa Mapping:   `if InputLeft():` 
.include "boa_nodes/conditions/boa_node_cond_if_left.asm"
; Boa Mapping:       `MoveLeft()`
.include "boa_nodes/actions/boa_node_act_move_left.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'if' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"

;                                                               ---

; ---
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputRight():`
.include "boa_nodes/conditions/boa_node_cond_if_right.asm"
; Boa Mapping:       `MoveRight()`
.include "boa_nodes/actions/boa_node_act_move_right.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputUp():`
.include "boa_nodes/conditions/boa_node_cond_if_up.asm"
; Boa Mapping:       `MoveUp()`
.include "boa_nodes/actions/boa_node_act_move_up.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputDown():`
.include "boa_nodes/conditions/boa_node_cond_if_down.asm"
; Boa Mapping:       `MoveDown()`
.include "boa_nodes/actions/boa_node_act_move_down.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes combining an action with loop termination.
; Boa Mapping:   `elif InputA():`
.include "boa_nodes/conditions/boa_node_cond_if_a.asm"
; Boa Mapping:       `Draw(symbol)`
.include "boa_nodes/actions/boa_node_act_draw.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:       `selecting = False` (Breaks the loop if draw was successful)
.include "boa_nodes/conditions/boa_node_cond_break.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
; Functionality: Final fallthrough path for the if/elif chain.
;                If InputA() is NOT pressed (last condition failed),
;                control lands here and continues polling next condition.
; Boa Mapping:   (If no condition in the chain matched, continue while loop)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Boa Mapping:   (Loop continuation for no-match case)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---
; ---
; Boa Mapping:   (This label marks the exit point of the entire while loop)
.include "boa_nodes/labels/boa_node_label_exit.asm"
; Functionality: Explicitly changes the current symbol between players after the turn.
; Boa Mapping:   `if symbol == 'x': Turn('o') else: Turn('x')`
.include "boa_nodes/boa_node_switch_turn.asm"
;                                                               ---

; ---  Inlyses Compiled Libraries and BOA Logic  --- 

; ---
; Functionality: Initializes the WRAM memory to 0 (empty cells) and 
;                renders the static 3x3 grid lines onto the screen
; Boa Mapping:   Triggered by the setup phase of `grid a = (3,3)`
.include "boa_lib/boa_grid_funcs.asm"
;                                                               ---

; ---
; Functionality: Contains boundary checking (0 to 2) and coordinate 
;                updates for the logical grid, plus cursor redrawing
; Boa Mapping:   Maps directly to the Tile Operations in BNF Syntax
;                and movement logic
.include "boa_lib/boa_movement.asm"
;                                                               ---

; ---
; Functionality: Converts 2D grid coordinates to a 1D WRAM array index,
;                checks if a tile is occupied, updates the WRAM state, 
;                and calculates the pixel geometry to draw 'X' or 'O'
; Boa Mapping:   Maps to `Draw(symbol)` and the turn switching logic
.include "boa_lib/boa_drawing.asm"
;                                                               ---

; ---
; Functionality: Generic hardware rendering logic (DrawVerticalLine, 
;                DrawHorizontalLine, PlotWhitePixel, ShowSprite)
; Boa Mapping:   No direct mapping. Supports the graphical 
;                operations required by the Boa drawing files
.include "gba_engine/gba_graphics.asm"
;                                                               ---

; ---
; Functionality: Core GBA system routines. Enters Mode 3, waits for 
;                VBlank to prevent screen tearing, and polls the KEYINPUT 
;                register (0x4000130) for button presses.
; Boa Mapping:   No direct mapping. Supports the input evaluation 
;                in the if/elif chains
.include "gba_engine/gba_hardware.asm"
;                                                               ---