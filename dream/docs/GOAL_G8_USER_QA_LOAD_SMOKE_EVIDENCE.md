# Goal G8 — §7 checklist load smoke (21/21)

**Date:** 2026-09-13  
**Note:** Agent load/attach probe only — **does not** mark user §7 checks or close Goal.

## Runner

`tools/g8_user_qa_load_smoke.tscn` + `g8_user_qa_load_smoke_runner.gd`  
For each of the 21「§7验收」scenes: instantiate → wait `_ready` → assert outdoor has `DayNightWeather` + `AreaInteractHost` (interiors: non-empty tree).

## MCP

| Probe | Result |
| --- | --- |
| `mcp_status()` | `ok=true passed=21 total=21 fails=0 done=true` |
| Shot | `docs/evidence/g8_user_qa_load_smoke_21.png` |

CLI Godot binary was not found on PATH in this environment; smoke was run via editor MCP.

User §7 hand-feel still required.
