# GOAL G8 — Stall / fishing / portal ColorRect–Polygon hard-gate

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel.

## Change

Removed production ColorRect/Polygon fallbacks for shipped interactables:

| Surface | Before | After |
| --- | --- | --- |
| C05 `MarketStall` | ColorRect poles/awning/board/bay | sprites only; `push_error` if missing |
| `FishingSpot` | ColorRect buoy/pulse/bubble/drops; Polygon ring | sprites only |
| `FishCage` | Polygon water ring | `fish_ring_00` Sprite2D only |
| Portal doorstep/arch (`WorldSpawnUtil`) | Polygon fallback | sprites only |
| Crop furrows (`AreaCraft`) | ColorRect rows | `furrow_line_00` only |

## QA

`qa_no_placeholder_visuals.py` now fails if ColorRect/Polygon production helpers return on stall/fishing/cage/furrow/portal doorstep.

## MCP

- Market `MarketStall_n_w` cycle → locked: StallLayers = **Sprite2D only** (`g8_stall_locked_sprite_only.png`)
- River bobber + cage: **WaterRing Sprite2D**; `mcp_cast_fx` frames=4 (`g8_fishing_sprite_only_ring.png`)
