# Multi-team QA sign-off (Goal item 4)

**Date:** 2026-09-13  
**Authority:** [`GOAL_INTERACT_COMPLETE.md`](GOAL_INTERACT_COMPLETE.md) §2 roles + §8 row 4  
**Does not replace** user §7 Godot hand-feel QA.

## Role batches this goal

| Role | Focus | Evidence / verdict |
| --- | --- | --- |
| Draw / Crop / Cutout / Import | Farmer white-plate → v2; mayor/miller packs; outdoor prop copies; landmark/civic/breakable/fence/bridge/furrow/awning repaints | `paint_landmark_props.py` + props/market PNG+import |
| StyleQA | Work pose sheets 32×48 ×4; landmark/utility painted uniq floors | `qa_work_pose_style` + `qa_landmark_style` **GREEN** |
| Continuity / science (Canon) | C58–C60 / C22 state explainable | Genre+Canon agent **PASS** |
| Genre reference | Portals façade/doorstep; outdoor hosts ban `interior/props` | Genre **PASS**; QA blocks DIK / routine / seasonal / hidden_chests |
| Imported-style consistency | NPC edge-white gate; farmer promote | `qa_npc_white_plates.py` **GREEN** (7 packs) |
| Animation-frame QA | leaf/rope/lid/bird/waterfall/drawer; WorkPose+leaf smoke | `qa_interaction_frames.py` **GREEN**; `g8_anim_fx_smoke` **PASS** |

## Automated gates (must stay GREEN)

- `tools/qa_no_placeholder_visuals.py`
- `tools/qa_interaction_frames.py`
- `tools/qa_interact_sprite_inventory.py`
- `tools/qa_npc_white_plates.py`
- `tools/qa_work_pose_style.py`
- `tools/qa_orphan_hotspot_visuals.py`
- `tools/qa_landmark_style.py`
- G8 smoke matrix scripts (interact / interior FX / portal / worldsys / anim FX / bath)

## Still open for Goal complete

User §7 checkboxes in `GOAL_INTERACT_COMPLETE.md` — all **用户勾选** remain `[ ]`.
