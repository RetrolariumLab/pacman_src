# cpu

# 2A03

Source: https://www.nesdev.org/wiki/2A03

The 2A03, short for RP2A03, is the common name of the NTSC NES CPUchip. It consists of a MOS Technology 6502 processor (lacking decimal mode) and audio, joypad, and DMA functionality. PAL systems use the similar RP2A07, which has a different clock rate, adjusted sampled audio rates, and DMA bugfixes.

## 2A03 register map

In addition to the registers in the 6502 core, the 2A03 contains 22 memory-mapped registers for sound generation (see NES APU), joystick reading, and OAM DMA transferring. Unlike the addresses of PPUregisters and mapperregisters, CPU register addresses are completely decoded, which means that the entire space from the end of CPU registers to the top of address space ($4020 through $FFFF) is available to the Game Pak.

The range $4018-$401F does nothing on a retail NES. It was intended for 2A03 functionality that never made it to production. Various revisions of the 2A03 include test registers(which are disabled in normal operation) or remnants of an incompletely implemented IRQ counterthat was disconnected from the rest of the circuit. Mappers can place writable registers here without conflicting with the 2A03, but placing readable registers here should be avoided because of conflicts with DMA.

| Address | Name | Write | Read |
| $4000 | SQ1_VOL | Pulse 1 | Duty cycle and volume | Open bus |
| $4001 | SQ1_SWEEP | Sweep control register |
| $4002 | SQ1_LO | Low byte of period |
| $4003 | SQ1_HI | High byte of period and length counter value |
| $4004 | SQ2_VOL | Pulse 2 | Duty cycle and volume |
| $4005 | SQ2_SWEEP | Sweep control register |
| $4006 | SQ2_LO | Low byte of period |
| $4007 | SQ2_HI | High byte of period and length counter value |
| $4008 | TRI_LINEAR | Triangle | Linear counter |
| $4009 |  | Unused |
| $400A | TRI_LO | Low byte of period |
| $400B | TRI_HI | High byte of period and length counter value |
| $400C | NOISE_VOL | Noise | Volume |
| $400D |  | Unused |
| $400E | NOISE_LO | Period and waveform shape |
| $400F | NOISE_HI | Length counter value |
| $4010 | DMC_FREQ | DMC | IRQ flag, loop flag and frequency |
| $4011 | DMC_RAW | 7-bit DAC |
| $4012 | DMC_START | Start address = $C000 + $40*$xx |
| $4013 | DMC_LEN | Sample length = $10*$xx + 1 bytes (128*$xx + 8 samples) |
| $4014 | OAMDMA | OAM DMA: Copy 256 bytes from $xx00-$xxFF into OAM via OAMDATA ($2004) |
| $4015 | SND_CHN | Sound channels enable | Sound channel and IRQ status |
| $4016 | JOY1 | Joystick strobe | Joystick 1 data |
| $4017 | JOY2 | Frame counter control | Joystick 2 data |
| $4018-$401A | APU test functionality that is normally disabled. See CPU Test Mode. |
| $401C-$401F | Unfinished IRQ timer functionality that is always disabled. See RP2A03 Programmable Interval Timer. |

## See also
- NES CPU

# 6502 assembly optimisations

Source: https://www.nesdev.org/wiki/6502_assembly_optimisations

This page is about optimisations that are possible in assembly language, or various things one programmer has to keep in mind to make their code as optimal as possible.

There is two major kind of optimisations: Optimisation for speed (code executes in fewer cycles) and optimisation for size (the code takes fewer bytes).

There is also some other kinds of optimisations, such as constant-executing-time optimisation (code execute in a constant number of cycle no matter what it has to do), or RAM usage optimisation (use as few variables as possible). Because those optimisations have more to do with the algorithm than with its implementation in assembly, only speed and size optimisations will be discussed in this article.

## Optimise both speed and size of the code

### Avoid a jsr + rts chain

A tail calloccurs when a subroutine finishes by calling another subroutine. This can be optimised into a JMP instruction:

```text
MySubroutine
  lda Foo
  sta Bar
  jsr SomeRandomRoutine
  rts

```

becomes :

```text
MySubroutine
  lda Foo
  sta Bar
  jmp SomeRandomRoutine

```

Savings : 9 cycles, 1 byte

### Split word tables in high and low components

This optimisation is not human friendly, makes the source code much bigger, but still makes the compiled [1]size smaller and faster:

```text
Example
  lda FooBar
  asl A
  tax
  lda PointerTable,X
  sta Temp
  lda PointerTable+1,X
  sta Temp+1
  ....

PointerTable
  .dw Pointer1, Pointer2, ....

```

Becomes :

```text
Example
  ldx FooBar
  lda PointerTableL,X
  sta Temp
  lda PointerTableH,X
  sta Temp+1
  ....

PointerTableL
  .byt <Pointer1, <Pointer2, ....

PointerTableH
  .byt >Pointer1, >Pointer2, ....

```

Some assemblers may have a way to implement a macro to automatically make the table coded like this (Unofficial MagicKit Assembler is one such program).

Savings : 2 bytes, 4 cycles

### Use Jump tables with RTS instruction instead of JMP indirect instruction

The so-called RTS Trickis a method of implementing jump tables by pushing a subroutine's entry point to the stack.

```text
; This:

  ldx JumpEntry
  lda PointerTableH,X
  sta Temp+1
  lda PointerTableL,X
  sta Temp
  jmp [Temp]

; becomes this:

  ldx JumpEntry
  lda PointerTableH,X
  pha
  lda PointerTableL,X
  pha
  rts

```

Note that PointerTable entries must point to one byte before the intended target when the RTS trick is used, because RTS will add 1 to the offset.

If `Temp `is outside zero page, this saves 6 bytes and 1 cycle. If `Temp `is within zero page, this saves 4 bytes and costs 1 cycle.

In either case, it frees up the RAM occupied by `Temp `for other uses so long as the use of the RTS Trick does not occur at peak stack depth. In addition, it's reentrant, which means the NMI and IRQ handlers do not need dedicated 2-byte RAM allocations for their own `Temp `variables.

Combining this with the tail call optimization squeezes 1 more byte and 9 more cycles:

```text
; This:

  jsr SomeOtherFunction  ; MUST NOT modify JumpEntry
  ldx JumpEntry
  lda PointerTableH,X
  pha
  lda PointerTableL,X
  pha
  rts

; Becomes this:

  ldx JumpEntry
  lda PointerTableH,X
  pha
  lda PointerTableL,X
  pha
  jmp SomeOtherFunction

```

Here, the CPU runs `SomeOtherFunction `, then returns to the function from the jump table, then returns to what called this dispatcher. One example is a `SomeOtherFunction `that mixes player input into the random number generator's entropy pool before calling the routine for a particular game state.

### Inline subroutine called only one time through the whole program

There is no reason to call a subroutine if it is only called a single time. It would be more optimal to just insert the code where the subroutine is called. However this makes the code less structured and harder to understand. Inline expansionof a subroutine into another subroutine can be done with a macro. One drawback is that if the subroutine is called in a loop, it may require some JMPing to work around the 128-byte limit on branch length.

How macros are used depends on the assembler so no code examples will be placed here to avoid further confusion. In C, the `static inline `keyword acts as a hint to expand a function as a macro.

Savings : 4 bytes, 12 cycles.

### Easily test 2 upper bits of a variable

```text
    lda FooBar
    asl A         ;C = b7, N = b6

```

Alternative:

```text
    bit Foobar    ;N = b7, V = b6, regardless of the value of A.

```

This can be e.g. used to poll the sprite-0-hit flag in $2002.

### Avoiding the need for CLC/SEC with ADC/SBC

When using ADC #imm, somewhere where it is known carry is already cleared, there's no need to use a CLC instruction. However, that carry is known to be set (for example, the code is located in a branch that is only ever entered with a BCS instruction), it's still possible to avoid using CLC by just doing ADC #(value-1). The `PLOT `subroutine in the Apple II Monitor uses this.

Similarly for SBC #imm: When it is known that carry is clear , SEC instruction can be avoided by just doing SBC #(value-1) or ADC #<-value.

### Test bits in decreasing order

```text
   lda foobar
   bmi bit7_set
   cmp #$40  ; we know that bit 7 wasn't set
   bcs bit6_set
   cmp #$20
   bcs bit5_set
             ; and so on

```

Or the value of A doesn't need to be preserved :

```text
   lda foobar
   bmi bit7_set
   asl
   bmi bit6_set
   asl
   bmi bit5_set
             ; and so on

```

This saves one byte per comparison.

### Test bits in increasing order

