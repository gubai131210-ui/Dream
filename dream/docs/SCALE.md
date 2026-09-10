# Dream — Scale Lock (`SCALE.md`)

**Status:** LOCKED  
**Date:** 2026-09-10  
**Scope:** Gameplay grid, character/building proportions, Godot import rules for AI asset sheets.

This document is the single source of truth for pixel scale. All TileMaps, collision, interaction radii, and sliced sprites must obey these constants. Do not invent a second grid.

---

## 1. Locked constants

| Constant | Value | Meaning |
|---|---|---|
| `BASE_TILE` | **32** | Gameplay tile edge length in pixels. One TileMap cell = 32×32. |
| `HALF_TILE` | 16 | Convenience half-cell. |
| `CHARACTER_HEIGHT_PX` | **48–64** | Standing character silhouette height (≈ **1.5–2.0** tiles). Target midpoint **56 px**. |
| `CHARACTER_WIDTH_PX` | 24–40 | Typical body width; keep under **1.25** tiles. |
| `COTTAGE_HEIGHT_TILES` | **3–5** | Cottage / small house total height (**96–160 px**). |
| `TOWN_HALL_HEIGHT_TILES` | **5–8** | Landmark / town hall height (**160–256 px**). |
| `PROP_SMALL_TILES` | **0.5–1.5** | Barrels, crates, flowers, lamps (**16–48 px** tall). |
| `PROP_LARGE_TILES` | **1.5–3** | Carts, stalls, large crates (**48–96 px** tall). |
| `TREE_HEIGHT_TILES` | **3–6** | Canopy trees (**96–192 px**). |
| `INTERACT_RADIUS_TILES` | **1.0–1.5** | Default NPC / prop interact distance. |

### Why `BASE_TILE = 32` (not native sheet cell)

Source sheets are AI tilesheets on black backgrounds. They **do not** divide evenly by 32 or 64, and native “cells” are much larger than a playable Stardew-like tile. Gameplay therefore uses a **normalized 32 px grid**. Assets are sliced / scaled into that grid before TileSet / Sprite2D use.

---

## 2. Measured sheet evidence

Paths: source under `素材/素材文件/`, preview copies under `_preview/`.

### 2.1 Canvas sizes

| Sheet | Preview / source | Canvas | Notes |
|---|---|---|---|
| B01-01 grass | `_preview/b01_grass.png` | **1448×1086** RGB | Black bg, loose grid of grass swatches |
| A01 / A09 / A16 | `_preview/a01.png` etc. | **1448×1086** RGB | Full-bleed reference compositions (not tilemaps) |
| B03 / B13 / B15 / B12 / B14 | various | **1448×1086** RGB | Sprite sheets on black |
| B08-02 houses | `_preview/b08_house.png` | **1254×1254** RGB | Multi-house sheet on black |
| B11 props | `_preview/b11_props.png` | **1254×1254** RGB | Prop clusters on black |

### 2.2 Divisibility (failure of native 32/64 packing)

| Dimension | `% 32` remainder | `% 64` remainder |
|---|---|---|
| 1448 (W) | **8** | **40** |
| 1086 (H) | **30** | **62** |
| 1254 (W/H) | **6** | **38** |

**Conclusion:** Do **not** auto-slice AI sheets with a rigid 32×32 or 64×64 atlas assumption. Detect content islands / manual crop first, then normalize to `BASE_TILE`.

### 2.3 B01-01 grass — native cell estimate

Content bbox ≈ `(22,20)–(1426,1043)` → **1404×1023**.

Connected grass swatches (96 islands):

| Metric | Value (px) |
|---|---|
| Tile width | min 101 / **median 105** / max 108 / mean 105.1 |
| Tile height | min 108 / **median 114** / max 128 / mean 115.2 |
| Column gap (empty) | ≈ **12–14** |
| Row gap (empty) | ≈ **9–15** |
| Column pitch (sep spacing) | ≈ **117–119** (mode ~119) |
| Row pitch (sep spacing) | ≈ **123–135** (mode ~124) |
| Layout | ≈ **12 columns × 8 rows** of swatches |

**Native grass cell estimate: ~105×114 px** (pitch ~118×128).  
**Gameplay tile after normalize: 32×32** (one swatch may become a 3×3 or 4×4 atlas of variants after downscale/crop — slicer decides; gameplay cell stays 32).

### 2.4 B08-02 buildings — native blob estimate

Five major house islands (downsampled CC, scaled back):

| Approx size (W×H) | Role guess |
|---|---|
| 566×626 | Large landmark / multi-story |
| 546×586 | Large house |
| 482×444 | Mid cottage |
| 286×442 | Tall narrow |
| 296×382 | Small cottage |

Median native height ≈ **444 px**. After scale-to-character (see §3), cottages land in **3–5 tiles**, landmarks **5–8 tiles**.

### 2.5 B14 characters — native blob estimate

Standing NPC islands (three sheets sampled):

| Sheet sample | Height median / mean | Width median |
|---|---|---|
| B14 sheet A | **174 / 174** | ~88 |
| B14 sheet B | **188 / 180** | ~98 |
| B14 sheet C | **192 / 186** | ~103 |

