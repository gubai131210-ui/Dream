# Dream Phase 4B — Outdoor shell completion

**Status:** IN PROGRESS (scenes landed; pending user Godot visual QA)  
**Depends on:** Phase 4 (A04 forest entrance + A11 station playable), `AREA_FRAMEWORK.md`, `BUILDING_PLACEMENT.md`, `NPC_ANIM.md`, skill `realistic-scene-craft`  
**Next after DONE:** User confirms → [`PHASE5.md`](PHASE5.md) / [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md) Wave A  

Completes the **A-class outdoor map shell** so enterable C interiors are not opened against hollow outdoors.

## Scope (locked)

| ID | Scene folder | Silhouette (1/8 must read as) | Primary portals |
|---|---|---|---|
| A05 | `forest_deep` | Dense canopy / low light / winding dirt only | ↔ A04；→ A06 or A07 |
| A06 | `river` | Wide meander water spine + both banks | ↔ A05 / A07 / A13 |
| A07 | `waterfall` | Vertical fall mass + mist pool (not flat pond) | ↔ A06 / A05 |
| A12 | `hill_farm` | Terraced plots / slope dirt / few sheds | ↔ A02 or A03；→ A13 |
| A13 | `lake` | Large open water + shore ring path | ↔ A06 / A12 / A14 / A15 |
| A14 | `lighthouse` | Coast rock + tall tower silhouette | ↔ A13 |
| A15 | `lake_house` | Single lakeside dwelling + dock spur | ↔ A13 |

**Map:** 40×30, `BASE_TILE=32`. Skeleton = Assembler / Ground / Path / Water / YSortRoot / DebugGrid / CameraController / InfoPanel / UI TopBar (match `forest_entrance.tscn`).

**Out of scope:** interiors (C), train gameplay, combat, full seasonal art, Phase 5.

## Architecture (locked paths)

```
SceneRouter:
  FOREST_DEEP_PATH  := res://scenes/areas/forest_deep/forest_deep.tscn
  RIVER_PATH        := res://scenes/areas/river/river.tscn
  WATERFALL_PATH    := res://scenes/areas/waterfall/waterfall.tscn
  HILL_FARM_PATH    := res://scenes/areas/hill_farm/hill_farm.tscn
  LAKE_PATH         := res://scenes/areas/lake/lake.tscn
  LIGHTHOUSE_PATH   := res://scenes/areas/lighthouse/lighthouse.tscn
  LAKE_HOUSE_PATH   := res://scenes/areas/lake_house/lake_house.tscn
```

Each scene: `scripts/areas/{name}_assembler.gd` + `{name}_controller.gd` + `scenes/areas/{name}/{name}.tscn`.

## Multi-agent split (file ownership exclusive)

| Agent | Owns | Deliver |
|---|---|---|
| **Systems** | `scene_router.gd`, `hub_controller.gd`, `world_hub.tscn`, `connection_overview.tscn` | Paths + `go_*` + TopBar/hotspots with `_change_if_exists` (no missing-scene crash) |
| **Level-A05** | `forest_deep_*` + may add portal on `forest_entrance_*` →深林 | Playable A05 |
| **Level-Water** | `river_*`, `waterfall_*` | Playable A06+A07 + mutual portals |
| **Level-HillLake** | `hill_farm_*`, `lake_*` | Playable A12+A13 + mutual portals |
| **Level-Landmark** | `lighthouse_*`, `lake_house_*` | Playable A14+A15；portals ↔ lake path constants |
| **QA** | review only | PHASE4B + BUILDING_PLACEMENT + NPC_ANIM + silhouette |

**Wave:** Systems first → A05 ∥ Water ∥ HillLake ∥ Landmark → QA → commit/push.

## Hub / UI rules

- 禁止「更多」弹层塞全部新入口。  
- `world_hub`：可增加 **第二行 TopBar（NatureRow）** 或 connection 热点；每个入口独立 Button / Area2D。  
- 缺场景时 `_change_if_exists` 只提示，不崩。

## Craft rules (all Level agents)

1. Reuse `AreaCraft` + `PatrolActor` (`craft.spawn_patrol_actor`) — no static slide patrol.  
2. Buildings: `find_building_inside` + full sprite AABB ⊆ `map_play_rect`.  
3. Water: meander mask — never straight `Rect2i` canal; never paste A-class PNG as background.  
4. Pass order: masks → grass → dirt → water → path → buildings → props → trees → actors → FX → portals.  
5. TopBar: 总览 + 连接总览 + ≥1 neighbor + 返回邻区；`make_portal` edge links.  
6. Reference only: `assets/raw/A0x_*.png` — craft, do not fullscreen sprite the map.

## 禁止偷懒

- 禁止未写 Systems 路径就散开空 `.tscn` 无法从 Hub 发现  
- 禁止复制广场/市集/车站 assembler 只改类名与坐标  
- 禁止六张图做成同一「中心石板 + 北房 + 西河」  
- 禁止瀑布做成无落差的平湖贴图  
- 禁止深林做成森林入口的复制粘贴（必须更密、更暗、无大 clearing 广场感）  
- 禁止建筑脚底检测代替整栋 AABB  
- 禁止 NPC 静态图 + tween 滑动  
- 禁止孤岛（无 portal / 无返回 Hub）  
- 禁止整张参考图当场景背景  
- 禁止一次顺手开 Phase 5 室内空壳  
- 禁止 UI 一个弹层堆全部 Nature 入口  
- 禁止 Level agent 互改对方目录或改 `scene_router`（仅 Systems）

## Acceptance

1. Hub / 连接总览 → 七场景均可进（文件存在后），缺文件不崩  
2. A04↔A05；A05↔A06/A07；A06↔A13；A12↔A13；A13↔A14/A15 至少一侧 portal 可点  
3. 七场景 1/8 缩略可互相区分  
4. BUILDING_PLACEMENT + PatrolActor  
5. 用户本地 Godot 测（中文路径）  
6. Commit + push `origin`  

## References

- Templates: `forest_entrance_*`, `station_*`, `farmland_*`  
- Docs: `BUILDING_PLACEMENT.md`, `NPC_ANIM.md`, `AREA_FRAMEWORK.md`  
- Raw: `A05`–`A07`, `A12`–`A15` under `assets/raw/`
