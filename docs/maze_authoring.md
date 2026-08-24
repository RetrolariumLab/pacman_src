# Maze Authoring

Maze Studio is the local editor for the expanded variant's stage-2 maze:

```text
make init-expanded-assets
make maze-studio
```

The editor renders the 27x22 grid directly from the original background CHR,
offers all 64 maze tile IDs, paints complete mouse strokes with one-step Undo,
supports Redo and right-click eyedropper selection, and shows the row, column,
tile ID, and known role under the pointer. Blue cell borders indicate differences
from the extracted original maze.

Semantic overlays identify the fixed tunnel endpoints, ghost-house bounds and
door, Pac-Man and ghost spawn cells, and current power pellets. These landmarks
are deliberately read-only: they document constraints in the original engine
rather than adding expanded-only actor-coordinate tables or conditional runtime
code.

## Export contract

Save and Save As write JSON atomically. Export is rejected unless:

- the grid is exactly 27x22 with tile IDs `$00..$3F`;
- row-bounded RLE fits the fixed 416-byte expanded allocation;
- the maze contains 192 collectible tiles and four visible power pellets;
- the normal playfield and six-cell house interior retain their expected
  connectivity;
- the `$2C` house door, actor spawn cells, and tunnel endpoints remain valid.

The encoder greedily forms runs of at most four tiles without crossing a row,
then deterministically splits runs until the existing 416-byte layout is filled.
Thus editing the maze does not move the later expanded assets or modify the
preservation build.

`Build ROM` and `Run FCEUX` pass the currently saved JSON explicitly to the
expanded targets. Unsaved changes are never built. The normal `make verify`
continues to reproduce the original ROM byte for byte.
