# Goal G8 waterfall water animation evidence

**Date:** 2026-09-13  
**Scene:** `res://scenes/areas/waterfall/waterfall.tscn`  
**Assembler:** `scripts/areas/waterfall_assembler.gd` → `_spawn_waterfall_anim`

## Result

**PASS (MCP runtime)** — cascade uses `AnimatedSprite2D` `WaterfallAnim`, not static tall/mid fallback.

## Runtime proof

| Check | Evidence |
| --- | --- |
| Node | `/root/Waterfall/YSortRoot/瀑布/Visual/WaterfallAnim` class `AnimatedSprite2D` |
| Animation | `fall` loop @ 8 fps; frames `waterfall_water_00..05` |
| Playing | `is_playing() == true`; `get_frame()` observed advancing (e.g. frame 5) |
| Hotspot | `瀑布` at ~(656, 396); Visual owns cascade **and splash** |
| Scale | `WaterfallAnim.scale = (0.55, 0.55)` after review widen |
| Capture | `docs/evidence/g8_waterfall_anim.png` |

## Assets / QA

- Frames: `assets/sprites/props/waterfall_water_00.png` … `_05.png` (from `waterfall_water_anim_sheet_v3.png` via `tools/slice_waterfall_water_frames.py`)
- `tools/qa_interaction_frames.py` asserts `waterfall_water` group + assembler `WaterfallAnim` wiring

## Note

Static `waterfall_tall_00` / `waterfall_mid_00` remain **fallback only** when fewer than 4 loop frames load.
