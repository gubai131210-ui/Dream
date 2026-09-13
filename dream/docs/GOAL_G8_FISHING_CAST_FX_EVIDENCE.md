# Goal G8 — Fishing cast multi-frame splash

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel QA.

## Gap closed

`FishingSpot.play_cast_fx` was pulse-ring only. Cast/catch now prefer the 4-frame `fish_splash` sheet (same as C22 cage / bite).

## Change

- `fishing_spot.gd`: `play_cast_fx` / `play_catch_fx` → `_spawn_splash()`; splash oneshot **pause-on-end**; `mcp_cast_fx`.
- `tools/qa_interior_tap_fx.py`: static gate for interior TapFX wiring + crate-before-board order.

## MCP evidence

| Probe | Result |
| --- | --- |
| Lake `FishingSpot_lake_east_dock.mcp_cast_fx` | ok, FX_fish_splash frames=4 |
| Shot | `docs/evidence/g8_fishing_cast_splash_held.png` |

User §7 still required.
