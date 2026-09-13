# Goal G8 — §7 checklist agent-ready + progress poll

**Date:** 2026-09-13  
**Note:** Does not mark user checks or close Goal.

## Changes

- Checklist subtitle states Agent smoke **21/21 PASS**
- `mcp_progress()` returns `done/total/checked/unchecked` from `user://goal_user_qa.cfg` for agent polling
- Hub「§7验收」tooltip: Agent 冒烟已就绪

## MCP

| Probe | Result |
| --- | --- |
| `mcp_progress()` | `done=0 total=21 all_done=false` (userdata cfg absent) |
| Live square | `mcp_spawn_c58_fx(shake_tree)` leaf_fall×4; `lamp_toggle` lamp_spark×4 + light |
| qa_* suite | all GREEN (frames/fx/style/semantic/…) |
| Shot | `evidence/g8_user_qa_checklist_agent_ready.png` |

User must still hand-feel 21 items and reply「§7 已勾」.
