# NPC walk animation + diversity

**Problem:** Market/areas reuse `npc_00` + `idle_frame_*` from one grandma sheet; patrol only tweens `position` (sliding).

**Sources (already in `assets/raw/`):**
- `B14_npc_01.png` — elder woman (walk 4×4 + sit/wave/knit)
- `B14_npc_02.png` — station master (walk 4×4 + sit/gesture)
- `B14_npc_03.png` — blacksmith (walk 4×4 + anvil/wave)
- Optional generated sheets under `assets/raw/gen_npc_*.png`

## Deliverables

| Agent | Owns |
|---|---|
| **Slice** | `tools/slice_npc_walk.py` → `assets/sprites/npc/{id}/walk_{down,left,right,up}_{0-3}.png` + `meta.json` |
| **Systems** | `scripts/actors/patrol_actor.gd` — move + directional `AnimatedSprite2D`; `AreaCraft.spawn_patrol_actor(...)` |
| **Wire** | `market_street_dressing.gd` (+ farm/residential/square actors) use **different** character ids |
| **Draw** | 1–2 extra character sheets if needed (farmer / merchant), then slice |

## Anim rules
- Walk: cycle frames while moving; idle: frame 0 of facing dir when paused
- Facing from movement delta (prefer horizontal if |dx|≥|dy|)
- Scale height ≈ 56px (`SCALE.md`)

## 禁止偷懒
- 禁止再用 idle_frame_* 冒充不同角色  
- 禁止只 tween 位移不切帧  
- 禁止三套 B14 只用一套  
- 禁止跳过 NEAREST / 透明抠黑底  
