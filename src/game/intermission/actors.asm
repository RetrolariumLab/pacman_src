; Intermission actor movement, wrapping, and visibility

; Integrate fixed-point horizontal motion for five staged cutscene actors
; Inputs: object X pairs as velocities, staged sprite positions, actor attributes
; Outputs: staged X positions and tunnel attribute bit; offscreen slots are cleared
; Side effects: a zero staged X disables integration for that slot
; Clobbers: A, X, Y and zp_work0..zp_work3
sub_update_intermission_actor_positions:
    LoadPointer zp_work0, ram_obj_position
    LoadPointer zp_work2, ram_spr_position
    LDX #$00
; Iterate to next actor slot
bra_loop_update_next_actor:
    LDY #$00
    LDA (zp_work2),Y  ; 0274 0278 027C 0280 0284
    BEQ bra_advance_actor_pointer
    INY
    LDA (zp_work0),Y  ; 001B 001F 0023 0027 002B
    CLC
    ADC (zp_work2),Y  ; 0275 0279 027D 0281 0285
    STA (zp_work2),Y  ; 0275 0279 027D 0281 0285
    DEY
    LDA (zp_work0),Y  ; 001A 001E 0022 0026 002A
    ADC (zp_work2),Y  ; 0274 0278 027C 0280 0284
    STA (zp_work2),Y  ; 0274 0278 027C 0280 0284
    CMP #$C0
    BCC bra_actor_in_visible_range
; Mark actor attribute when crossing horizontal boundary
bra_loop_mark_actor_horizontal_wrap:
    LDA #$20
    ORA ram_actor_sprite_attrs,X
    STA ram_actor_sprite_attrs,X
    BNE bra_continue_actor_bounds_check  ; jmp
; Actor within visible horizontal range
bra_actor_in_visible_range:
    CMP #$40
    BCC bra_loop_mark_actor_horizontal_wrap
    LDA #$DF
    AND ram_actor_sprite_attrs,X
    STA ram_actor_sprite_attrs,X
; Continue with staged-X offscreen bounds checks
bra_continue_actor_bounds_check:
    LDY #$00
    LDA (zp_work2),Y  ; 0274 0278 027C 0280 0284
    CMP #$FC
    BCC bra_actor_not_outside_vertical_bounds
; Reset offscreen actor position and velocity
bra_loop_reset_offscreen_actor:
    LDA #$00
    STA (zp_work2),Y  ; 0274 0278 027C 0280 0284
    STA (zp_work0),Y  ; 001A 001E 0022 0026 002A
    INY
    STA (zp_work0),Y  ; 001B 001F 0023 0027 002B
    INY
    STA (zp_work2),Y  ; 0276 027A 027E 0282 0286
    BNE bra_advance_actor_pointer
; Actor remains within staged-X bounds
bra_actor_not_outside_vertical_bounds:
    CMP #$04
    BCC bra_loop_reset_offscreen_actor
; Advance object/sprite pointers to next actor
bra_advance_actor_pointer:
    LDA zp_work0
    CLC
    ADC #< $0004
    STA zp_work0
    LDA zp_work1
    ADC #> $0004
    STA zp_work1
    LDA zp_work2
    CLC
    ADC #< $0004
    STA zp_work2
    LDA zp_work3
    ADC #> $0004
    STA zp_work3
    INX
    CPX #$05
    BNE bra_loop_update_next_actor
    RTS

; Dispatch intermission tile animation script by scene id
; Animation dispatch is scene-aligned with tbl_intermission_scene_handlers
; and usually keyed by the same ram_intermission_substate
