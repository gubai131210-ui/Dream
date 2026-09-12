# Goal G8 C58 multi-frame FX evidence

**Date:** 2026-09-13  
**Runner:** `res://tools/g8_c58_fx_smoke.gd`  
**Result:** PASS (exit=0)

## What it proves

On plaza `WorldInteractKit` activate:

| Interact | FX node | Frames |
| --- | --- | ---: |
| `well_water` | `FX_well_rope` | 4 |
| `crate_search` | `FX_crate_lid` | 4 |
| `shake_tree` | `FX_leaf_fall` | 4 |

Each FX is an `AnimatedSprite2D` playing `oneshot` immediately after `_handle_interact`.

## Related

- `tools/qa_interaction_frames.py` now includes `well_rope` / `crate_lid` / `leaf_fall` / `bird_peck` groups  
- Prior anim smoke: `GOAL_G8_ANIM_FX_EVIDENCE.md` (pose + leaf)
