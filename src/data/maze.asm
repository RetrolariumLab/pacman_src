; Compressed maze layout

; The format is decoded by sub_decompress_and_upload_maze_layout
; It is kept as an extracted asset until a checked, editable encoder exists
; Each byte uses its upper two bits as a run-length code and lower six bits
; as a tile id

tbl_maze_rle_stream:
    .incbin "assets/generated/maze/maze.rle"
