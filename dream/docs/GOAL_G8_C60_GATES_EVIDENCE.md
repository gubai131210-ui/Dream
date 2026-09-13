# Goal evidence — G8_C60_GATES

**MCP date:** 2026-09-13  
**Kit:** `ProgressGates` on `village_square`

## Live MCP

| Probe | Result |
| --- | --- |
| Locked door sprite | `gate_locked_door_00` — `g8_c60_locked_door.png` |
| `ProgressGates.mcp_unlock("locked_door")` | `ok=true`, `sprite_alpha≈0.45`, `unlocked_count=1` |
| After unlock | InfoPanel「锁门·通」+「锁已打开…」+ sprite_alpha≈0.45 — `g8_c60_locked_door_unlocked.png` |
| Fallen log sprite | repainted `gate_log_00` (uniq≥60) — `g8_c60_fallen_log.png` |

Headless: `g8_worldsys_activate_smoke` gates≥3.

User Godot QA still required (§7).
