# Seamless terrain (no grid seams)

## Problem

Ground looked like separate pads because:

1. **Art seams** — AI grass swatches have dark vignette borders; placing them adjacent draws a grid.
2. **Atlas gutters** — slicing left transparent pixels between cells.
3. **Engine bleed** (secondary) — Linear filtering / non-integer zoom can add hairline gaps.

Refs: Godot TileSet `use_texture_padding`, Nearest filter, snap 2D transforms; pixel-art wrap-offset seamless technique.

## Solution in this project

1. `tools/make_seamless_terrain.py` strips vignette, forces wrap-matched edges, writes:
   - `assets/tilesets/grass_seamless_atlas.png`
   - `assets/tilesets/stone_seamless_atlas.png`
   - `assets/tilesets/dirt_seamless_atlas.png`
2. Village square paints **base fill** from seamless variants (random), not bordered AI pads.
3. `TileSetFactory` enables `use_texture_padding` and Nearest on layers.
4. Camera zoom snapped to whole numbers where possible.

## Rebuild

```powershell
python dream/tools/make_seamless_terrain.py
```

Then re-run the square scene in Godot.
