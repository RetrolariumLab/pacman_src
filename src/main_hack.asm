; Explicit entrypoint for optional behavior-changing builds
; The preservation entrypoint src/main.asm never defines hack feature flags

PACMAN_HACK_START_STAGE = 5

.include "main.asm"
