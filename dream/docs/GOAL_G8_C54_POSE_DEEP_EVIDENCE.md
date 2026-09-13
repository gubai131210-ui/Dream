# Goal G8 — C53/C54 pose deep-paint (P1)

**Date:** 2026-09-13  
**Gap:** Pose sheets were farmer/elder walk recolor + face-adjacent stamps; Genre/Goal §5 P1 asked for contact poses. `read` life cue wrongly used `flower_bed_00`.

## Code / art

- `tools/paint_pose_deep.py` — re-paint work (sow/smith/stall/cook) + life (eat/sleep/read/laundry/idle_sit) 32×48×4
  - Tools at mid/side (hoe, hammer+spark, crate, ladle+steam)
  - Life: bowl at chest, closed eyes+Z, **open book mid-torso**, washboard, stool sit
- New prop `assets/sprites/props/book_open_00.png`
- `npc_routine_demo.gd`: `read` cue → `book_open_00` (not flower_bed)

## Gates / MCP

| Check | Result |
| --- | --- |
| `qa_work_pose_style` | GREEN (uniq≫80, edge-white≤12) |
| `qa_interact_fx_coverage` | asserts `book_open_00` wiring |
| `mcp_probe_life_poses` | 5/5 anim+cue frames=4 |

Shots:

- `docs/evidence/g8_c53_work_pose_deep.png`
- `docs/evidence/g8_c54_life_pose_read_deep.png`

User §7 still open (K/L hand-feel).
