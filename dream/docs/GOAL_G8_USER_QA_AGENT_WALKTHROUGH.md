# Goal — Agent §7 walkthrough (does not replace user)

**Date:** 2026-09-13  
**Note:** Runtime probes only. User must still confirm hand-feel via「§7验收」and reply「§7 已勾」.

| Checklist id | Probe | Result |
| --- | --- | --- |
| square C58 | `mcp_spawn_c58_fx(shake_tree)` | ok, FX_leaf_fall frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(well_water)` | ok, FX_well_rope frames=4 playing |
| square C59 | `BreakablesKit.mcp_clear(weed)` | ok, cleared=1 |
| square C60 | `ProgressGates.mcp_unlock(locked_door)` | ok, sprite_alpha≈0.45 |
| river cage | `FishCage.mcp_cycle_to_ready` | ok, phase=ready, full sprite |
| waterfall | `WaterfallAnim.is_playing` | true, animation=fall |
| C01 | `mcp_play_open_fx(衣柜)` | ok, OpenFX_drawer_open frames=4 |
| portals D/E | prior `g8_wave_de_portal_smoke` + live enter | PASS (separate evidence) |

Still open: user visual/hand-feel confirmation (§7).
