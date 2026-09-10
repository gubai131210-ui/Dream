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

## Collision / blocked (medium)

- `AreaCraft.blocked_mask` marks **building feet** + **tree trunks** (`mark_blocked_footprint` after buildings; `spawn_tree` auto-marks).
- `is_npc_walkable` = in-bounds ∧ ¬water ∧ ¬blocked (grass/dirt/path OK).
- `PatrolActor` (via `spawn_patrol_actor`) snaps blocked waypoints and **turns back** when the next step would enter a blocked/water tile — no full A* this wave.
- Assemblers must call `craft.mark_blocked_footprint(pos, half_w, half_h)` with the **same** half sizes used for `find_building_inside`.

## Ambient animals

- `AmbientCritter` + `assets/sprites/animals/` (B13 slice). Farm scenes place cat/dog/sheep/cow/deer ambient; **chicken/bird sheets not in B13** yet (`PROP_ORIENTATION.md`).

## 禁止偷懒
- 禁止再用 idle_frame_* 冒充不同角色  
- 禁止只 tween 位移不切帧  
- 禁止三套 B14 只用一套  
- 禁止跳过 NEAREST / 透明抠黑底  
- 禁止 NPC 直线穿建筑/树干 footprint（必须接 blocked_mask）  

