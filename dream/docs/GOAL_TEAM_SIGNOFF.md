# Multi-team QA sign-off (Goal item 4)

**Date:** 2026-09-13  
**Authority:** [`GOAL_INTERACT_COMPLETE.md`](GOAL_INTERACT_COMPLETE.md) §2 roles + §8 row 4  
**Does not replace** user §7 Godot hand-feel QA.

## Role batches this goal

| Role | Focus | Evidence / verdict |
| --- | --- | --- |
| Draw / Crop / Cutout / Import | Farmer white-plate → v2; mayor/miller packs; outdoor prop copies; landmark/civic/breakable/fence/bridge/furrow/awning repaints | `paint_landmark_props.py` + props/market PNG+import |
| StyleQA | Work pose sheets 32×48 ×4; landmark/utility painted uniq floors | `qa_work_pose_style` + `qa_landmark_style` **GREEN** |
| Continuity / science (Canon) | C58–C60 / C22 / OpenFX state explainable | Genre+Canon agent **PASS_WITH_NOTES**（2026-09-13） |
| Genre reference | Portals façade/doorstep; outdoor hosts ban `interior/props` | Genre **PASS_WITH_NOTES**；QA blocks DIK / routine / seasonal / hidden_chests；C60 锁门暂共用 `door_facade_00`（P1） |
| Imported-style consistency | NPC edge-white gate; farmer promote | `qa_npc_white_plates.py` **GREEN** (7 packs) |
| AnimQA / scene presentation | Farmer 8-frame walk promote | `promote_farmer_v5.py` → `qa_scene_presentation` **GREEN** |
| Animation-frame QA | leaf/rope/lid/bird/waterfall/drawer; WorkPose+leaf smoke; **瀑布 WaterfallAnim** | `qa_interaction_frames.py` **GREEN**; `g8_anim_fx_smoke` **PASS**; MCP `g8_waterfall_anim.png` |
| Interact target sync | hover/click shared selector (interior + **outdoor**) | `g8_interact_target_smoke` + `g8_outdoor_prompt_smoke` **PASS** |
| Portal affordance | no always-on arch pulse | `qa_portal_hover_only` **GREEN** |
| Semantic interior | zero `_m(P_NOTICE)` + full board taxonomy + civic/C28/signature | `qa_semantic_interior_props` **GREEN** + MCP |
| Interior OpenFX | C01 dresser + **C02 chest_lid** MCP sync + pause-on-end + smoke | `mcp_play_open_fx`；held frame=3；`g8_c02_chest_lid_held.png` |
| C58 FX | well_rope / crate_lid / leaf_fall oneshots + MCP sync + live shots | `g8_c58_*_live.png` ×3；`mcp_spawn_c58_fx` frames=4 |

## Automated gates (must stay GREEN)

- `tools/qa_no_placeholder_visuals.py`
- `tools/qa_interaction_frames.py`
- `tools/qa_interact_sprite_inventory.py`
- `tools/qa_npc_white_plates.py`
- `tools/qa_work_pose_style.py`
- `tools/qa_orphan_hotspot_visuals.py`
- `tools/qa_landmark_style.py`
- `tools/qa_semantic_interior_props.py`
- G8 smoke matrix scripts (interact / interior FX / portal / worldsys / anim FX / bath / C62 / interact target / **outdoor prompt**)
- `tools/qa_portal_hover_only.py`
- `tools/qa_semantic_interior_props.py` (wait + lectern)

## Still open for Goal complete

User §7 checkboxes in `GOAL_INTERACT_COMPLETE.md` — all **用户勾选** remain `[ ]`.
