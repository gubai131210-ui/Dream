# Multi-team QA sign-off (Goal item 4)

**Date:** 2026-09-13  
**Authority:** [`GOAL_INTERACT_COMPLETE.md`](GOAL_INTERACT_COMPLETE.md) §2 roles + §8 row 4  
**Does not replace** user §7 Godot hand-feel QA.

## Role batches this goal

| Role | Focus | Evidence / verdict |
| --- | --- | --- |
| Draw / Crop / Cutout / Import | Farmer white-plate → v2; mayor/miller packs; outdoor prop copies; landmark/civic/breakable/fence/bridge/furrow/awning repaints | `paint_landmark_props.py` + props/market PNG+import |
| StyleQA | Work pose sheets 32×48 ×4; landmark/utility painted uniq floors | `qa_work_pose_style` + `qa_landmark_style` **GREEN**（2026-09-13 re-run） |
| Continuity / science (Canon) | C58–C60 / C22 / OpenFX state explainable | Genre+Canon agent **PASS_WITH_NOTES**（2026-09-13 refresh） |
| Genre reference | Portals façade/doorstep; outdoor hosts ban `interior/props` | Genre **PASS_WITH_NOTES**（refresh）；QA blocks DIK / routine / seasonal / hidden_chests；**C60 锁门=`gate_locked_door_00`** |
| Imported-style consistency | NPC edge-white gate; farmer promote | `qa_npc_white_plates.py` **GREEN** (7 packs) |
| AnimQA / scene presentation | Farmer 8-frame walk promote | `promote_farmer_v5.py` → `qa_scene_presentation` **GREEN** |
| Animation-frame QA | leaf/rope/lid/bird/waterfall/drawer; WorkPose+leaf smoke; **瀑布 WaterfallAnim** | `qa_interaction_frames.py` **GREEN**; `g8_anim_fx_smoke` **PASS**; MCP `g8_waterfall_anim.png` |
| Interact target sync | hover/click shared selector (interior + **outdoor**) | `g8_interact_target_smoke` + `g8_outdoor_prompt_smoke` **PASS** |
| District multi-frame | DIK keyword→C58 FX sheets | `GOAL_G8_DISTRICT_FX_EVIDENCE.md`；market/forest MCP |
| Portal affordance | no always-on arch pulse | `qa_portal_hover_only` **GREEN** |
| Semantic interior | zero `_m(P_NOTICE)` + full board taxonomy + civic/C28/signature | `qa_semantic_interior_props` **GREEN** + MCP |
| Interior OpenFX | C01 dresser + **C02 chest_lid** MCP sync + pause-on-end + smoke | `mcp_play_open_fx`；held frame=3；`g8_c02_chest_lid_held.png` |
| C58 FX | well/crate/tree/bird oneshots + pause-on-end + MCP live ×4 | smoke held_ok；`g8_c58_*_live.png` |
| C59 Breakables | stake/weed sprites + `mcp_clear` + **clear FX** | `GOAL_G8_C59_BREAKABLES_EVIDENCE.md`；`GOAL_G8_C59_C61_FX_EVIDENCE.md` |
| C61 Hidden chests | coin_chest + lid + `mcp_open` **5/5 sites** | `GOAL_G8_C60_C61_FULL_EVIDENCE.md`；well + tree/waterfall/cave/island MCP |
| C05 stall cycle FX | state tap → crate_lid / board_rustle / leaf_fall | `GOAL_G8_C05_STALL_FX_EVIDENCE.md`；`mcp_cycle` |
| Integer zoom (agent) | plaza zoom=(1,1) + C53 work ring visible | `g8_square_zoom1_work_pose_v3.png`（用户 §7 仍待手感） |
| C22 cage splash | place/collect → fish_splash×4 oneshot | `GOAL_G8_C22_CAGE_SPLASH_EVIDENCE.md`；`mcp_splash` frames=4 |
| C58 lamp spark | lamp_toggle → lamp_spark×4；DIK lamp 同 sheet | `GOAL_G8_C58_LAMP_SPARK_EVIDENCE.md` |
| Interior tap FX | non-open props → TapFX_* (C58 sheets) | `GOAL_G8_INTERIOR_TAP_FX_EVIDENCE.md`；C07 blackboard/desk/lamp |

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
