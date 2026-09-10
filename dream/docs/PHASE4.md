# Dream Phase 4 — Forest edge + Station spine

**Status:** IN PROGRESS  
**Depends on:** Phase 3 (A03/A10 + Hub), `AREA_FRAMEWORK.md`, `BUILDING_PLACEMENT.md`, `NPC_ANIM.md`, skill `realistic-scene-craft`  
**Next:** [`PHASE4B.md`](PHASE4B.md) outdoor shell (A05–A07, A12–A15) → then [`PHASE5.md`](PHASE5.md) / [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)

Village ring (plaza / residential / farm / farmland / market) is in place. Phase 4 opens the **nature edge** and **transit spine**.

## Scope (locked)

| ID | Scene | Goal |
|---|---|---|
| A04 | 森林入口 | Dense forest belt + **dirt trail spine** (not stone plaza), clearing with 0–1 cabin fully inside play zone, rocks/flora, few NPCs via `PatrolActor`, portals ↔ 住宅区 / 广场 |
| A11 | 车站 | **North transit spine**: stone platform strip + tracks band (ColorRect/path proxy), station building south-facing **full AABB**, benches same-zone style, `station_master` patrol, portals ↔ 广场 / 市集 / 总览 |
| Hub | A01 / A16 | Separate TopBar buttons + map hotspots for A04 / A11 |
| Core | Shared | `SceneRouter` paths; reuse `AreaCraft` + `PatrolActor`; no new mask API |

**Out of scope:** A05 deep forest, A06–A07 waterfalls, A12–A15 lake/lighthouse, combat, train gameplay.

## District silhouette (must differ)

| Scene | 1/8 thumbnail must read as |
|---|---|
| A04 | Dark tree mass + narrow dirt trail + small clearing |
| A11 | Long platform / track band + one big station roof |

**禁止**再做成「中央大石板 + 北排房子 + 西河」的广场克隆。

## Architecture (locked paths)

```
SceneRouter:
  FOREST_ENTRANCE_PATH := res://scenes/areas/forest_entrance/forest_entrance.tscn
  STATION_PATH         := res://scenes/areas/station/station.tscn

scripts/areas/forest_entrance_assembler.gd / forest_entrance_controller.gd
scenes/areas/forest_entrance/forest_entrance.tscn

scripts/areas/station_assembler.gd / station_controller.gd
scenes/areas/station/station.tscn
```

Scene skeleton (match farmland): Assembler, Ground, Path, Water, YSortRoot, DebugGrid, CameraController, InfoPanel, UI/TopBar.

Map: **40×30**, `BASE_TILE=32`.

### A04 craft targets
1. Forest OUTSIDE clearing; trails = dirt; optional tiny stream (meander, not Rect2i).  
2. Trees dense on edges; `find_clear_near` / footprint — never in water.  
3. Optional cabin via `find_building_inside` + `map_play_rect`.  
4. NPCs: `farmer` / `elder_woman` via `craft.spawn_patrol_actor`.  
5. Portals: `→住宅区`, `→广场`, `→总览`.

### A11 craft targets
1. E–W or N–S **platform** path strip (stone); parallel “track” dark strip (ColorRect row or dirt).  
2. Station building (reuse `building_00`/`building_03`) full AABB in play zone.  
3. Benches: one style on platform only (`bench_1`).  
4. NPC: `station_master` + 1–2 travelers (`merchant` / `farmer`).  
5. Portals: `→广场`, `→商业街`, `→总览`.

## Multi-agent split

| Agent | Owns | Deliver |
|---|---|---|
| **Systems** | `scene_router.gd` only (+ optional tiny AreaCraft helper) | Paths + `go_forest_entrance` / `go_station` |
| **Level-A04** | `forest_entrance_*` + may patch residential/square portals →森林 | Playable A04 |
| **Level-A11** | `station_*` + may patch square/market portals →车站 | Playable A11 |
| **Hub** | `hub_controller.gd`, `world_hub.tscn`, `connection_overview.tscn` | Enter A04/A11 |
| **QA** | review only | PHASE4 + BUILDING_PLACEMENT + NPC_ANIM |

**Wave:** Systems → A04 ∥ A11 ∥ Hub → QA.

## 禁止偷懒

- 禁止整张参考图当场景背景  
- 禁止复制广场/市集 assembler 只改类名  
- 禁止森林入口中央大石板广场  
- 禁止车站无站台脊、只放一座孤立房子  
- 禁止建筑脚底检测代替整栋 AABB  
- 禁止 NPC 再用静态图 + `animate_patrol` 滑动（必须 `spawn_patrol_actor`）  
- 禁止 Hub「更多」弹层塞入口；各自顶栏按钮  
- 禁止孤岛（无 portal / 无返回 Hub）  
- UI：导航在 TopBar，信息用 InfoPanel  

## Acceptance

1. Hub → A04 and A11 run without script errors  
2. Residential/Square ↔ Forest; Square/Market ↔ Station via portals + TopBar  
3. Silhouette test + BUILDING_PLACEMENT + PatrolActor  
4. User local Godot test (Chinese paths)  
5. Commit; push if remote exists  

## References

- `assets/raw/A04_*` / `assets/raw/references/` if present  
- `assets/raw/A11_station.png`  
- Prior: `farmland_*`, `market_street_*`, `PatrolActor`
