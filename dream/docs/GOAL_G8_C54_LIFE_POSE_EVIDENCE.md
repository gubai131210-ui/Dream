# Goal G8 — C54 life pose multi-frame cues

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel QA.

## Gap closed

C54 life cycle (`cycle_life_state`) spawned actors + InfoPanel but **skipped** pose sheets (`kind != "work"`). Objective wants multi-frame feedback where applicable for listed interactions/rings.

## Change

- Generated `assets/sprites/npc/life_poses/{eat,sleep,read,laundry,idle_sit}/pose_00..03.png` (32×48) via `paint_life_poses.py` (elder_woman base).
- `npc_routine_demo.gd`: life path uses same `WorkPoseCue` + `WorkPoseAnim` + outdoor prop anchors.
- QA: `qa_work_pose_style` covers life kinds; `qa_interaction_frames` +5 groups; `qa_no_placeholder_visuals` requires `life_poses`.

## MCP evidence

| Probe | Result |
| --- | --- |
| `NpcRoutineDemo.mcp_probe_life_poses` | ok, count=5；eat/sleep/read/laundry/idle_sit each frames=4 playing |
| Shot (sleep sample) | `docs/evidence/g8_c54_life_pose_sleep.png` |

User §7 still required.
