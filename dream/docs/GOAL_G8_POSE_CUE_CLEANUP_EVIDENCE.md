# Goal G8 — WorkPoseCue cleanup + C54 eat bowl cue

**Date:** 2026-09-13  
**Gaps:** Rapid K/L left `WorkPoseCue_dying` stubs (deferred `queue_free` rename). C54 `eat` cue used `stove_00` (cook prop) instead of a bowl.

## Code

- `npc_routine_demo.gd`: `_clear_work_pose_cues()` immediately `free()`s all `WorkPoseCue*` before spawn
- `debug_force_work_pose` reports `dying=N`
- `eat` → `res://assets/sprites/props/bowl_00.png` (painted via `paint_pose_deep.paint_bowl_prop`)

## MCP

| Call | Result |
| --- | --- |
| `debug_force_work_pose` | `cue=true dying=0` |
| Rapid `cycle_work_ring` ×2 + force | still `dying=0`, single `WorkPoseCue` |
| Life `eat` | bowl cue; `g8_c54_life_pose_eat_bowl.png` |

Gate: `qa_interact_fx_coverage` asserts `_clear_work_pose_cues` + `bowl_00.png`.

User §7 still open.
