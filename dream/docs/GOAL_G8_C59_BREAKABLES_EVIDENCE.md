# Goal evidence — G8_C59_BREAKABLES

**MCP date:** 2026-09-13  
**Kit:** `BreakablesKit` on `village_square`

## Live MCP

| Probe | Result |
| --- | --- |
| Stake PropSprite | present (`breakable_stake_00`) — `g8_c59_breakables_stake.png` |
| Weed PropSprite | present (`breakable_weed_00`) — `g8_c59_breakables_weed.png` |
| `BreakablesKit.mcp_clear("stake")` | `ok=true`, `cleared=1`, `remaining_nodes=3` |
| After clear | InfoPanel + stake removed — `g8_c59_stake_cleared.png` |

Headless: covered by `g8_worldsys_activate_smoke` (breakables=4).

User Godot QA still required (§7).
