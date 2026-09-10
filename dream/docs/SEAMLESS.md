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
4. River is a **meandering mask** (not a straight canal); bank cells use damp grass with mud/reed detail. See `LAYOUT.md`.
5. **Per-district ecology weights** — do not use one distance mapping everywhere. See `AREA_FRAMEWORK.md` and zone profiles in `.cursor/skills/realistic-scene-craft/reference-formulas.md`.

| District | Stronger grass bias |
| --- | --- |
| Plaza | `mowed` near stone; `damp` west bank |
| Residential | `meadow` yards; `mowed` only on lanes |
| Farm home | `meadow` + occasional `weed`; less stone-adjacent mow |
| Farmland | `meadow` matrix; crop beds are **dirt**, not grass variants |
| Market | `mowed` along street; avoid `tall` inside stall band |

## Rebuild

```powershell
python dream/tools/make_seamless_terrain.py
```

Then re-run the village square scene in Godot.

## Forbidden shortcuts (anti-lazy)

- One `dpath`→grass mapping for every district
- Farmland crop beds painted as grass variants instead of dirt rectangles
- Shipping vignette-bordered AI swatches as wrap fillers
- Claiming “seamless” after only engine padding without wrap-matched art
- Skipping bank `damp` on water neighbors
