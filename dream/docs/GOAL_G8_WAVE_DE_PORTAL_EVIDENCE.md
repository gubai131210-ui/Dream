# Goal evidence — G8_WAVE_DE_PORTALS

**Date:** 2026-09-13  
**Runner:** `res://tools/g8_wave_de_portal_smoke.gd`  
**Result:** PASS (ok=3 fails=0)

## Headless enter

| Case | Host | Destination | Cues | Enter |
| --- | --- | --- | --- | --- |
| C32 | `market_street` | `c32_market_back` | DoorFacade/Doorstep/DoorArch | PASS |
| C46 | `c01_home` | `c46_second_floor` | same | PASS |
| C50 | `farm_residential` | `c50_farm_cellar` | same | PASS |

## Live MCP clicks

| Enter | Shot |
| --- | --- |
| Market 「进入市场后台」→ C32 | `docs/evidence/g8_portal_c32_enter.png` |
| C01 「↑二楼」→ C46 | `docs/evidence/g8_portal_c46_enter.png` |

User Godot QA still required (§7 portal hand-feel).
