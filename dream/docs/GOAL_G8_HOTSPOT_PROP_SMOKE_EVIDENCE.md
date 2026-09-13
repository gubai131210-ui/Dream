# Goal G8 — Outdoor hotspot formal-pixel inventory smoke

**Date:** 2026-09-13  
**Note:** Agent runtime inventory — does **not** close user §7.

## Runner

`tools/g8_hotspot_prop_smoke.tscn` + `g8_hotspot_prop_smoke_runner.gd`

For each of 14 outdoor areas: instantiate → collect `interactable_hotspots` under host → require nested `Sprite2D` / `AnimatedSprite2D` (covers `PropSprite`, MarketStall `StallLayers`, FishingSpot `Bobber`, reparented building sprites). PatrolActor exempt (walk sheets).

## MCP

| Probe | Result |
| --- | --- |
| `mcp_status()` | `ok=true passed_scenes=14/14 hotspots_ok=554 fails=0` |
| Shot | [`evidence/g8_hotspot_prop_smoke_14.png`](evidence/g8_hotspot_prop_smoke_14.png) |

Also: square + interior `_make_hotspot` now call `AreaCraft.repair_user_text`; encoding QA expanded to all `scripts/**/*.gd`.
