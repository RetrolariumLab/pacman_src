; Official ROM revision profiles.
; Keep the preservation source on Japan V1.0 unless an entrypoint explicitly
; selects another profile before including main.asm.

REVISION_JAPAN_V10 = 0
REVISION_JAPAN_V11 = 1

.ifndef PACMAN_REVISION
PACMAN_REVISION = REVISION_JAPAN_V10
.endif

.assert PACMAN_REVISION >= REVISION_JAPAN_V10, error, "invalid Pac-Man revision"
.assert PACMAN_REVISION <= REVISION_JAPAN_V11, error, "invalid Pac-Man revision"
