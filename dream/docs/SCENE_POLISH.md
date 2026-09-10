# Scene polish wave — existing outdoor assemblers

**Status:** IN PROGRESS  
**Date:** 2026-09-10  
**Skills:** `realistic-scene-craft`, `painting-asset-craft`  
**Locks:** `AREA_FRAMEWORK.md`, `BUILDING_PLACEMENT.md`, `LAYOUT.md`, `SEAMLESS.md`, `NPC_ANIM.md`, `PHASE4B.md`

## Goal

Optimize **already shipped** outdoor scenes against the latest craft locks. No new interiors (Phase 5). No Hub/router rewrites unless a path is broken.

## Shared checklist (every agent)

```
- [ ] craft.setup(W, H, district_id) — correct district for eco weights
- [ ] Silhouette ≠ plaza clone (district table)
- [ ] Water = meander role for THIS district (not Rect2i canal)
- [ ] Buildings: find_building_inside + full AABB ⊆ zone
- [ ] Trees: craft.spawn_tree (or find_sprite_inside) — no footprint-only
- [ ] NPCs: spawn_patrol_actor only
- [ ] No opaque ColorRect landmark hacks
- [ ] Props use real paths (barrel_0/crate_0/lamp_0/rock_0N/…) scale ≤0.6
- [ ] Portals + TopBar return Hub
```

## Multi-agent ownership (exclusive)

| Agent | Files only |
|---|---|
| **Village-Core** | `village_square_assembler.gd`, `village_residential_assembler.gd` |
| **Farm-Market** | `farm_residential_assembler.gd`, `farmland_assembler.gd`, `market_street_assembler.gd` (+ dressing if needed) |
| **Transit-Forest** | `forest_entrance_assembler.gd`, `forest_deep_assembler.gd`, `station_assembler.gd` |
| **Water-Landmark** | `river_assembler.gd`, `waterfall_assembler.gd`, `lake_assembler.gd`, `hill_farm_assembler.gd`, `lighthouse_assembler.gd`, `lake_house_assembler.gd` |

## 禁止偷懒

- 禁止只改注释/变量名交差  
- 禁止复制广场骨架到其他 district  
- 禁止树木 `find_clear_near` 脚底放置  
- 禁止建筑脚底检测代替整栋 AABB  
- 禁止 ColorRect 当瀑布/崖/码头  
- 禁止静态 NPC tween 滑动  
- 禁止整张 A 类参考图当背景  
- 禁止改对方 agent 文件 / 开 Phase 5 室内  
- 禁止 Hub「更多」弹层堆入口  

## Acceptance

1. Each owned assembler uses `setup(..., district_id)` + `spawn_tree` for trees  
2. Silhouette readable; waterfall remains cliff→fall→pool  
3. User local Godot visual QA  
4. Commit + push  

## District ids (suggested)

| Scene | district_id |
|---|---|
| village_square | `plaza` |
| village_residential | `residential` |
| farm_residential | `farm_home` |
| farmland | `farmland` |
| market_street | `market` |
| forest_* / wild nature / station | `wild` (or keep existing if already set) |
