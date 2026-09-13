# Goal G8 — §7 checklist load + interact smoke (21/21)

**Date:** 2026-09-13  
**Note:** Agent load/attach probe only — **does not** mark user §7 checks or close Goal.

## Runner

`tools/g8_user_qa_load_smoke.tscn` + `g8_user_qa_load_smoke_runner.gd`

Name matching uses **exact** / **prefix** only (no substring `contains`) to avoid false-pass on `WorldPortal_*`.

| Scene class | Required nodes / affordances |
| --- | --- |
| All outdoor | `DayNightWeather` + `AreaInteractHost` |
| square | + `WorldInteractKit` + `BreakablesKit` + `ProgressGates` |
| market | + `MarketStall_*` + `DistrictInteractKit` |
| river / lake | + `FishCage_*` or `FishingSpot_*` + `DistrictInteractKit` |
| waterfall | + `WaterfallAnim` + `DistrictInteractKit` + `SecretPassageChain_*` |
| forest | + `SecretPassageChain_*` + portal with `meta.secret_chain` (or 密道/暗河/瀑后 label) |
| other outdoor districts | + `DistrictInteractKit` |
| interiors | non-empty tree + `Portal_Return` / `Portal_Extra_*` |

## MCP (tightened probe)

| Probe | Result |
| --- | --- |
| Console | `G8_USER_QA_LOAD: done ok=21 fails=0` |
| `mcp_status()` | `ok=true passed=21 total=21 fails=0 done=true` |
| Shot | [`evidence/g8_user_qa_interact_smoke_21.png`](evidence/g8_user_qa_interact_smoke_21.png) |

Review fix: forest no longer accepts ordinary `WorldPortal_*` alone; interiors correctly expect `Portal_*` (not outdoor `WorldPortal_*`).

User §7 hand-feel still required.
