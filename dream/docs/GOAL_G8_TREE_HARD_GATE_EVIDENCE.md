# GOAL G8 — Tree hard-gate + §7 brief MCP

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel.

## Change

- Removed `WorldInteractKit._setup_tree_marker` (Polygon2D canopy/trunk production fallback).
- `shake_tree` now `push_error` if `PropSprite` missing; formal `tree_00.png` required.
- `qa_interact_sprite_inventory.py` hard-fails if TreeCanopyCue / `_setup_tree_marker` returns, or `tree_00` / scale-0 regresses.
- Taxonomy: G2 row no longer says “StyleQA 抛光仍开放”.

## MCP evidence

1. `run_scene` → `user_qa_checklist.tscn`
2. `mcp_jump_first` → square; `armed=true`, brief_title 广场…
3. Runtime `/root/VillageSquare/UI/UserQaBrief` present; `UserQaReturnBtn` present
4. `WorldHS_摇树/Visual` children: Marker(debug) + Tag + ContactShadow + **PropSprite** — **no** TreeCanopyCue / TreeTrunkCue
5. Screenshot: `docs/evidence/g8_user_qa_brief_tree_hard_gate.png`

## QA

- `qa_interact_sprite_inventory` / `qa_no_placeholder_visuals` / `qa_landmark_style` / `qa_work_pose_style` GREEN
