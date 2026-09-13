# Goal G8 — Held sleep pillow MCP + Env-H cleanup

**Date:** 2026-09-13  

## Code

- `NpcRoutineDemo.mcp_force_life_pose(id)` — force life ring + **hold** cue (no fade) for screenshots
- Sleep pillow cue scale 0.55; `prop_path=pillow_00.png` returned by MCP
- Removed C58 leaf/grain Polygon2D fallbacks (sprite FX always present)
- Stripped vestigial dusk-hold / restore-timer fields from `DayNightWeather`
- §7 square item hint/expect mention sticky night lamp + sleep pillow

## MCP

| Field | Value |
| --- | --- |
| `mcp_force_life_pose("sleep")` | `ok`, `prop_scale≈0.55`, `prop_path=.../pillow_00.png` |
| Shot | `g8_c54_pillow_closeup.png` (zoom 2 at cue) |

User §7 still open.
