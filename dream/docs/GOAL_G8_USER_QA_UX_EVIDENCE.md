# Goal G8 — §7 checklist UX + demo actor cleanup

**Date:** 2026-09-13  
**Why:** Agent side saturated; only user §7 closes Goal — reduce hand-feel friction without auto-checking.

## Changes

- `user_qa_checklist.gd`: outdoor/indoor group headers; green **通过标准** per row; **跳转下一项未勾**; `mcp_next_unchecked`
- `npc_routine_demo.gd`: `_clear_demo_actors()` immediate free (no `NpcRingDemoActor_dying` stubs)
- C54 sleep cue → `pillow_00.png` (Genre note vs hay)
- Genre/Canon refresh: **PASS_WITH_NOTES** ([Review](58c453e8-b637-43f5-aa8d-b94255293955))

## MCP

| Call | Result |
| --- | --- |
| checklist `mcp_next_unchecked` | remaining=21, id=square, expect present |
| Shot | `docs/evidence/g8_user_qa_checklist_v3.png` |

User §7 still open — this only helps the human gate, does not close it.
