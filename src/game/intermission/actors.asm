; Intermission actor movement, wrapping, and visibility

sub_E9A5_update_intermission_actor_positions:		; was: sub_E9A5
    LoadPointer ram_0000, ram_obj_position
    LoadPointer ram_0002, ram_spr_position
    LDX #$00
; Iterate to next actor slot
bra_E9B7_loop_update_next_actor:		; was: bra_E9B7_loop
    LDY #$00
    LDA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    BEQ bra_EA00_advance_actor_pointer
    INY
    LDA (ram_0000),Y    ; 001B 001F 0023 0027 002B
    CLC
    ADC (ram_0002),Y    ; 0275 0279 027D 0281 0285
    STA (ram_0002),Y    ; 0275 0279 027D 0281 0285
    DEY
    LDA (ram_0000),Y    ; 001A 001E 0022 0026 002A
    ADC (ram_0002),Y    ; 0274 0278 027C 0280 0284
    STA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    CMP #$C0
    BCC bra_E9DA_actor_in_visible_range
; Mark actor attribute when crossing horizontal boundary
bra_E9D0_loop_mark_actor_horizontal_wrap:		; was: bra_E9D0_loop
    LDA #$20
    ORA ram_0292,X
    STA ram_0292,X
    BNE bra_E9E6_continue_actor_bounds_check    ; jmp
; Actor within visible horizontal range
bra_E9DA_actor_in_visible_range:		; was: bra_E9DA
    CMP #$40
    BCC bra_E9D0_loop_mark_actor_horizontal_wrap
    LDA #$DF
    AND ram_0292,X
    STA ram_0292,X
; Continue with vertical/offscreen bounds checks
bra_E9E6_continue_actor_bounds_check:		; was: bra_E9E6
    LDY #$00
    LDA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    CMP #$FC
    BCC bra_E9FC_actor_not_outside_vertical_bounds
; Reset offscreen actor position and velocity
bra_E9EE_loop_reset_offscreen_actor:		; was: bra_E9EE_loop
    LDA #$00
    STA (ram_0002),Y    ; 0274 0278 027C 0280 0284
    STA (ram_0000),Y    ; 001A 001E 0022 0026 002A
    INY
    STA (ram_0000),Y    ; 001B 001F 0023 0027 002B
    INY
    STA (ram_0002),Y    ; 0276 027A 027E 0282 0286
    BNE bra_EA00_advance_actor_pointer
; Actor remains within vertical bounds
bra_E9FC_actor_not_outside_vertical_bounds:		; was: bra_E9FC
    CMP #$04
    BCC bra_E9EE_loop_reset_offscreen_actor
; Advance object/sprite pointers to next actor
bra_EA00_advance_actor_pointer:		; was: bra_EA00
    LDA ram_0000
    CLC
    ADC #< $0004
    STA ram_0000
    LDA ram_0001
    ADC #> $0004
    STA ram_0001
    LDA ram_0002
    CLC
    ADC #< $0004
    STA ram_0002
    LDA ram_0003
    ADC #> $0004
    STA ram_0003
    INX
    CPX #$05
    BNE bra_E9B7_loop_update_next_actor
    RTS



; Dispatch intermission tile animation script by scene id
; Animation dispatch is scene-aligned with tbl_E769_intermission_scene_handlers
; and usually keyed by the same ram_0088 substate.
