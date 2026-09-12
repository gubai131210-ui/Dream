# Goal G8 MCP runtime evidence

**Date:** 2026-09-13  
**MCP:** tomyud1 `godot-mcp-server` 0.6.0 · Godot connected · `MCPRuntime` OK  
**Errors:** 0 (square + C01 + museum enter runs)

## Captures

| Shot | Path | What it proves |
| --- | --- | --- |
| Square idle | `docs/evidence/g8_square_idle.png` | Outdoor district art + UI; C58 props present |
| Square interact | `docs/evidence/g8_square_well_click.png` / `g8_square_lamp_click.png` | Click → InfoPanel feedback |
| Portal enter | `docs/evidence/g8_portal_museum_enter.png` | Square portal → C40 museum interior (return UI visible) |
| C01 idle | `docs/evidence/g8_c01_home_idle.png` | Interior art + fire FX + return portals |
| C01 dresser open | `docs/evidence/g8_c01_dresser_open.png` | InfoPanel「衣柜」+ runtime `OpenFX_drawer_open` |

## Runtime queries (editor)

- Museum portal children: `DoorFacade` + `DoorstepCue` + `DoorArchCue`
- Well hotspot `Visual/Marker.visible = false`; `PropSprite` present
- Lamp `Visual` includes `PropSprite` + `PointLight2D` (`LampLight`)
- Dresser after click: `FocusCorners` + `OpenFX_drawer_open` (`AnimatedSprite2D`)
- Portal click at museum cue → scene change to museum interior (header「博物馆」)

## Still required for Goal complete

User Godot QA §7 checkboxes (visual fidelity / Waves A2–F) — MCP shots do **not** replace human playthrough sign-off.