**Native character height ≈ 170–200 px.**  
Must downscale to **48–64 px** display height (~**0.28–0.35×**).

### 2.6 B11 / B12 / B13 props & critters

| Pack | Native blob heights (median-ish) | After char-scale → tiles @32 |
|---|---|---|
| B11 props | ~230 px (large props); smaller ~50–66 | ~1.5–2.5 tiles / ~0.5 tile |
| B12 crops | ~174 px tall, ~88 wide | ~1.5–2 tiles if unscaled — usually crop to **1–2 tiles** |
| B13 animals | ~185 px | scale with characters → **~1–2 tiles** |

---

## 3. Proportion rules (authoring)

Relative to `BASE_TILE = 32` and `CHARACTER_HEIGHT_PX = 56` (midpoint):

1. **Player / NPC** — feet on tile baseline; head ≤ 2 tiles above feet.
2. **Door** — opening ≥ character height; width ≥ 1 tile.
3. **Cottage** — eave/ridge 3–5 tiles; footprint typically 3–6 tiles wide.
4. **Town hall / landmark** — 5–8 tiles tall; must still read as “big but walkable,” not a skyscraper.
5. **Props** — never taller than a cottage unless intentional landmark. Small yard props (sack/crate/barrel/lamp) must spawn at **display scale ≤0.55** — see `PROP_ORIENTATION.md`.
6. **Barrel pose** — default **upright** `barrel_1`; horizontal `barrel_0` only for market wine/stall specialty (`PROP_ORIENTATION.md`).
7. **Shore rocks** — landmark bank rocks ≈ **½ character height** (scale ~0.28–0.35); no tree AABB overlap; contact shadow required.
8. **A01 / A09 reference comps** — use for *relative* silhouette hierarchy only (world overview / village square mood). They are **not** 1:1 tilemaps; do not import as TileSet.

### Suggested downscale from native AI sprites

```
scale ≈ CHARACTER_HEIGHT_PX / native_char_height
      ≈ 56 / 180  ≈ 0.31
```

Apply the **same** scale family to buildings/props sliced from the same art pass so silhouettes match A09.

---

## 4. Godot import rules (mandatory)

For every pixel art / AI-sheet PNG under `assets/`:

| Setting | Value | Reason |
|---|---|---|
| Compress Mode | **Lossless** | Avoid blocky chroma on soft AI pixels |
| Filter | **Nearest** (`texture_filter = nearest`) | Crisp pixel edges; no bilinear smear |
| Mipmaps | **Off** (unless distant LOD explicitly needed) | Prevents blur on 32 px tiles |
| Fix Alpha Border | On when converting black-bg → transparent | Clean sprite edges |
| HDR / Normal Map | Off unless authored | |

Project / scene defaults:

- Root `Window` / `Viewport` stretch: keep integer scale when possible (1×, 2×, 3× of design resolution).
- TileMap: `tile_size = Vector2i(32, 32)`.
- Never upscale with linear filtering for gameplay sprites.

### Pipeline folders

```
dream/assets/raw/      ← untouched copies / sourced sheets
dream/assets/sliced/   ← cropped islands + transparency
dream/assets/tilesets/ ← 32×32 (or N×32) atlas + TileSet resources
dream/assets/sprites/  ← characters, props, FX at display scale
```

---

## 5. Failure criteria (reject / re-slice)

A change **fails review** if any of the following is true:

1. **Wrong grid** — TileMap or collision uses a cell size other than **32×32** without an ADR amending this file.
2. **Native sheet as TileSet** — importing 1448×1086 / 1254×1254 AI sheets directly as a 32-or-64 atlas without slicing.
3. **Character out of band** — standing height outside **48–64 px** (except cutscenes / intentionally giant bosses, documented).
4. **Building out of band** — cottage outside **3–5** tiles tall, or town hall outside **5–8**, without design note.
5. **Soft pixels** — Filter ≠ Nearest or Compress ≠ Lossless on gameplay art.
6. **Scale drift** — mixing unscaled native AI sprites (~180 px chars) with normalized 32-grid tiles in the same playable scene.
7. **Black matte left on** — sprites still keyed to sheet black background in-game.
8. **Non-integer camera zoom** that makes 32 px tiles shimmer (unless temporary debug).

---

## 6. Quick reference (copy into code)

```gdscript
# scripts/core/scale.gd  (canonical numbers — keep in sync with this doc)
const BASE_TILE: int = 32
const CHARACTER_HEIGHT_MIN: int = 48
const CHARACTER_HEIGHT_MAX: int = 64
const CHARACTER_HEIGHT_TARGET: int = 56
const COTTAGE_HEIGHT_TILES_MIN: int = 3
const COTTAGE_HEIGHT_TILES_MAX: int = 5
const TOWN_HALL_HEIGHT_TILES_MIN: int = 5
const TOWN_HALL_HEIGHT_TILES_MAX: int = 8
```

---

## 7. Measurement appendix

- Tooling: Python 3 + Pillow + NumPy (`_analyze_scale.py` at repo root; disposable).
- Method: black-background threshold (RGB ≤ 18), content bbox, gap/run occupancy, connected-component island sizes.
- Locked decision: **`BASE_TILE = 32`** despite native grass cell **~105×114**.
