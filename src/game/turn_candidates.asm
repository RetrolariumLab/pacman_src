; Collect valid movement directions from neighboring maze tiles

; Inputs: X=ghost-state/direction slot offset; zp_work0 points to four cached
; neighbor tiles; zp_work9 and zp_work10 are caller-accepted special tile classes
; Outputs: zp_work11..zp_work14 contain compacted direction indices followed by $FF
; Side effects: removes the reverse of ram_ghost_direction,X from consideration
; Clobbers: A, Y, zp_work10..zp_work14; X is preserved

sub_collect_valid_turn_candidates:  ; was: sub_E42B
    LDY #$FF
    STY zp_work11
    STY zp_work12
    STY zp_work13
    STY zp_work14
    INY  ; 00
; Scan neighbor tiles for passable candidates
bra_scan_neighbor_tiles:  ; was: bra_E436_loop
    LDA (zp_work0),Y  ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    CMP zp_work9
    BEQ bra_store_candidate_direction
    AND #$F8
    BEQ bra_store_candidate_direction
    CMP zp_work10
    BNE bra_next_neighbor_tile
; Store candidate direction index
bra_store_candidate_direction:  ; was: bra_E444
    TYA
    STA zp_work11,Y
; Advance to next neighbor tile
bra_next_neighbor_tile:  ; was: bra_E448
    INY
    CPY #$04
    BNE bra_scan_neighbor_tiles
    LDA ram_ghost_direction,X
    CLC
    ADC #con_direction_reverse_delta
    AND #con_direction_mask
    TAY
    LDA #$FF
    STA zp_work11,Y
    LDA #$03
    STA zp_work10
; Compact candidate list removing blocked/reverse entries
bra_compact_candidate_list:  ; was: bra_E45E_loop
    LDY #$00
; Shift candidate entries left during compaction
bra_shift_candidate_entry:  ; was: bra_E460_loop
    LDA zp_work11,Y
    CMP #$FF
    BNE bra_next_compaction_index
    LDA zp_work12,Y
    STA zp_work11,Y
    LDA #$FF
    STA zp_work12,Y
; Advance compaction index
bra_next_compaction_index:  ; was: bra_E472
    INY
    CPY #$03
    BNE bra_shift_candidate_entry
    DEC zp_work10
    BNE bra_compact_candidate_list
    RTS

; Upload fixed HUD text blocks (READY/1UP/2UP labels etc.)
