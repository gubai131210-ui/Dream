# Goal G8 C58 multi-frame FX evidence

**Date:** 2026-09-13  
**Runner:** `res://tools/g8_c58_fx_smoke.gd`  
**Result:** PASS (exit=0) — re-run 2026-09-13 after FX hold + MCP probe

## What it proves

On plaza `WorldInteractKit` activate:

| Interact | FX node | Frames |
| --- | --- | ---: |
| `well_water` | `FX_well_rope` | 4 |
| `crate_search` | `FX_crate_lid` | 4 |
| `shake_tree` | `FX_leaf_fall` | 4 |

Each FX is an `AnimatedSprite2D` playing `oneshot` immediately after `_handle_interact`.

## MCP live (editor)

- `WorldInteractKit.mcp_spawn_c58_fx(id)` sync probe → `ok` + `frames=4` + `playing=true` for well / crate / tree  
- InfoPanel activate copy: `docs/evidence/g8_c58_well_rope_live.png`（取水 / 井绳吱呀）  
- Oneshot holds last frame ~2s so short clips remain readable

## Related

- `tools/qa_interaction_frames.py` includes `well_rope` / `crate_lid` / `leaf_fall` / `bird_peck` groups  
- Prior anim smoke: `GOAL_G8_ANIM_FX_EVIDENCE.md` (pose + leaf)
