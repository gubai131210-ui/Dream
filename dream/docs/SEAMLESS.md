# Seamless terrain (no grid seams)

## Problem

Ground looked like separate pads because:

1. **Art seams** — AI grass swatches have dark vignette borders.
2. **Leftover old pads** — bordered deco / tree bases along the west strip.
3. **Monotone fill** — one tile everywhere looks flat.
4. **Engine bleed** (secondary) — Linear filter / non-integer zoom.

## Solution

1. `tools/make_seamless_terrain.py` builds wrap-matched tiles (`L==R`, `T==B`) with ecological types:
   - **mowed** — short grass near roads / plaza (foot traffic + upkeep)
   - **meadow** — open yards
   - **tall** — map edges / low-traffic corners
   - **weed** — disturbed patches
   - **damp** — riverbank
2. Assembler **clears** TileMapLayers first, paints by distance-to-path / edge / water, removes old `grass_atlas` deco pads, moves west trees inland.
3. `TileSetFactory`: `use_texture_padding` + Nearest; camera zoom snaps to integers.

## Rebuild

```powershell
python dream/tools/make_seamless_terrain.py
```

Then re-run the village square scene in Godot.
