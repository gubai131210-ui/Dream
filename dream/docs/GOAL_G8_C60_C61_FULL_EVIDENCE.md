# Goal evidence — C60 unlock FX + C61 all sites

**Date:** 2026-09-13  

## C60 ProgressGates unlock FX

| id | FX | MCP |
| --- | --- | --- |
| locked_door | `board_rustle`×4 | fx_playing=true, sprite_alpha≈0.45 |
| fallen_log | `leaf_fall`×4 | ok |
| boulder | `bench_dust`×4 | ok |

Shot: `docs/evidence/g8_c60_unlock_fx_door.png`（InfoPanel「锁门·通」）

## C61 HiddenChests `mcp_open` — all 5 sites (shots + smoke)

| site_id | host | frames | playing | shot |
| --- | --- | --- | --- | --- |
| well | village_square | 4 | true | `g8_c61_well_chest_open.png` |
| tree_behind | forest_deep | 4 | true | `g8_c61_tree_chest_open.png` |
| waterfall | waterfall | 4 | true | `g8_c61_waterfall_chest_open.png` |
| cave | hill_farm | 4 | true | `g8_c61_cave_chest_open.png` |
| island | lake | 4 | true | `g8_c61_island_chest_open.png` |

**Smoke:** `res://tools/g8_c61_chests_smoke.gd` — opens all five via `mcp_open`, asserts frames≥4.

User §7 still required.
