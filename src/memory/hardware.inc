; NES CPU-visible hardware registers used by the source reconstruction.
; Read/write aliases are kept where the same address has different hardware roles.

PPUCTRL             = $2000
PPUMASK             = $2001
PPUSTATUS           = $2002
OAMADDR             = $2003
OAMDATA             = $2004
PPUSCROLL           = $2005
PPUADDR             = $2006
PPUDATA             = $2007

OAMDMA              = $4014
APU_STATUS          = $4015
JOYPAD1             = $4016
JOYPAD2             = $4017
APU_FRAME_COUNTER   = $4017

; PPUCTRL ($2000)
PPUCTRL_SPRITE_PATTERN_HIGH     = $08
PPUCTRL_NMI_ENABLE              = $80

; PPUMASK ($2001)
PPUMASK_SHOW_BG_LEFT            = $02
PPUMASK_SHOW_SPRITES_LEFT       = $04
PPUMASK_SHOW_LEFT_EDGE          = PPUMASK_SHOW_BG_LEFT + PPUMASK_SHOW_SPRITES_LEFT
PPUMASK_SHOW_BG                 = $08
PPUMASK_SHOW_SPRITES            = $10
PPUMASK_RENDERING_ENABLE        = PPUMASK_SHOW_BG + PPUMASK_SHOW_SPRITES

; APU_STATUS ($4015)
APU_STATUS_ENABLE_ALL           = $1F

; JOYPAD1/JOYPAD2 ($4016/$4017 reads, $4016 write)
JOYPAD_STROBE                   = $01
JOYPAD_SERIAL_BIT               = $01
JOYPAD_READ_MASK                = $03

; APU_FRAME_COUNTER ($4017 write)
APU_FRAME_COUNTER_IRQ_INHIBIT   = $40
APU_FRAME_COUNTER_5_STEP        = $80
