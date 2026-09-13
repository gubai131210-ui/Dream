# GOAL package — Player Spine A + Farm Crop B + Encounter Pocket D

**Status:** IN PROGRESS 2026-09-13  
**Goal:** Research-backed design + multi-agent delivery of A/B/D with **new art only**.  
**Locks:** [`research/PLAYER_SPINE_A_RESEARCH.md`](./research/PLAYER_SPINE_A_RESEARCH.md), [`research/FARM_CROP_B_RESEARCH.md`](./research/FARM_CROP_B_RESEARCH.md), [`research/ENEMY_LOOT_GAMEPLAY_RESEARCH.md`](./research/ENEMY_LOOT_GAMEPLAY_RESEARCH.md), [`INTERACTION_DESIGN.md`](./INTERACTION_DESIGN.md), [`ENV_H.md`](./ENV_H.md), [`RUINS_C29.md`](./RUINS_C29.md)  
**Skills:** `painting-asset-craft`, `interior-territory-craft`, `interior-visual-qa`, BreakablesKit pattern

---

## Multi-agent ownership (互斥)

| Team | Owns | Deliverable |
| --- | --- | --- |
| **Spine-A** | `SpawnRegistry`, `InventoryService`, `SceneRouter.change_to` spawn, `PlayerBootstrap`, portal `spawn_id` meta | Autoloads + QA |
| **Farm-B** | `FarmCropKit`, farmland controller attach, **new** turnip stage sprites + water/harvest FX | 3–5 plots, morning tick |
| **Encounter-D** | `EncounterPocketKit`, C29 attach, **new** moss critter + loot materials + clear FX | Zone-gated pocket |
| **ArtGen** | New PNG sheets only (no reuse of old crop furrow-as-plant / old enemy stubs) | Import + Nearest |
| **QA** | `tools/qa_spine_abd.py` + subagent review | GREEN before push |

---

## A — Spawn + Inventory (+ walk contract)

### Spawn
- `SpawnRegistry.set_pending(spawn_id)` before `change_scene`
- `SceneRouter.change_to(tree, path, spawn_id := "")`
- Portal meta optional: `spawn_id` = where to appear in **destination**
- `PlayerBootstrap` resolves: pending id → marker `Spawn_<id>` or catalog default → Portal_Return apron → camera → default
- Apron offset south of door to avoid re-trigger (Stardew pattern)

### Inventory
- Autoload `InventoryService`: `try_add(id, n)`, `try_remove`, `count`, `snapshot`
- Catalog: `crop_turnip`, `seed_turnip`, `loot_moss_resin`, `loot_ruin_shard` (+ capacity soft cap)

### Collision contract (doc + soft enforce)
- Keep tile-mask walkability (`AreaCraft.is_npc_walkable`) as Phase0 truth
- Hotspots/portals = Area2D only; never claim Area2D is solid wall
- Player feet origin unchanged (`FOOT_CONTACT_Y`)

---

## B — Turnip vertical slice

| Lock | Value |
| --- | --- |
| Crop | `turnip` |
| Stages | 4 PNGs `crop_turnip_stage_00..03` **NEW** |
| Plots | 4 dirt tiles on farmland |
| Tick | Night→Day morning via `DayNightWeather.state_changed` |
| Water | Hotspot verb; rain counts as watered |
| Harvest | Ripe → `InventoryService.try_add("crop_turnip", 1)` + FX |

---

## D — C29 encounter pocket

| Lock | Value |
| --- | --- |
| Place | `c29_ruins` east cache corridor |
| Critter | `moss_blob` **NEW** sprite + hit FX |
| Clear | 3 clicks / hits → drop |
| Loot | `loot_moss_resin` (+ optional `loot_ruin_shard`) **NEW** |
| Dual source | Breakable urn in same pocket low-chance same resin |
| Soft sink | InfoPanel craft hint / station soft gate text (no hard lock) |
| Safety | Assert zero spawn on square / station / farmland |

---

## 禁止偷懒

1. 禁止复用旧作物垄线当植株；禁止复用旧敌图  
2. 禁止广场/车站/农场刷可伤玩家怪  
3. 禁止收获只弹 Info 不进 Inventory  
4. 禁止 `change_to` 仍无 spawn_id 通道却声称出生点完成  
5. 禁止材料无 sink 文案  
6. 禁止未跑 `qa_spine_abd.py` / 子 agent 审查就声称 DONE  
7. 禁止中文路径下用易损 CLI 代替用户 Godot 手测  

## Acceptance

- [x] Autoloads registered; QA GREEN (`python tools/qa_spine_abd.py`)
- [x] Portal with spawn_id lands on marker/apron (forest→C29 `entrance`; C29 return `from_ruins`; south apron +48y)
- [x] Plant→water→morning×3→harvest adds turnip (code path + InventoryService)
- [x] C29 moss clear adds resin + dual urn; square/station/farmland have no EncounterPocketKit
- [ ] User Godot: farmland crop + ruins pocket（请本地手测）
