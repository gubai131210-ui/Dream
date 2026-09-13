# Goal evidence — G8_C22_FISH_CAGE

**MCP date:** 2026-09-13  
**Scenes:** `river.tscn` + `lake.tscn`  
**Nodes:** `FishCage_river_west_bend_cage` · `FishCage_lake_east_dock_cage`

## Sync MCP API (`fish_cage.gd`)

| Probe | Result |
| --- | --- |
| `mcp_place()` | `ok=true`, `phase=soaking`, empty cage sprite |
| `mcp_cycle_to_ready()` | `ok=true`, `phase=ready`, title「可收」, `fish_cage_full_00` |
| `mcp_collect()` | `ok=true`, `phase=empty`, empty cage sprite |

## Live shots

| Shot | Path |
| --- | --- |
| River soaking | `docs/evidence/g8_river_fish_cage_soaking.png` |
| River ready | `docs/evidence/g8_river_fish_cage_ready.png` |
| Lake ready | `docs/evidence/g8_lake_fish_cage_ready.png` |

## Headless

`tools/g8_c22_fish_cage_smoke.gd` — **river + lake** place→ready→collect; **ok=6 fails=0 PASS**.

User Godot QA still required (§7 river/lake cage).
