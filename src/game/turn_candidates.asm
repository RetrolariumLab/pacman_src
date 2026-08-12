; Collect valid movement directions from neighboring maze tiles

sub_E42B_collect_valid_turn_candidates:		; was: sub_E42B
    LDY #$FF
    STY ram_000C
    STY ram_000D
    STY ram_000E
    STY ram_000F
    INY ; 00
; Scan neighbor tiles for passable candidates
bra_E436_scan_neighbor_tiles:		; was: bra_E436_loop
    LDA (ram_0000),Y    ; 022F 0230 0231 0232 0233 0234 0235 0236 0237 0238 0239 023A 023B 023C 023D 023E
    CMP ram_000A
    BEQ bra_E444_store_candidate_direction
    AND #$F8
    BEQ bra_E444_store_candidate_direction
    CMP ram_000B
    BNE bra_E448_next_neighbor_tile
; Store candidate direction index
bra_E444_store_candidate_direction:		; was: bra_E444
    TYA
    STA ram_000C,Y
; Advance to next neighbor tile
bra_E448_next_neighbor_tile:		; was: bra_E448
    INY
    CPY #$04
    BNE bra_E436_scan_neighbor_tiles
    LDA ram_00B9,X
    CLC
    ADC #$02
    AND #$03
    TAY
    LDA #$FF
    STA ram_000C,Y
    LDA #$03
    STA ram_000B
; Compact candidate list removing blocked/reverse entries
bra_E45E_compact_candidate_list:		; was: bra_E45E_loop
    LDY #$00
; Shift candidate entries left during compaction
bra_E460_shift_candidate_entry:		; was: bra_E460_loop
    LDA ram_000C,Y
    CMP #$FF
    BNE bra_E472_next_compaction_index
    LDA ram_000D,Y
    STA ram_000C,Y
    LDA #$FF
    STA ram_000D,Y
; Advance compaction index
bra_E472_next_compaction_index:		; was: bra_E472
    INY
    CPY #$03
    BNE bra_E460_shift_candidate_entry
    DEC ram_000B
    BNE bra_E45E_compact_candidate_list
    RTS



; Upload fixed HUD text blocks (READY/1UP/2UP labels etc.)
