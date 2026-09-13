# Goal G8 — Portal DoorFacade inventory smoke

**Date:** 2026-09-13  
**Note:** Agent runtime inventory — does **not** close user §7.

## Runner

`tools/g8_portal_facade_smoke.tscn` + `g8_portal_facade_smoke_runner.gd`

Covers **14 outdoor + 56 interiors = 70 scenes**. Every `WorldPortal_*` / `Portal_*` / `Portal_Return` / `Portal_Extra*` must have a `DoorFacade` `Sprite2D` with non-null texture.

## MCP

| Probe | Result |
| --- | --- |
| `mcp_status()` | `ok=true passed_scenes=70/70 portals_ok=161 fails=0` |
| Shot | [`evidence/g8_portal_facade_smoke_70.png`](evidence/g8_portal_facade_smoke_70.png) |

Pairs with hotspot sprite inventories (outdoor 554 + interior 958).
