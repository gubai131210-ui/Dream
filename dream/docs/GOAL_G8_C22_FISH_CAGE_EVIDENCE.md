# Goal evidence — G8_C22_FISH_CAGE

**MCP date:** 2026-09-13  
**Scene:** `res://scenes/areas/river/river.tscn`  
**Node:** `YSortRoot/FishCage_river_west_bend_cage`

## Sync MCP API (`fish_cage.gd`)

| Probe | Result |
| --- | --- |
| `mcp_place()` | `ok=true`, `phase=soaking`, title「浸泡中」, sprite `fish_cage_00` |
| `mcp_cycle_to_ready()` | `ok=true`, `phase=ready`, title「可收」, sprite `fish_cage_full_00` |
| `mcp_collect()` | `ok=true`, `phase=empty`, title base, sprite `fish_cage_00` |

## Live shots

| Shot | Path |
| --- | --- |
| Soaking | `docs/evidence/g8_river_fish_cage_soaking.png` |
| Ready（提示「收取渔获」） | `docs/evidence/g8_river_fish_cage_ready.png` |

## Headless

`tools/g8_c22_fish_cage_smoke.gd` — place → force ready → collect; **ok=3 fails=0**.

User Godot QA still required (§7 river/lake cage).
