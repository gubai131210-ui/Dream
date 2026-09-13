# GOAL G8 — Hub §7 entry + WIP profile quarantine

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel.

## Hub entry MCP

1. `run_scene` `world_hub.tscn`
2. TopBar `EnterUserQa` text=`§7验收`, visible, enabled
3. `emit_signal(pressed)` → `/root/UserQaChecklist` loaded
4. Screenshot: `docs/evidence/g8_hub_user_qa_entry.png`

## WIP quarantine

Moved stale profile forks out of live scripts path (contained old `P_NOTICE` markers that confused audits):

- `scripts/interiors/_wip_archive/` (gitignored)
- Live source of truth remains `interior_profiles.gd` only
