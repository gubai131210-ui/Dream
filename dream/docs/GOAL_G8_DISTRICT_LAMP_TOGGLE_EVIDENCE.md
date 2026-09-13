# Goal G8 — District lamp light toggle (Genre parity)

**Date:** 2026-09-13  
**Gap closed:** Genre note — DIK lamps had `lamp_spark` + Info only; plaza `lamp_toggle` also toggles `PointLight2D` + sprite modulate.

## Code

- `district_interact_kit.gd`: `_setup_lamp` / `_toggle_lamp` on `id.contains("lamp")`
- Interact body →「路灯已点亮/熄灭。」
- `mcp_spawn_fx(*lamp*)` toggles + reports `lamp_on` / `has_light`

Hosts with lamps: `station` (`stn_lamp`), `lighthouse` (`light_lamp`).

## MCP

| Call | Result |
| --- | --- |
| lighthouse `mcp_spawn_fx("light_lamp")` #1 | `lamp_blurb=路灯已熄灭。` `lamp_on=false` `has_light=true` frames=4 |
| #2 | `路灯已点亮。` `lamp_on=true` energy=0.85 |
| #3 | off again; LampLight `enabled=false` `energy=0` |
| station `mcp_spawn_fx("stn_lamp")` | off + spark×4 |

Shots: `g8_district_lighthouse_lamp_on.png` / `g8_district_lighthouse_lamp_off.png`

Gate: `qa_interact_fx_coverage.py` asserts `_setup_lamp` / `_toggle_lamp` / `PointLight2D`.

User §7 still open.