```text
   lda foobar
   lsr
   bcs bit0_set
   lsr
   bcs bit1_set
   lsr
   bcs bit2_set
             ; and so on

```

Note: This does not preserve the value of A.

### Test bits without destroying the accumulator

The AND instruction can be used to test bits, but this destroy the value in the accumulator. The BIT can do this but it has no immediate adressing mode. A way to do it is to look for an opcode that has the bits that needs to be tested, and using bit $xxxx on this opcode.

```text
Example
   lda foobar
   and #$30
   beq bits_clear
   lda foobar
   ....

bits_clear
   lda foobar
   .....

```

becomes :

```text
Example
   lda foobar
   bit _bmi_instruction ;equivalent to and #$30 but preserves A
   beq bits_clear
   ....

bits_clear
   .....

anywhere_in_the_code
    ....
_bmi_instruction    ;The BMI opcode = $30
    bmi somewhere

```

Savings : 2 cycles, 3 bytes

### Test for equality preserving carry

To test whether A equals some other value, EOR can be used instead of CMP to avoid overwriting the carry flag. However, unlike CMP, EOR destroys A. [2]

Before:

```text
   php        ; store carry
   cmp myVal
   beq equal
   plp        ; restore carry; A != myVal
   ...
equal:
   plp        ; restore carry; A == myVal
   ...

```

After (unlike the previous snippet, destroys A):

```text
   eor myVal
   beq equal
   ...        ; A was not equal to myVal
equal:
   ...        ; A was equal to myVal

```

If necessary, the original value of A can be restored with another EOR, which is still faster than the first snippet:

```text
   eor myVal
   beq equal
   eor myVal  ; A was not equal to myVal; restore A
   ...
equal:
   eor myVal  ; restore A
   ...

```

Savings: 7 cycles and 3 bytes if A destroyed, 3 cycles and -1 byte if A preserved.

### Test whether all specified bits are set, preserving carry

To test whether all specified bits are set, EOR & AND can be used instead of AND & CMP to avoid overwriting the carry flag. [3]

Before (testing bits 7, 6, 1 and 0 of A):

```text
  php             ; preserve carry
  and #%11000011
  cmp #%11000011
  beq all_set
  plp             ; not all set
  ...
all_set:
  plp
  ...

```

After:

```text
  eor #$ff
  and #%11000011
  beq all_set
  ...             ; not all set
all_set:
  ...

```

Savings: 7 cycles, 3 bytes.

### Use opposite rotate instead of a great number of shifts

To retrieve the 3 highest bits of a value in the low positions, it is tempting to do 5 LSRs in a row. However, if it is not needed for the 5 top bits to be cleared, this is more efficient:

```text
  lda value   ; got: 76543210 c
  rol         ; got: 6543210c 7
  rol         ; got: 543210c7 6
  rol         ; got: 43210c76 5
  rol         ; got: 3210c765 4
  ; Only care about these ^^^

```

It works the same for replacing 5 ASLs with 4 RORs.

3 RORs can replace 6 ASLs :

```text
  lda value   ; got: 76453210 c
  ror         ; got: c7654321 0
  ror         ; got: 0c765432 1
  ror         ; got: 10c76543 2
  and #$C0    ; got: 10------

```

### Avoid compare instructions in loops

In a loop, comparing the loop counter using CMP/CPX/CPY #constant can often be avoided by choosing the direction of the loop and the final value carefully, so the branch instruction can operate using only the Z and N flags from INX/DEX/etc.

Increasing values of X up to 127, starting from 255 or 0-127:

```text
loop:
  ...
  inx
  bpl loop

```

Increasing values of X up to 255:

```text
loop:
  ...
  inx
  bne loop

```

Decreasing values of X down to 1:

```text
loop:
  ...
  dex
  bne loop

```

Decreasing values of X down to 0, starting from 0-128:

```text
loop:
  ...
  dex
  bpl loop

```

Decreasing values of X down to 128, starting from 129-255 or 0:

```text
loop:
  ...
  dex
  bmi loop

```

Arrays can be offset by a constant to get a suitable final value for the loop counter:

```text
; copy indexes 10-13 from my_array to $2007
ldx #252              ; 256 - number of bytes
loop:
  lda my_array-242,x  ; 242 = first X - first index in my_array
  sta $2007
  inx
  bne loop

```

Savings: 2 cycles, 2 bytes (less if applying an offset to an array prevents using zero page addressing).

### Avoid compare instructions for certain constants

Comparing values to 0 is unnecessary after an instruction which modifies A/X/Y or a memory address. Example:

```text
; this:
  lda Val
  clc
  adc #$02
  cmp #$00
  beq Zero
  bmi Negative

; becomes:
  lda Val
  clc
  adc #$02 ; this sets the zero/negative flags
  beq Zero
  bmi Negative

```

Savings: 2 bytes, 2 cycles.

Similarly, CMP/CPX/CPY #constant can be avoided for -1 ($ff), 1, and 2 at the cost of clobbering the register.

Comparing to -1 ($ff):

```text
; this:
  lda Val
  cmp #$ff
  beq Equals
  bne NotEquals

; becomes:
  ldx Val ; Y will also work
  inx
  beq Equals
  bne NotEquals

```

Comparing to 1:

```text
; this:
  lda Val
  cmp #$01
  beq Equals
  bne NotEquals

; becomes:
  ldx Val ; Y will also work
  dex
  beq Equals
  bne NotEquals

```

Comparing to 2 (for range checks):

```text
; this:
  lda Val
  cmp #$02
  bcc LessThan
  bcs GreaterEqualTo

; becomes:
  lda Val
  lsr a
  beq LessThan
  bne GreaterEqualTo

```

Savings: 1 byte. Using Read-Modify-Write instructions on the variable itself can save an extra byte at the cost of clobbering its value.

### Blend bits from two sources using EOR

Suppose you want to overwrite some of the bits in a byte with the corresponding bits from another byte--for example, when working with PPU attribute tables. The naive way to do it is expressed by the following pseudocode, where mask indicates which bits in dst to modify:

`dst = (src & mask) | (dst & ~mask) `

However, this statement can be reexpressed as an equivalent one which takes fewer operations, especially on a single-accumulator machine like the 6502:

`dst = ((src ^ dst) & mask) ^ dst `

In assembly language:

```text
  lda src
  eor dst
  and mask
  eor dst
  sta dst

```

If you replace the second `eor dst `with `eor src `, then set bits in mask indicate the bits to retain from dst rather than the bits to overwrite with src.

## Optimise speed at the expense of size

Those optimisations will make code faster to execute, but use more ROM. Therefore, it is useful in NMI routines and other things that need to run fast.

### Use identity look-up table instead of temp variable

Main article: Identity table

```text
Example
    ldx Foo
    lda Bar
    stx Temp
    clc
    adc Temp    ;A = Foo + Bar

```

becomes :

```text
Example
    ldx Foo
    lda Bar
    clc
    adc Identity,X    ;A = Foo + Bar

Identity
    .byt $00, $01, $02, $03, .....

```

If the program is very large (such as in large games), it is possible that this way eventually saves ROM; also, it might save one byte of RAM in some circumstances.

Savings : 2 cycles

### Use look-up table to shift left 4 times

Provided that the high nibble is already cleared, the value can be shifted left by 4 by making a look-up table.

```text
Example:
  lda rownum
  asl A
  asl A
  asl A
  asl A
  rts

```

becomes

```text
Example:
  ldx rownum
  lda times_sixteen,x
  rts

times_sixteen:
  .byt $00, $10, $20, $30, $40, $50, $60, $70
  .byt $80, $90, $A0, $B0, $C0, $D0, $E0, $F0

```

In very large programs, this might save some ROM space. However, it will use up the X register, so it might not be ideal.

Savings: 4 cycles

## Optimise code size at the expense of cycles

Those optimisations will produce code that is smaller but takes more cycles to execute. Therefore, it can be used in the parts of the program that do not have to be fast.

### Use the stack instead of a temp variable

```text
Example
   lda Foo
   sta Temp
   lda Bar
   ....
   ....
   lda Temp   ;Restores Foo
   .....

```

becomes:

```text
Example
   lda Foo
   pha
   lda Bar
   ....
   ....
   pla   ;Restores Foo
   .....

```

Savings : 2 bytes.

### Use an "intelligent" argument system

Each time a routine needs multiple bytes of arguments (>3) it's hard to code it without wasting a lot of bytes.

```text
Example
   lda Argument1
   sta Temp
   lda Argument2
   ldx Argument3
   ldy Argument4
   jsr RoutineWhichNeeds4Args
   .....

```

Becomes something like:

