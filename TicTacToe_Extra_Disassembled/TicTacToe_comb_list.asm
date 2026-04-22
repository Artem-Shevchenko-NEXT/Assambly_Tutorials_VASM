; ---                    Old Combination               ---
; Combo 01: L -> R -> U -> D -> A (baseline order)

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

; ---                    New Combination               ---
; Combo 02: A -> L -> R -> U -> D (new order)

; ---
; Functionality: Specific condition representing an 'If' condition and its body.
; Boa Mapping:   `if InputA():`
.include "boa_nodes/conditions/boa_node_cond_if_a.asm"
; Boa Mapping:       `Draw(symbol)`
.include "boa_nodes/actions/boa_node_act_draw.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:       `selecting = False` (Breaks the loop if draw was successful)
.include "boa_nodes/conditions/boa_node_cond_break.asm"
; Boa Mapping:   (End of 'if' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"

;                                                               ---

; ---
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputLeft():`
.include "boa_nodes/conditions/boa_node_cond_if_left.asm"
; Boa Mapping:       `MoveLeft()`
.include "boa_nodes/actions/boa_node_act_move_left.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
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
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputUp():`
.include "boa_nodes/conditions/boa_node_cond_if_up.asm"
.include "boa_nodes/actions/boa_node_act_move_up.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputDown():`
.include "boa_nodes/conditions/boa_node_cond_if_down.asm"
.include "boa_nodes/actions/boa_node_act_move_down.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---                    New Combination               ---
; Combo 03: A(Left) -> L(Right) -> R(Draw) -> U(down) -> D (up)
; ---
; Functionality: Specific condition representing an 'If' condition and its body.
; Boa Mapping:   `if InputA():`
.include "boa_nodes/conditions/boa_node_cond_if_a.asm"
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
; Boa Mapping:   `elif InputLeft():`
.include "boa_nodes/conditions/boa_node_cond_if_left.asm"
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
; Boa Mapping:   `elif InputRight():`
.include "boa_nodes/conditions/boa_node_cond_if_right.asm"
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
; Boa Mapping:   (If the previouse condition wasn't true, skips down to this label)
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputUp():`
.include "boa_nodes/conditions/boa_node_cond_if_up.asm"
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
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputDown():`
.include "boa_nodes/conditions/boa_node_cond_if_down.asm"
; Boa Mapping:       `MoveUp()`
.include "boa_nodes/actions/boa_node_act_move_up.asm"
; Boa Mapping:       (Auto added to wait for the user to let go of the button)
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
; Boa Mapping:   (End of 'elif' block indent: jump back to the start of the while loop)
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---                    New Combination               ---
; Combo 04: R(Right) -> D(Draw) -> A(Down) -> L(Left) -> U(Up)
; ---
; Functionality: Specific condition representing an 'If' condition and its body.
; Boa Mapping:   `if InputRight():`
.include "boa_nodes/conditions/boa_node_cond_if_right.asm"
; Boa Mapping:       `MoveRight()`
.include "boa_nodes/actions/boa_node_act_move_right.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"

;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputDown():`
.include "boa_nodes/conditions/boa_node_cond_if_down.asm"
; Boa Mapping:       `Draw(symbol)`
.include "boa_nodes/actions/boa_node_act_draw.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/conditions/boa_node_cond_break.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
; Functionality: Specific AST nodes representing an 'Elif' condition and its body.
; Boa Mapping:   `elif InputA():`
.include "boa_nodes/conditions/boa_node_cond_if_a.asm"
; Boa Mapping:       `MoveDown()`
.include "boa_nodes/actions/boa_node_act_move_down.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_left.asm"
.include "boa_nodes/actions/boa_node_act_move_left.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_up.asm"
.include "boa_nodes/actions/boa_node_act_move_up.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---                    New Combination               ---
; Combo 05: U(Up) -> A(Right) -> D(Down) -> R()Left -> L(Draw)
; ---
; Functionality: Specific condition representing an 'If' condition and its body.
; Boa Mapping:   `if InputUp():`
.include "boa_nodes/conditions/boa_node_cond_if_up.asm"
; Boa Mapping:       `MoveUp()`
.include "boa_nodes/actions/boa_node_act_move_up.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"

;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_a.asm"
; Boa Mapping:       `MoveRight()`
.include "boa_nodes/actions/boa_node_act_move_right.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_down.asm"
.include "boa_nodes/actions/boa_node_act_move_down.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_right.asm"
; Boa Mapping:       `MoveLeft()`
.include "boa_nodes/actions/boa_node_act_move_left.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---

; ---
.include "boa_nodes/labels/boa_node_label_next_cond.asm"
.include "boa_nodes/conditions/boa_node_cond_if_left.asm"
; Boa Mapping:       `Draw(symbol)`
.include "boa_nodes/actions/boa_node_act_draw.asm"
.include "boa_nodes/actions/boa_node_act_wait_release.asm"
.include "boa_nodes/conditions/boa_node_cond_break.asm"
.include "boa_nodes/boa_node_jmp_loop.asm"
;                                                               ---