; NES CPU-visible hardware registers used by the preservation source.
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