```text
Example
   jsr PassArguments
   .dw RoutineWhichNeeds4Args
   .db Argument1, Argument2, Argument3, Argument4
   .db $00
   ....

PassArguments
   pla
   tay
   pla
   pha                    ; put the high byte back
   sta pointer+1
   ldx #$00
   beq SKIP
LOOP
   sta parameters,x
   inx
SKIP
   iny                    ; pointing one short first pass here fixes that
   lda (pointer),y
   bne LOOP
   iny
   lda (pointer),y
   beq LOOP

   dey                    ; fix the return address guess we can't return to a
                         ;  break
   tya
   pha
   jmp (parameters)

```

Syscalls in Apple ProDOS [4]and FDS BIOS work this way.

Savings : Complicated to estimate - only saves bytes if the trick is used fairly often across the program, in order to compensate for the size of the PassArguments routine.

### Using relative branch instruction instead of absolute

If the state of one of the processor flags is already known at this point and the branch target is not too far away, then a condition branch instruction can be used. For example,

```text
lda #1
jmp target

```

becomes

```text
lda #1
bne target  ; zero flag is always clear

```

or

```text
lda #1
bpl target  ; negative flag is always clear

```

Savings : 1 byte.

### BIT trick

The BIT instruction ($24 and $2C) can be used to "mask out" the following 1- or 2-byte instruction without affecting non-flags CPU registers. Care should be taken, however, to ensure a masked 2-byte instruction does not match the address of a register with read side effects, as this would trigger them.

This trick can be used to create multiple entry points to a subroutine that takes one argument in a register. For example,

```text
sub_11:
    lda #11
sub:
    sta $2007
    sta $2007
    rts
...
lda #5
jsr sub
lda #7
jsr sub
jsr sub_11
lda #13
jsr sub

```

becomes

```text
sub_5:
    lda #5
    .byte $2c  ; BIT absolute opcode
sub_7:
    lda #7     ; turns into the operand of BIT if sub_5 was called
    .byte $2c  ; BIT absolute opcode
sub_11:
    lda #11    ; turns into the operand of BIT if sub_5 or sub_7 was called
sub:
    sta $2007
    sta $2007
    rts
...
jsr sub_5
jsr sub_7
jsr sub_11
lda #13
jsr sub

```

Code size is reduced if sub_5 and sub_7 are called more than once.

[5]

## See also
- Synthetic instructions

