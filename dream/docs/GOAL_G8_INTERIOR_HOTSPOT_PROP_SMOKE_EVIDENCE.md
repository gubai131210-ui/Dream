# Goal G8 — Interior hotspot formal-pixel inventory smoke

**Date:** 2026-09-13  
**Note:** Agent runtime inventory — does **not** close user §7.

## Runner

`tools/g8_interior_hotspot_prop_smoke.tscn` + `g8_interior_hotspot_prop_smoke_runner.gd`

Auto-discovers all `res://scenes/interiors/*/*.tscn` (56). For each: instantiate → `interactable_hotspots` under host → require nested `Sprite2D` / `AnimatedSprite2D`. PatrolActor / AmbientCritter exempt.

## MCP

| Probe | Result |
| --- | --- |
| `mcp_status()` | `ok=true passed_scenes=56/56 hotspots_ok=958 fails=0` |
| Shot | [`evidence/g8_interior_hotspot_prop_smoke_56.png`](evidence/g8_interior_hotspot_prop_smoke_56.png) |

Paired with outdoor smoke (`GOAL_G8_HOTSPOT_PROP_SMOKE_EVIDENCE.md` — 14/14, 554 OK).
