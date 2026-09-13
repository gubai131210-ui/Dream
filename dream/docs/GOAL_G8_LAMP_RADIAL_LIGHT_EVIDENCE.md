# Goal G8 — Outdoor lamp radial PointLight texture

**Date:** 2026-09-13  
**Gap closed:** Genre note — plaza + District `PointLight2D` had energy/modulate but **no light texture** (interior already used `_radial_light_texture`). Soft radial falloff was missing outdoors.

## Code

- `WorldSpawnUtil.radial_light_texture()` + `configure_lamp_light(light, …)`
- `world_interact_kit.gd` `_setup_lamp` → `configure_lamp_light`
- `district_interact_kit.gd` `_setup_lamp` → same helper
- `mcp_spawn_fx(*lamp*)` now returns `has_light_texture` / `light_enabled` / `light_energy`

## MCP

| Scene | Probe | Result |
| --- | --- | --- |
| lighthouse | `mcp_spawn_fx("light_lamp")` | `has_light_texture=true`, on: energy=0.85, off: energy=0 |
| lighthouse | LampLight query | `texture=<GradientTexture2D>` |
| village_square | LampLight on `WorldHS_路灯` | `texture=<GradientTexture2D>`, energy=0.85 |

Zoomed framing shots (camera @ lamp, zoom=2.5):

- `docs/evidence/g8_district_lighthouse_lamp_on_zoom.png`
- `docs/evidence/g8_district_lighthouse_lamp_off_zoom.png`

Note: daytime outdoor scenes stay bright — radial glow is most obvious with dusk/`CanvasModulate`; MCP fields prove texture assignment. Off state still dims `PropSprite` modulate.

Gate: `qa_interact_fx_coverage.py` asserts `configure_lamp_light` / `radial_light_texture` wiring.

User §7 still open.