## Notes
- ↑Pedants may complain that "compile" is incorrect terminology for "translate a program written in assembly language into object code". But it is the most familiar term meaning "translate a program, no matter the language, into object code", and the same issues apply to code generators within a compiler that targets the 6502 as to programs written in 6502 assembly language.
- ↑EOR #$FF - 6502 Ponderables and Befuddlements, puzzle $00
- ↑foobles on NESDev Discord 2023-08-30 (UTC)
- ↑ProDOS 8 Technical Reference Manual
- ↑Used in Super Mario Bros. (e.g. MoveSpritesOffscreen in doppelganger's disassembly)

# 6502 cycle times

Source: https://www.nesdev.org/wiki/6502_cycle_times

| Mnemonic | Description | Imp | Imm | ZP | ZP,X | ZP,Y | Abs | Abs,X | Abs,Y | Ind | Ind,X | Ind,Y | Acc | Rel |
| ADC | Add with carry |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| AND | Bitwise AND with A |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| BIT | Bit test |  |  | 3 |  |  | 4 |  |  |  |  |  |  |  |
| CMP | Compare A |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| CPX | Compare X |  | 2 | 3 |  |  | 4 |  |  |  |  |  |  |  |
| CPY | Compare Y |  | 2 | 3 |  |  | 4 |  |  |  |  |  |  |  |
| EOR | Bitwise XOR with A |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| LDA | Load A |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| LDX | Load X |  | 2 | 3 |  | 4 | 4 |  | 4+ |  |  |  |  |  |
| LDY | Load Y |  | 2 | 3 | 4 |  | 4 | 4+ |  |  |  |  |  |  |
| ORA | Bitwise OR with A |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| SBC | Subtract with carry |  | 2 | 3 | 4 |  | 4 | 4+ | 4+ |  | 6 | 5+ |  |  |
| STA | Store A |  |  | 3 | 4 |  | 4 | 5 | 5 |  | 6 | 6 |  |  |
| STX | Store X |  |  | 3 |  | 4 | 4 |  |  |  |  |  |  |  |
| STY | Store Y |  |  | 3 | 4 |  | 4 |  |  |  |  |  |  |  |
| ASL | Arithmetic shift left |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  | 2 |  |
| DEC | Decrement memory |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  |  |  |
| INC | Increment memory |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  |  |  |
| LSR | Logical shift right |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  | 2 |  |
| ROL | Rotate left |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  | 2 |  |
| ROR | Rotate right |  |  | 5 | 6 |  | 6 | 7 |  |  |  |  | 2 |  |
| PHA | Push A | 3 |  |  |  |  |  |  |  |  |  |  |  |  |
| PHP | Push processor status | 3 |  |  |  |  |  |  |  |  |  |  |  |  |
| PLA | Pull A | 4 |  |  |  |  |  |  |  |  |  |  |  |  |
| PLP | Pull processor status | 4 |  |  |  |  |  |  |  |  |  |  |  |  |
| BRK | Break | 7 |  |  |  |  |  |  |  |  |  |  |  |  |
| JMP | Jump |  |  |  |  |  | 3 |  |  | 5 |  |  |  |  |
| JSR | Jump to subroutine |  |  |  |  |  | 6 |  |  |  |  |  |  |  |
| RTI | Return from interrupt | 6 |  |  |  |  |  |  |  |  |  |  |  |  |
| RTS | Return from subroutine | 6 |  |  |  |  |  |  |  |  |  |  |  |  |
| BCC | Branch if carry clear |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BCS | Branch if carry set |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BEQ | Branch if equal |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BMI | Branch if minus |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BNE | Branch if not equal |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BPL | Branch if plus |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BVC | Branch if overflow clear |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| BVS | Branch if overflow set |  |  |  |  |  |  |  |  |  |  |  |  | 2++ |
| CLC | Clear carry | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| CLD | Clear decimal | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| CLI | Clear interrupt disable | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| CLV | Clear overflow | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| DEX | Decrement X | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| DEY | Decrement Y | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| INX | Increment X | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| INY | Increment Y | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| NOP | No operation | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| SEC | Set carry | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| SED | Set decimal | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| SEI | Set interrupt disable | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TAX | Transfer A to X | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TAY | Transfer A to Y | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TSX | Transfer S to X | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TXA | Transfer X to A | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TXS | Transfer X to S | 2 |  |  |  |  |  |  |  |  |  |  |  |  |
| TYA | Transfer Y to A | 2 |  |  |  |  |  |  |  |  |  |  |  |  |

+: Plus 1 cycle if page crossed
++: Plus 1 cycle if branch taken, and 1 more cycle if page crossed

# 6502 instructions

Source: https://www.nesdev.org/wiki/6502_instructions

Below are some references for the 6502 instruction set:
- Instruction reference, describing all official instructions and how they function
- CPU unofficial opcodes, including a full opcode matrix of all official and unofficial opcodes
- Programming with unofficial opcodes
- 6502 assembly optimisations
- Delay code, and Fixed cycle delay: how to create a delay of a precise number of CPU cycles with smallest number of code bytes
- 6502 cycle times

## External links
- http://users.telenet.be/kim1-6502/6502/proman.html- MOS 6502 programming manual
- http://nesdev.org/6502_cpu.txt- Includes tick-by-tick breakdowns of instructions (see CPU interruptsfor breakdowns of interrupts)
- https://www.nesdev.org/obelisk-6502-guide/reference.html- Historical 6502 instruction reference, but largely obsoleted by NESdev's instruction reference
- Visual 6502can be used to figure out obscure instruction behavior. There's also a 2A03 versionavailable (hosted on residential broadband, so avoid needless shift-reloading). There is also a tutorial on reading the circuit diagramsavailable, aimed at beginners.

# CPU

Source: https://www.nesdev.org/wiki/CPU

The NES CPU core is based on the 6502 processor and runs at approximately 1.79 MHz (1.66 MHz in a PAL NES). It is made by Ricohand lacks the MOS6502's decimal mode. In the NTSC NES, the RP2A03chip contains the CPU and APU; in the PAL NES, the CPU and APU are contained within the RP2A07chip.

## Sections
- CPU instructions
- CPU addressing modes
- CPU memory map
- CPU power-up state
- CPU registers
- CPU status flag behavior
- CPU interrupts
- Unofficial opcodes
- CPU pin-out and signals, and other hardware pin-outs

## Frequencies

The CPU generates its clock signal by dividing the master clock signal.

| Rate | NTSC NES/Famicom | PAL NES | Dendy |
| Color subcarrier frequency fsc (exact) | 3579545.45 Hz (315/88 MHz) | 4433618.75 Hz | 4433618.75 Hz |
| Color subcarrier frequency fsc (approx.) | 3.579545 MHz | 4.433619 MHz | 4.433619 MHz |
| Master clock frequency 6fsc | 21.477272 MHz | 26.601712 MHz | 26.601712 MHz |
| Clock divisor d | 12 | 16 | 15 |
| CPU clock frequency 6fsc/d | 1.789773 MHz (~559 ns per cycle) | 1.662607 MHz (~601 ns per cycle) | 1.773448 MHz (~564 ns per cycle) |

* The vast majority of PAL famiclones use a chipset or NOAC with this timing. A small number have UMC UA6540+6541, which also uses PAL NES timing. [1]

## Notes
- All illegal 6502 opcodes execute identically on the 2A03/2A07.
- Every cycle on 6502 is either a read or a write cycle.
- A printer friendly version covering all section is available here.
- Emulator authors may wish to emulate the NTSC NES/Famicom CPU at 21441960 Hz ((341×262−0.5)×4×60) to ensure a synchronised/stable 60 frames per second. [2]

## See also
- Cycle reference chart
- 2A03 technical referenceby Brad Taylor. (Pretty old at this point; information on the wiki might be more up-to-date.)

## References
- ↑nesdev forum: Eugene.S provides a list of famiclones
- ↑nesdev forum: Mesen - NES Emulator

# CPU Test Mode

Source: https://www.nesdev.org/wiki/CPU_Test_Mode

Pin 30 on the 2A03G and 2A03H provides special functionality in some revisions of the chip and is normally grounded.

## 2A03G / 2A03H Test Mode

Pin 30 of the 2A03G and 2A03H can be asserted to enable a special test mode for the APU. This activates registers for testing the APU at $4018-$401A at the expense of deactivating the joypad input registers at $4016-$4017:

```text
R$4018: [BBBB AAAA] - current instant DAC value of B=pulse2 and A=pulse1 (either 0 or current volume)
R$4019: [NNNN TTTT] - current instant DAC value of N=noise (either 0 or current volume)
                      and T=triangle (anywhere from 0 to 15)
R$401A: [.DDD DDDD] - current instant DAC value of DPCM channel (same as value written to $4011)
W$401A: [L..T TTTT] - set state of triangle's sequencer to T, and lock all channels if L=1
                      (pulse+noise always output current volume, triangle/DPCM no longer advance)

```

Test mode disconnects the external CPU bus from the internal bus when reading from any of $4000-401F, just as normally happens when reading from $4015; this is what disables the joypads, by preventing the CPU from seeing the value they put on the bus. Test mode also causes the CPU to continue outputting M2 while held in reset.

Connecting pin 30 to CPU A3 allows the test and controller registers to coexist, at the cost of increased likelihood of DMC DMA corruption when the CPU is reading from $4000-401F (see DMA register conflicts). Because the state of A3 is effectively random when reset begins and because the address lines go high impedance during reset, a weak pulldown (10k Ohm) should be used to prevent pin 30 from floating while reset is held and restore standard M2-during-reset behavior.

## 2A03E

On the 2A03E, pin 30 functions as an external /RDY input, and the Playchoice 10supervisor CPU uses this to reset the 2A03E when the player runs out of time (by driving pin 30 high to halt it, then driving pin 30 low and pulling /RESET low to reset it). Driving pin 30 high and then low has been observed to simply crash the 2A03E.

## 2A07A

Just as with the 2A03E, pin 30 on the 2A07 is an external /RDY input.

## 2A03

In the original version of the 2A03, pin 30 is not connected to anything at all.

## See also
- Forum: Breaking NES apart
- See: File:Apu address.jpg
- See: CPU pin out and signal description

# CPU addressing modes

Source: https://www.nesdev.org/wiki/CPU_addressing_modes

The NES CPU is a second-source version of MOS Technology 6502, manufactured by Ricoh. Addressing modes and instruction timings are the same as those in the standard 6502.

This page summarizes the 6502 addressing modes and explains some cases where certain modes might be useful.

## Indexed addressing

Indexed addressing modes use the X or Y register to help determine the address. The 6502 has six main indexed addressing modes:

| Abbr | Name | Formula | Cycles |
| d,x | Zero page indexed | val = PEEK((arg + X) % 256) | 4 |
| d,y | Zero page indexed | val = PEEK((arg + Y) % 256) | 4 |
| a,x | Absolute indexed | val = PEEK(arg + X) | 4+ |
| a,y | Absolute indexed | val = PEEK(arg + Y) | 4+ |
| (d,x) | Indexed indirect | val = PEEK(PEEK((arg + X) % 256) + PEEK((arg + X + 1) % 256) * 256) | 6 |
| (d),y | Indirect indexed | val = PEEK(PEEK(arg) + PEEK((arg + 1) % 256) * 256 + Y) | 5+ |

Notes:
- Abbreviations for addressing modes are those used in WDC's 65C816 data sheets.
- + means add a cycle for write instructions or for page wrapping on read instructions, called the "oops" cycle below.

The 6502 has one 8-bit ALU and one 16-bit upcounter (for PC). To calculate a,x or a,y addressing in an instruction other than sta, stx, or sty, it uses the 8-bit ALU to first calculate the low byte while it fetches the high byte. If there's a carry out, it goes "oops", applies the carry using the ALU, and repeats the read at the correct address. Store instructions always have this "oops" cycle: the CPU first reads from the partially added address and then writes to the correct address. The same thing happens on (d),y indirect addressing.

The (d),y mode is used far more often than (d,x). The latter implies a table of addresses on zero page. On computers like the Apple II, where the BASIC interpreter uses up most of zero page, (d,x) is rarely used. But the NES has far more spare room in zero page, and music engine might use X = 0, 4, 8, or 12 to match APUregister offsets.

## Other addressing

| Abbr | Name | Notes |
|  | Implicit | Instructions like RTS or CLC have no address operand, the destination of results are implied. |
| A | Accumulator | Many instructions can operate on the accumulator, e.g. LSR A. Some assemblers will treat no operand as an implicit A where applicable. |
| #v | Immediate | Uses the 8-bit operand itself as the value for the operation, rather than fetching a value from a memory address. |
| d | Zero page | Fetches the value from an 8-bit address on the zero page. |
| a | Absolute | Fetches the value from a 16-bit address anywhere in memory. |
| label | Relative | Branch instructions (e.g. BEQ, BCS) have a relative addressing mode that specifies an 8-bit signed offset relative to the current PC. |
| (a) | Indirect | The JMP instruction has a special indirect addressing mode that can jump to the address stored in a 16-bit pointer anywhere in memory. |

# CPU interrupts

Source: https://www.nesdev.org/wiki/CPU_interrupts

An interrupt is a signal that causes a CPU to pause, save what it was doing, and call a routine that handles the signal. The signal usually indicates an event originating in other circuits in a system. The routine, called an interrupt service routine (ISR) or interrupt handler, processes the event and then returns to the main program.

The NES CPU is based on the MOS 6502 CPU, which supports two kinds of interrupts: the ordinary interrupt request ( IRQ) and a non-maskable interrupt ( NMI). This page covers detailed interrupt behavior for the 6502 and assumes basic familiarity with 6502 interrupts. For a basic introduction to 6502 interrupts, see e.g. the MOS 6502 Programming Manual.

## Detailed interrupt behavior

The NMI input is edge-sensitive (reacts to high-to-low transitions in the signal) while the IRQ input is level-sensitive (reacts to a low signal level). Both inputs are active low.

The NMI input is connected to an edge detector . This edge detector polls the status of the NMI line during φ2of each CPU cycle (i.e., during the second half of each cycle) and raises an internal signal if the input goes from being high during one cycle to being low during the next. The internal signal goes high during φ1 of the cycle that follows the one where the edge is detected, and stays high until the NMI has been handled.

The IRQ input is connected to a level detector . If a low level is detected on the IRQ input during φ2 of a cycle, an internal signal is raised during φ1 the following cycle, remaining high for that cycle only (or put another way, remaining high as long as the IRQ input is low during the preceding cycle's φ2).

The output from the edge detector and level detector are polled at certain points to detect pending interrupts. For most instructions, this polling happens during the final cycle of the instruction, before the opcode fetch for the next instruction. If the polling operation detects that an interrupt has been asserted, the next "instruction" executed is the interrupt sequence.

Many references will claim that interrupts are polled during the last cycle of an instruction, but this is true only when talking about the output from the edge and level detectors. As can be deduced from above, it's really the status of the interrupt lines at the end of the second-to-last cycle that matters.

If both an NMI and an IRQ are pending at the end of an instruction, the NMI will be handled and the pending status of the IRQ forgotten (though it's likely to be detected again during later polling).

The interrupt sequences themselves do not perform interrupt polling, meaning at least one instruction from the interrupt handler will execute before another interrupt is serviced.

## Delayed IRQ response after CLI, SEI, and PLP

The RTI instruction affects IRQ inhibition immediately. If an IRQ is pending and an RTI is executed that clears the I flag, the CPU will invoke the IRQ handler immediately after RTI finishes executing. This is due to RTI restoring the I flag from the stack before polling for interrupts.

The CLI, SEI, and PLP instructions on the other hand change the I flag after polling for interrupts (like all two-cycle instructions they poll the interrupt lines at the end of the first cycle), meaning they can effectively delay an interrupt until after the next instruction. For example, if an interrupt is pending and the I flag is currently set, executing CLI will execute the next instruction before the CPU invokes the IRQ handler.

Verification and testing of this behavior in emulators can be accomplished through test ROM images.

## Branch instructions and interrupts

The branch instructions have more subtle interrupt polling behavior. Interrupts are always polled before the second CPU cycle (the operand fetch), but not before the third CPU cycle on a taken branch. Additionally, for taken branches that cross a page boundary, interrupts are polled before the PCH fixup cycle (see [1]for a tick-by-tick breakdown of the branch instructions). An interrupt being detected at either of these polling points (including only being detected at the first one) will trigger a CPU interrupt.

## Interrupt hijacking

Normally, the NMI vector is at $FFFA, the reset vector at $FFFC, and the IRQ and BRK vector at $FFFE. This means that when servicing an IRQ, the 6502 will push PC and P and then read the new program counter from $FFFE and $FFFF, as if `JMP ($FFFE) `. But the MOS 6502 and by extension the 2A03/2A07has a quirk that can cause an interrupt to use the wrong vector if two different interrupts occur very close to one another.

For example, if NMI is asserted during the first four ticks of a BRK instruction, the BRK instruction will execute normally at first (PC increments will occur and the status word will be pushed with the B flag set), but execution will branch to the NMI vector instead of the IRQ/BRK vector:

```text
Each [] is a CPU tick. [...] is whatever tick precedes the BRK opcode fetch.

Asserting NMI during the interval marked with * causes a branch to the NMI routine instead of the IRQ/BRK routine:

     ********************
[...][BRK][BRK][BRK][BRK][BRK][BRK][BRK]

```

In a tick-by-tick breakdown of BRK, this looks like

```text
 #  address R/W description
--- ------- --- -----------------------------------------------
 1    PC     R  fetch opcode, increment PC
 2    PC     R  read next instruction byte (and throw it away),
                increment PC
 3  $0100,S  W  push PCH on stack, decrement S
 4  $0100,S  W  push PCL on stack, decrement S
*** At this point, the signal status determines which interrupt vector is used ***
 5  $0100,S  W  push P on stack (with B flag set), decrement S
 6   $FFFE   R  fetch PCL, set I flag
 7   $FFFF   R  fetch PCH

```

Similarly, an NMI can hijack an IRQ, and an IRQ can hijack a BRK (though it won't be as visible since they use the same interrupt vector). The tick-by-tick breakdown of all types of interrupts is essentially like that of BRK, save for whether the B bit is pushed as set and whether PC increments occur.

This is not usually a problem for an IRQ interrupted by an NMI because the IRQ will normally still be asserted when the NMI returns and generate a new interrupt. The BRK instruction, however, can effectively be cancelled by an NMI (or an IRQ) this way, so code utilizing BRK should be careful not to have a chance of coinciding with an NMI. (The B bit on the stack can be checked in the NMI handler to detect and dispatch the missing BRK.)

### IRQ and NMI tick-by-tick execution

For exposition and to emphasize similarity with BRK, here's the tick-by-tick breakdown of IRQ and NMI (derived from Visual 6502). A reset also goes through the same sequence, but suppresses writes, decrementing the stack pointer thrice without modifying memory. This is why the I flag is always set on reset.

```text
 #  address R/W description
--- ------- --- -----------------------------------------------
 1    PC     R  fetch opcode (and discard it - $00 (BRK) is forced into the opcode register instead)
 2    PC     R  read next instruction byte (actually the same as above, since PC increment is suppressed. Also discarded.)
 3  $0100,S  W  push PCH on stack, decrement S
 4  $0100,S  W  push PCL on stack, decrement S
*** At this point, the signal status determines which interrupt vector is used ***
 5  $0100,S  W  push P on stack (with B flag *clear*), decrement S
 6   A       R  fetch PCL (A = FFFE for IRQ, A = FFFA for NMI), set I flag
 7   A       R  fetch PCH (A = FFFF for IRQ, A = FFFB for NMI)

```

## Notes
- The above interrupt hijacking and IRQ response behavior is tested by the cpu_interrupts_v2test ROM.
- For more details of how the PPU generates NMI during VBlank, see NMIand PPU frame timing.
- The B status flag doesn't physically exist inside the CPU, and only appears as different values being pushed for bit 4 of the saved status bits by PHP, BRK, and NMI/IRQ.
- For a more technical description of what causes the hijacking behavior, see Visual6502's writeup.

# CPU registers

Source: https://www.nesdev.org/wiki/CPU_registers

The registers on the NES CPU are just like on the 6502. There is the accumulator, 2 indexes, a program counter, the stack pointer, and the status register. Unlike many CPU families, members do not have generic groups of registers like say, R0 through R7.

### Accumulator

A is byte-wide and along with the arithmetic logic unit(ALU), supports using the status register for carrying, overflow detection, and so on.

### Indexes

X and Y are byte-wide and used for several addressing modes. They can be used as loop counters easily, using INC/DEC and branch instructions. Not being the accumulator, they have limited addressing modes themselves when loading and saving.

### Program Counter

The 2-byte program counter PC supports 65536 direct (unbanked) memory locations, however not all values are sent to the cartridge. It can be accessed either by allowing CPU's internal fetch logic increment the address bus, an interrupt (NMI, Reset, IRQ/BRQ), and using the RTS/JMP/JSR/Branch instructions.

### Stack Pointer

S is byte-wide and can be accessed using interrupts, pulls, pushes, and transfers. It indexes into a 256-byte stackat $0100-$01FF.

### Status Register

P has 6 bits used by the ALU but is byte-wide. PHP, PLP, arithmetic, testing, and branch instructions can access this register. See status flags.

# Status flags

Source: https://www.nesdev.org/wiki/CPU_status_flag_behavior

The flags register, also called processor status or just P , is one of the six architectural registers on the 6502 family CPU. It is composed of six one-bit registers. Instructions modify one or more bits and leave others unchanged.

## Flags

Instructions that save or restore the flags map them to bits in the architectural 'P' register as follows:

```text
7  bit  0
---- ----
NV1B DIZC
|||| ||||
|||| |||+- Carry
|||| ||+-- Zero
|||| |+--- Interrupt Disable
|||| +---- Decimal
|||+------ (No CPU effect; see: the B flag)
||+------- (No CPU effect; always pushed as 1)
|+-------- Overflow
+--------- Negative

```
- The PHP (Push Processor Status) and PLP (Pull Processor Status) instructions can be used to retrieve or set this register directly via the stack.
- Interrupts(NMI and IRQ/BRK) implicitly push the status register to the stack.
- Interrupts returning with RTI will implicitly pull the saved status register from the stack.
- The two bits with no CPU effect are ignored when pulling flags from the stack; there are no corresponding registers for them in the CPU.
- When P is displayed as a single 8-bit register by debuggers, there is no convention for what values to use for bits 5 and 4 and their values should not be considered meaningful.

### C: Carry
- After ADC, this is the carry result of the addition.
- After SBC or CMP, both of which do subtraction, this flag will be set if no borrow was the result, or alternatively a "greater than or equal" result.
- After a shift instruction (ASL, LSR, ROL, ROR), this contains the bit that was shifted out.
- Increment and decrement instructions do not affect the carry flag.
- Can be set or cleared directly with SEC or CLC.

### Z: Zero
- After most instructions that have a value result, this flag will either be set or cleared based on whether or not that value is equal to zero.

### I: Interrupt Disable
- When set, IRQ interruptsare inhibited. NMI, BRK, and reset are not affected.
- Can be set or cleared directly with SEI or CLI.
- Automatically set by the CPU after pushing flags to the stack when any interrupt is triggered (NMI, IRQ/BRK, or reset). Restored to its previous state from the stack when leaving an interrupt handler with RTI.
- If an IRQ is pending when this flag is cleared (i.e. the /IRQline is low), an interrupt will be triggered immediately. However, the effect of toggling this flag is delayed 1 instruction when caused by SEI, CLI, or PLP.

### D: Decimal
- On the NES, decimal mode is disabled and so this flag has no effect. However, it still exists and can be observed and modified, as normal.
- On the original 6502, this flag causes some arithmetic instructions to use binary-coded decimalrepresentation to make base 10 calculations easier.
- Can be set or cleared directly with SED or CLD.

### V: Overflow
- ADC and SBC will set this flag if the signed result would be invalid [1], necessary for making signed comparisons [2].
- BIT will load bit 6 of the addressed value directly into the V flag.
- Can be cleared directly with CLV. There is no corresponding set instruction, and the NES CPU does not expose the 6502's Set Overflow (SO) pin.

### N: Negative
- After most instructions that have a value result, this flag will contain bit 7 of that result.
- BIT will load bit 7 of the addressed value directly into the N flag.

### The B flag

While there are only six flags in the processor status register within the CPU, the value pushed to the stack contains additional state in bit 4 called the B flag that can be useful to software. The value of B depends on what caused the flags to be pushed. Note that this flag does not represent a register that can hold a value, but rather a transient signal in the CPU controlling whether it was processing an interrupt when the flags were pushed. B is 0 when pushed by interrupts ( NMIand IRQ) and 1 when pushed by instructions (BRK and PHP).

| Cause | B flag |
| NMI | 0 |
| IRQ | 0 |
| BRK | 1 |
| PHP | 1 |

Because IRQ and BRK use the same IRQ vector, testing the state of the B flag pushed by the interrupt to the stack is the only way for an IRQ handler to distinguish between them. The B flag also allows software to identify whether interrupt hijackinghas occurred, where an NMI overrides the BRK instruction, but the B flag is still set by the BRK. However, testing this bit from the stack is fairly slow, which is one reason why BRK wasn't used as a syscall mechanism. Instead, it was more often used to trigger a patching mechanism that hung off the IRQ vector: a single byte in programmable ROM would be forced to 0, and the IRQ handler would pick something to do instead based on the program counter.

Some debugging tools, such as Visual6502, display the B flag as bit 4 of P as a matter of convenience. The user can see it turn off at the start of an interrupt and back on after the CPU reads the vector.

## External links
- koitsu's explanation

### References
- ↑Article: The Overflow (V) Flag Explained
- ↑Article: Beyond 8-bit Unsigned Comparisons, Signed Comparisons

# CPU unofficial opcodes

Source: https://www.nesdev.org/wiki/CPU_unofficial_opcodes

Unofficial opcodes , sometimes called illegal opcodes or undocumented opcodes , are CPU instructionsthat were officially left unused by the original design. The 6502 family datasheet from MOS Technology does not specify or document their function, but they actually do perform various operations.

Some of these instructions are useful; some are not predictable; some do nothing but burn cycles; some halt the CPU until reset. Most NMOS 6502 cores interpret them the same way, although there are slight differences with the less stable instructions. CMOS variants of the 6502 handle them completely differently, and later CPUs in the same family (e.g. 65C02, HuC6280, 65C816) were free to implement new instructions in the place of the unused ones.

An accurateNES emulator must implement all instructions, not just the official ones. A small number of games use them (see below).

## Arrangement

The microcode of the 6502 is compressed into a 130-entry decode ROM. Instead of 256 entries telling how to process each separate opcode, it's encoded as combinational logic post-processing the output of a "sparse" ROM that acts in some ways like a programmable logic array (PLA). Each entry in the ROM means "if these bits are on, and these bits are off, do things on these six cycles." [1]

Many instructions activate multiple lines of the decode ROM at once. Often this is on purpose, such as one line for the addressing mode and one for the opcode part. But many of the unofficial opcodes simultaneously trigger parts of the ROM that were intended for completely unrelated instructions.

Perhaps the pattern is easier to see by shuffling the 6502's opcode matrix. This table lists all 6502 opcodes, 32 columns per row. The columns are colored by bits 1 and 0: 00 red, 01 green, 10 blue, and 11 gray.

|  | +00 | +01 | +02 | +03 | +04 | +05 | +06 | +07 | +08 | +09 | +0A | +0B | +0C | +0D | +0E | +0F | +10 | +11 | +12 | +13 | +14 | +15 | +16 | +17 | +18 | +19 | +1A | +1B | +1C | +1D | +1E | +1F |

| 00 | BRK | ORA(d,x) | STP | SLO(d,x) | NOPd | ORAd | ASLd | SLOd | PHP | ORA#i | ASL | ANC#i | NOPa | ORAa | ASLa | SLOa | BPL*+d | ORA(d),y | STP | SLO(d),y | NOPd,x | ORAd,x | ASLd,x | SLOd,x | CLC | ORAa,y | NOP | SLOa,y | NOPa,x | ORAa,x | ASLa,x | SLOa,x |

| 20 | JSRa | AND(d,x) | STP | RLA(d,x) | BITd | ANDd | ROLd | RLAd | PLP | AND#i | ROL | ANC#i | BITa | ANDa | ROLa | RLAa | BMI*+d | AND(d),y | STP | RLA(d),y | NOPd,x | ANDd,x | ROLd,x | RLAd,x | SEC | ANDa,y | NOP | RLAa,y | NOPa,x | ANDa,x | ROLa,x | RLAa,x |

| 40 | RTI | EOR(d,x) | STP | SRE(d,x) | NOPd | EORd | LSRd | SREd | PHA | EOR#i | LSR | ALR#i | JMPa | EORa | LSRa | SREa | BVC*+d | EOR(d),y | STP | SRE(d),y | NOPd,x | EORd,x | LSRd,x | SREd,x | CLI | EORa,y | NOP | SREa,y | NOPa,x | EORa,x | LSRa,x | SREa,x |

| 60 | RTS | ADC(d,x) | STP | RRA(d,x) | NOPd | ADCd | RORd | RRAd | PLA | ADC#i | ROR | ARR#i | JMP(a) | ADCa | RORa | RRAa | BVS*+d | ADC(d),y | STP | RRA(d),y | NOPd,x | ADCd,x | RORd,x | RRAd,x | SEI | ADCa,y | NOP | RRAa,y | NOPa,x | ADCa,x | RORa,x | RRAa,x |

| 80 | NOP#i | STA(d,x) | NOP#i | SAX(d,x) | STYd | STAd | STXd | SAXd | DEY | NOP#i | TXA | XAA#i | STYa | STAa | STXa | SAXa | BCC*+d | STA(d),y | STP | AHX(d),y | STYd,x | STAd,x | STXd,y | SAXd,y | TYA | STAa,y | TXS | TASa,y | SHYa,x | STAa,x | SHXa,y | AHXa,y |

| A0 | LDY#i | LDA(d,x) | LDX#i | LAX(d,x) | LDYd | LDAd | LDXd | LAXd | TAY | LDA#i | TAX | LAX#i | LDYa | LDAa | LDXa | LAXa | BCS*+d | LDA(d),y | STP | LAX(d),y | LDYd,x | LDAd,x | LDXd,y | LAXd,y | CLV | LDAa,y | TSX | LASa,y | LDYa,x | LDAa,x | LDXa,y | LAXa,y |

| C0 | CPY#i | CMP(d,x) | NOP#i | DCP(d,x) | CPYd | CMPd | DECd | DCPd | INY | CMP#i | DEX | AXS#i | CPYa | CMPa | DECa | DCPa | BNE*+d | CMP(d),y | STP | DCP(d),y | NOPd,x | CMPd,x | DECd,x | DCPd,x | CLD | CMPa,y | NOP | DCPa,y | NOPa,x | CMPa,x | DECa,x | DCPa,x |

| E0 | CPX#i | SBC(d,x) | NOP#i | ISC(d,x) | CPXd | SBCd | INCd | ISCd | INX | SBC#i | NOP | SBC#i | CPXa | SBCa | INCa | ISCa | BEQ*+d | SBC(d),y | STP | ISC(d),y | NOPd,x | SBCd,x | INCd,x | ISCd,x | SED | SBCa,y | NOP | ISCa,y | NOPa,x | SBCa,x | INCa,x | ISCa,x |

Key: a is a 16-bit absolute address, and d is an 8-bit zero page address. Entries in bold represent unofficial opcodes.

But if we rearrange it so that columns with the same bits 1-0 are close together, correlations become easier to see:

|  | +00 | +04 | +08 | +0C | +10 | +14 | +18 | +1C | +01 | +05 | +09 | +0D | +11 | +15 | +19 | +1D | +02 | +06 | +0A | +0E | +12 | +16 | +1A | +1E | +03 | +07 | +0B | +0F | +13 | +17 | +1B | +1F |

| 00 | BRK | NOPd | PHP | NOPa | BPL*+d | NOPd,x | CLC | NOPa,x | ORA(d,x) | ORAd | ORA#i | ORAa | ORA(d),y | ORAd,x | ORAa,y | ORAa,x | STP | ASLd | ASL | ASLa | STP | ASLd,x | NOP | ASLa,x | SLO(d,x) | SLOd | ANC#i | SLOa | SLO(d),y | SLOd,x | SLOa,y | SLOa,x |

| 20 | JSRa | BITd | PLP | BITa | BMI*+d | NOPd,x | SEC | NOPa,x | AND(d,x) | ANDd | AND#i | ANDa | AND(d),y | ANDd,x | ANDa,y | ANDa,x | STP | ROLd | ROL | ROLa | STP | ROLd,x | NOP | ROLa,x | RLA(d,x) | RLAd | ANC#i | RLAa | RLA(d),y | RLAd,x | RLAa,y | RLAa,x |

| 40 | RTI | NOPd | PHA | JMPa | BVC*+d | NOPd,x | CLI | NOPa,x | EOR(d,x) | EORd | EOR#i | EORa | EOR(d),y | EORd,x | EORa,y | EORa,x | STP | LSRd | LSR | LSRa | STP | LSRd,x | NOP | LSRa,x | SRE(d,x) | SREd | ALR#i | SREa | SRE(d),y | SREd,x | SREa,y | SREa,x |

| 60 | RTS | NOPd | PLA | JMP(a) | BVS*+d | NOPd,x | SEI | NOPa,x | ADC(d,x) | ADCd | ADC#i | ADCa | ADC(d),y | ADCd,x | ADCa,y | ADCa,x | STP | RORd | ROR | RORa | STP | RORd,x | NOP | RORa,x | RRA(d,x) | RRAd | ARR#i | RRAa | RRA(d),y | RRAd,x | RRAa,y | RRAa,x |

| 80 | NOP#i | STYd | DEY | STYa | BCC*+d | STYd,x | TYA | SHYa,x | STA(d,x) | STAd | NOP#i | STAa | STA(d),y | STAd,x | STAa,y | STAa,x | NOP#i | STXd | TXA | STXa | STP | STXd,y | TXS | SHXa,y | SAX(d,x) | SAXd | XAA#i | SAXa | AHX(d),y | SAXd,y | TASa,y | AHXa,y |

| A0 | LDY#i | LDYd | TAY | LDYa | BCS*+d | LDYd,x | CLV | LDYa,x | LDA(d,x) | LDAd | LDA#i | LDAa | LDA(d),y | LDAd,x | LDAa,y | LDAa,x | LDX#i | LDXd | TAX | LDXa | STP | LDXd,y | TSX | LDXa,y | LAX(d,x) | LAXd | LAX#i | LAXa | LAX(d),y | LAXd,y | LASa,y | LAXa,y |

| C0 | CPY#i | CPYd | INY | CPYa | BNE*+d | NOPd,x | CLD | NOPa,x | CMP(d,x) | CMPd | CMP#i | CMPa | CMP(d),y | CMPd,x | CMPa,y | CMPa,x | NOP#i | DECd | DEX | DECa | STP | DECd,x | NOP | DECa,x | DCP(d,x) | DCPd | AXS#i | DCPa | DCP(d),y | DCPd,x | DCPa,y | DCPa,x |

| E0 | CPX#i | CPXd | INX | CPXa | BEQ*+d | NOPd,x | SED | NOPa,x | SBC(d,x) | SBCd | SBC#i | SBCa | SBC(d),y | SBCd,x | SBCa,y | SBCa,x | NOP#i | INCd | NOP | INCa | STP | INCd,x | NOP | INCa,x | ISC(d,x) | ISCd | SBC#i | ISCa | ISC(d),y | ISCd,x | ISCa,y | ISCa,x |

Thus the 00 (red) block is mostly control instructions, 01 (green) is ALU operations, and 10 (blue) is read-modify-write (RMW) operations and data movement instructions involving X. The RMW instructions (all but row 80 and A0) in columns +06, +0E, +16, and +1E have the same addressing modes as the corresponding ALU operations.

The 11 (gray) block is unofficial opcodes combining the operations of instructions from the ALU and RMW blocks. all of them having the same addressing mode as the corresponding ALU opcode. The RMW+ALU instructions that affect memory are easiest to understand because their RMW part completes during the opcode and the ALU part completes during the next opcode's fetch. Column +0B, on the other hand, has no extra cycles; everything completes during the next opcode's fetch. This causes instructions to have strange mixing properties. Some even differ based on analog effects.

## Games using unofficial opcodes

The use of unofficial opcodes is rare in NES games. It appears to occur mostly in late or unlicensed titles:
- Beauty and the Beast (E) (1994) uses $80 (a 2-byte NOP). [2]
- Disney's Aladdin (E) (December 1994) uses $07 (SLO). This is Virgin's port of the Game Boy game, itself a port of the Genesis game, not any of the pirate originals.
- Dynowarz: Destruction of Spondylus (April 1990) uses 1-byte NOPs $DA and $FA on the first level when your dino throws his fist.
- F-117A Stealth Fighter uses $89 (a 2-byte NOP).
- 文字广场+排雷 (romanized in GoodNES as Cantonese "Gaau Hok Gwong Cheung (Ch)"): After selecting the left game (排雷) from this 2-in-1 multicart, a glitchy 32 KiB bankswitchcauses the CPU to get lost in non-code ROM space that only with correct emulation of unofficial opcodes, including $8B (XAA immediate), will have it eventually reach a BRK instruction that properly branches to that game's reset handler.
- Infiltrator uses $89 (a 2-byte NOP).
- Ninja Jajamaru-kun uses $04 (a 2-byte NOP) when your ninja collides with an enemy, as a consequence of branching into the middle of an instruction.
- Puzznic (all regions) (US release November 1990) uses $89 (a 2-byte NOP).
- Super Cars (U) (February 1991) uses $B3 (LAX).

### Homebrew games
- The MUSE music engine, used in Driar and STREEMERZ: Super Strength Emergency Squad Zeta , uses $8F (SAX), $B3 (LAX), and $CB (AXS). [3]
- Attribute Zoneuses $0B (ANC), $2F (RLA), $4B (ALR), $A7 (LAX), $B3 (LAX), $CB (AXS), $D3 (DCP) and $DB (DCP).
- The port of Zork to the Famicom uses a few unofficial opcodes.
- Eyra, the Crow Maiden uses several unofficial opcodes.

## See also
- Programming with unofficial opcodes

## External links
- 6502 opcode matrix including unofficial opcodes
- 65C02and 65816
- Illegal opcodesat Wikipedia.
- 65xx Processor Data
- 6502_cpu.txt

## References
- ↑Michael Steil. " How MOS 6502 Illegal Opcodes really work". Pagetable , 2008-07-29. Accessed 2019-11-10.
- ↑puNES 0.20 changelogindicating $80 opcode in Beauty and the Beast .
- ↑http://forums.nesdev.org/viewtopic.php?p=100957#p100957

# CPU variants

Source: https://www.nesdev.org/wiki/CPU_variants

Beyond the well-studied 2A03G, we know of the following CPU revisions, both made by Ricoh and other manufacturers:

## Official (NTSC)

All official NTSC CPUs use a ÷12 clock divider.

| Part | Picture | First Seen | Last Seen | Notes |

| RP2A03 (ceramic) |  | 1983-06 3G1 09 | Likely similar to standard plastic RP2A03. |

| RP2A03 |  | 1983-07 3G2 ?7 | 1984-09 4J2 50 | M2 duty cycle is 17/24 instead of 15/24 [1]. Lacks tonal noise mode. APU Frame Counter not restarted on reset. Has broken and disabled programmable interval timer on-die. Pin 30 connects to nothing. Other differences? |

| RP2A03E |  | 1984-10 4K1 11 | 1986-06 6F1 23 | Pin 30 is /RDY - combined with internal signals before feeding to internal 6502 +RDY. |

| RP2A03G |  | 1987-04 7D3 A0 | 1993-11 3LM 5A | Reference model. Pin 30 enables a CPU test mode. Later runs introduced a DMC DMA bug [2]. |

| RP2A03H |  | 1993-12 3MM 40 | 1999-05 9EM 5B | No known differences from late RP2A03G. |

| RP2A03H (laser) |  | 2001-03 1CL 42 | 2002-11 2LL 4A |  |

| RP2A04 |  | 1986-03 6C2 01 | Not actually a CPU at all, just a jumper in a 40-pin PDIP. Used in place of CPUs in Vs. System boards (and thus with NTSC timing). |

## Official (PAL)

All official PAL CPUs use a ÷16 clock divider and they have different APU period tablesthan the NTSC CPUs.

| Part | Picture | First Seen | Last Seen | Notes |

| RP2A07 |  | 1987-03 7C4 39 | 1990-04 0DL 2G | Input clock divider is 16. M2 duty cycle is 19/32 [3]. Changes to noise, DPCM, frame timer tables. Fixed DPCM RDY address bus glitches. Pin 30 connects to 6502 /RDY input. |

| RP2A07A |  | 1991-06 1FM 3C | 1992-10 2KM 3L | There are no known differences relative to 2A07letterless. |

## Unofficial

There are many unofficial, or "clone" CPUs. Though they generally work quite well for what they are, there are many associated quirks and quality control issues. Keep these items in mind:
- Some clones have reversed duty cycles on the pulse channels, which causes the tone to sound different, but the pitch to remain correct.
- All known clone CPUs use the NTSC APU period tables, including those intended for PAL systems.
- The clock divider may be 12 (like official NTSC), 16 (like official PAL), or 15 (unique to clones) and this can be tested by dividing the master clock frequency by the observed M2 frequency.
- If you use the incorrect clock divider, the pitch of the sound and the speed of the gameplay will be affected. See thisdiscussion adapting to a different clock divider.

| Part | ClkDiv | Picture | Notes |
| MG-N-501 | ? |  |  |
| MG-P-501 | ? |  | Micro Genius-made clone. Die has the same (UMC) © Ⓜ B6167F marking as a UA6527P. |
| UA6527 | 12 |  | UMC-made clone of 2A03G. Has swapped pulse channel duty cycles. Input clock Divider is 12. |

| UA6527P | UMC-made clone of 2A03G for compatibility with NTSC software in PAL countries. Different input clock divider. Still has swapped pulse channel duty cycles. Otherwise believed same as 6527. One revision has (UMC) © Ⓜ B6167F 1989 09 on the die. DMC status bit is cleared 1 APU cycle later than on RP2A03 CPUs. The cause is not known. This changes the timing for DMC DMA implicit-stop glitches (the sample must be started 1 APU cycle earlier to trigger the glitches), and it is suspected that it delays DMC IRQ by 1 APU cycle. Noise channel is slightly louder than others. |
| 16 |  | Runs hot. Revisions without "-" in the date stamp have a ÷16 CPU divider, like 6540 and 2A07 |
| 15 |  | Runs hot. Revisions with "-" in the date stamp and text on the bottom may have a ÷15 CPU divider. |
| ? |  | Runs cooler |

| UA6527P(Relabeled) | Note that UA6527P chips are notorious for being other chips that were relabeled. In some cases, the chip has been sanded and relabeled, but it may still be possible to figure out what it actually is based on markings on the bottom of the chip. In other cases, the chip was painted and a new label was printed on top of that. If that's the case, the original label may be revealed by removing the paint. |
|  |  | Example top of a sanded, painted, and relabeled CPU. Note the level of freshness on the top side of the chip versus the generally filthy bottom side. Extrusion marks are not as deep as normal, or may be sanded away entirely. |
| 15 |  | This CPU has a ÷15 clock divider and correct duty cycles. These are the same bottom markings as a TA03-NP1. Pin 30 function is +TST. |
| 15 |  | This CPU has a ÷15 clock divider and reverse duty cycles. Pin 30 function is /RDY. |
| 15 |  | This CPU has a ÷15 clock divider and reverse duty cycles. Pin 30 function is /RDY. |
| 16 |  | This CPU has a ÷16 clock divider and reverse duty cycles. |
| 16 |  | This CPU has a ÷16 clock divider and reverse duty cycles. Pin 30 function is /RDY. |
| UA6527PQ | ? |  |  |

| UA6540 | 16 |  | UMC-made clone of 2A07 [4]. Has swapped pulse duty cycles. Subsequent research implies this is identical to the early 6527P - NTSC tuning tables, ÷16 CPU divider. [5] |
| UA6547 | ? |  | Believed to be a 100% duplicate of UA6527, for use in PAL-M region. |
| UM6557 | ? |  | Believed to be a 100% duplicate of UA6527, for use in SECAM regions. |
| UM6561xx-1 | 12 |  | NES-on-a-chip for NTSC. Revisions "xx" F, AF, BF, CF known. |

| UM6561xx-2 | ? |  | NES-on-a-chip for PAL-B. Revisions "xx" F, AF, BF, CF known. F and AF revision pulse wave duty cycles match RP2A03, and DMC status bit is cleared 1 APU cycle later than on RP2A03 CPUs. AF revision observed to have incorrect ASR #imm ($4B) behavior, but other stable illegal instructions work properly. |
| 1818N | ? |  | ??-made NES-on-a-chip, NTSC timing. |
| T1818P | ? |  | ??-made NES-on-a-chip[[6]. Requires external 2 KiB RAMs for CPU and PPU. Swapped pulse duty cycles. DMC status bit is cleared 1 APU cycle later than on RP2A03 CPUs. |

| TA-03N | 12 |  | ??-made die-mask clone of 2A03G. Chip underside also has two codes of currently unknown purpose. Pin 30 activates CPU Test Mode like on 2A03G. Clock Divisor is 12. Illegal opcodes are the same. Early 1991 dated chips are reported to have problems with APU DMC playback, but this was corrected in 1992 onward. |

| TA-03NP | 15or12 |  | ??-made clone of 2A03G for NTSC compatibility in PAL countries. Input clock divider is 15? But not this one, this input clock divider is 12. |

| TA-03NP1 | 15 |  | ??-made clone of 2A03G for NTSC compatibility in PAL countries. Input clock divider is 15. Fixed DPCM problems? Correct pulse channel duties. Noise channel is slightly louder than others. DMC status bit is cleared 1 APU cycle later than on RP2A03 CPUs. |
| PM03 | ? |  | Gradiente-made clone of 2A03G. [7] |

| GS87007 | 12 |  | (Goldstar??)-made clone of 2A03 - has functioning decimal mode? [8] Found in MicroGenius clone with PAL/NTSC switch.[1] |
| KC-6005 | ? |  | Found in MT777-DX famiclone, behaves exactly like UA6527P |
| 6005B | ? |  |  |
| 2011 | ? |  |  |
| “2A03E” | ? |  | Both with and without USC insignia |
| KP2B03E | ? |  |  |
| 6527-21 P03 | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is RDY. |
| 6527 | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is RDY. |
| 6527P | 16 |  | Clock divider is /16. Pulse channel duty cycles are swapped. Pin 30 is RDY. |
| 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is TEST. |
| HA6527P | 15 |  | Clock divider is /15. Pulse channel duty cycles are swapped. Pin 30 is RDY. |
| SENITON 6527P-SS-P03 | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is TEST. |
| SENITON 6527UP-8 | 15 |  | Clock divider is /15. Pulse channel duty cycles are swapped. Pin 30 is RDY. |
| SENITON 6527AP | 16 |  | Clock divider is /16. Pulse channel duty cycles are swapped. Pin 30 is RDY. |
| SL/WH6527AP | 15 |  | Clock divider is /15. Pulse channel duty cycles are swapped. Pin 30 is RDY. |
| SNC6527P | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is TEST. |
| XYZ-6783 | ? |  | Lacks tonal noise mode like original RP2A03, but resets APU Frame Counter on console reset like 2A03E/2A03G. Otherwise behaves like letterless RP2A03. |
| 6538N | ? |  | ??-made CPU, despite the part number being similar to UMC PPU. Has inverted duty cycles like UA6527. DPCM works. |
| 8Z01N | 12 |  | Found in Family Game by NTDEC. |
| TECH 27 | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is TEST. |
| HITEX-6527P-P03 GX | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is TEST. |
| WDL6527P | 15 |  | Clock divider is /15. Pulse channel duty cycles are correct. Pin 30 is RDY. |

If you know of other differences or other revisions, please add them!

## See also
- PPU variants
- https://forums.nesdev.org/viewtopic.php?p=45889#p45889
- https://forums.nesdev.org/viewtopic.php?t=23916(More Info on CPU Clones)
- https://forums.nesdev.org/viewtopic.php?t=23682(Lots of Images and die-shots)
- ↑https://forums.nesdev.org/viewtopic.php?p=241514#p241514
