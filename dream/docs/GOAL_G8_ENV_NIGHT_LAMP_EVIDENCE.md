# Goal G8 — Env-H night grade + outdoor lamp glow

**Date:** 2026-09-13  
**Gap closed:** Radial lamp textures were invisible in daytime screenshots; Env-H was plaza-only then lamp-hosts-only. **All 14 outdoor area controllers** now mount `DayNightWeather` so every district can N-toggle night for §7 / MCP.

## Code

- `DayNightWeather.mcp_set_night(on)` — sync MCP probe
- Attach Env-H on **all** `scripts/areas/*_controller.gd` outdoor hosts (plaza / market / farmland / residential / farm_home / forest×2 / river / lake / waterfall / lighthouse / hill_farm / station / lake_house)
- `WorldInteractKit.mcp_activate` — full interact (lamp toggle + FX); `mcp_spawn_c58_fx(lamp_toggle)` reports light fields
- Interior lights DRY → `WorldSpawnUtil.radial_light_texture()`
- §7 hints: 广场/灯塔/车站 mention **N夜间**

## MCP

| Host | Call | Result |
| --- | --- | --- |
| plaza | `mcp_set_night(true)` + lamp on/off | night=true; `g8_square_lamp_night_on/off.png` |
| station | `mcp_set_night(true)` + `mcp_spawn_fx(stn_lamp)` | night=true; off energy=0; `g8_station_lamp_night_on/off.png` |
| lighthouse | `mcp_set_night(true)` + `mcp_spawn_fx(light_lamp)` | night=true; off energy=0; `g8_lighthouse_lamp_night_on/off.png` |
| forest_deep | `mcp_set_night(true)` | night=true (CanopyTint-safe path) |

Taxonomy: `ASSET_TAXONOMY` **H** + `ENV_H.md` — outdoor-wide thin mounts.

Gate: `qa_interact_fx_coverage.py` asserts every `*_controller.gd` has `DayNightWeather.attach_to`.

User §7 still open — hand-feel **N** + lamp toggle where lamps exist.
