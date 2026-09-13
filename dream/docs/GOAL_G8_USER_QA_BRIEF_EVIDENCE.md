# Goal G8 — §7 in-scene hand-feel brief

**Date:** 2026-09-13  
**Gap:** Jumping from checklist only showed「回§7清单」; pass criteria stayed on the checklist page.

## Code

- `DreamUI.arm_user_qa_brief(title, hint, expect)` stores criteria in `Engine` meta
- `DreamUI._add_user_qa_brief` mounts `UserQaBrief` panel (top-right under return chip)
- Checklist「跳转」/「跳转下一项未勾」/`mcp_jump_first` arm the brief
- Cleared with return-to-checklist / hub polish

## MCP

| Check | Result |
| --- | --- |
| `mcp_jump_first` | `brief_title=广场 C58–C60…`, armed |
| Runtime | `/root/VillageSquare/UI/UserQaBrief` visible |
| Shot | `g8_user_qa_brief_square.png` |

User §7 still open — this only reduces hand-feel friction.
