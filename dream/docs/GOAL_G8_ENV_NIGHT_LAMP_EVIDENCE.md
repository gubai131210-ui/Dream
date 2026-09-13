# Goal G8 — Env-H night grade + outdoor lamp glow

**Date:** 2026-09-13  
**Gap closed:** Radial lamp textures were invisible in daytime screenshots; only plaza had `DayNightWeather`. Lamp hosts (plaza / lighthouse / station) now share Env-H night grade so §7 / MCP can verify light result under dusk.

## Code

- `DayNightWeather.mcp_set_night(on)` — sync MCP probe
- Attach Env-H on `lighthouse_controller` + `station_controller` (plaza already had it)
- `WorldInteractKit.mcp_activate` — full interact (lamp toggle + FX); `mcp_spawn_c58_fx(lamp_toggle)` reports light fields
- Interior lights DRY → `WorldSpawnUtil.radial_light_texture()`
- §7 hints: 广场/灯塔/车站 mention **N夜间**

## MCP

| Host | Call | Result |
| --- | --- | --- |
| plaza | `DayNightWeather.mcp_set_night(true)` | night=true, modulate present |
| plaza | `mcp_spawn_c58_fx("lamp_toggle")` | has_light_texture=true, lamp_on=true, energy=0.85 |
| plaza | `mcp_activate("lamp_toggle")` | lamp_on=false, energy=0 |
| lighthouse | `mcp_set_night(true)` | night=true (Env-H mounted) |

Shots (camera @ lamp, zoom=2, night grade):

- `docs/evidence/g8_square_lamp_night_on.png`
- `docs/evidence/g8_square_lamp_night_off.png`

Taxonomy: `ASSET_TAXONOMY` layer **H** notes outdoor DayNight + radial PointLight.

User §7 still open — hand-feel N + lamp toggle on square/lighthouse/station.
