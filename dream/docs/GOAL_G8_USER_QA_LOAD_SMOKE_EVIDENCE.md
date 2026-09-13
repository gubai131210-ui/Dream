# Goal G8 — §7 checklist load + interact smoke (21/21)

**Date:** 2026-09-13  
**Note:** Agent load/attach probe only — **does not** mark user §7 checks or close Goal.

## Runner

`tools/g8_user_qa_load_smoke.tscn` + `g8_user_qa_load_smoke_runner.gd`

For each of the 21「§7验收」scenes: instantiate → wait `_ready` → assert:

| Scene class | Required nodes / affordances |
| --- | --- |
| All outdoor | `DayNightWeather` + `AreaInteractHost` |
| square | + `WorldInteractKit` + `BreakablesKit` + `ProgressGates` |
| market | + descendant `MarketStall_*` |
| river / lake | + `FishCage_*` or `FishingSpot_*` |
| waterfall | + `WaterfallAnim` |
| forest | + `SecretPassageChain` / Secret* / `Portal_*` |
| other outdoor districts | + `DistrictInteractKit` |
| interiors (C01/C02/C06/C40/C43/C32/C46) | non-empty tree + descendant `Portal_*` |

## MCP (enriched probe)

| Probe | Result |
| --- | --- |
| Console | `G8_USER_QA_LOAD: done ok=21 fails=0` (all 21 PASS lines) |
| `mcp_status()` | `ok=true passed=21 total=21 fails=0 done=true` |
| Shot | [`evidence/g8_user_qa_interact_smoke_21.png`](evidence/g8_user_qa_interact_smoke_21.png) |

Prior shallow smoke shot: `evidence/g8_user_qa_load_smoke_21.png` (DayNight+AreaInteract only).

User §7 hand-feel still required.
