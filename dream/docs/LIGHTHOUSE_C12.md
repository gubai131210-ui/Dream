# Lighthouse C12 — 灯塔内部（三层可读）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_A2.md`](./PHASE5_WAVE_A2.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C12, [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md)  
**Skills:** `realistic-scene-craft` (outdoor portal), `interior-visual-qa`  
**Peer silhouette:** classic coastal lighthouse shaft — oil/gear floor → spiral mid landing → lantern room (Stardew lighthouse is exterior-led; interior grammar follows real tower: store/gear → climb rest → lamp)

## Goal

One enterable tall room with **3 vertical walkable clusters** (not three separate scenes):

| Layer | Cluster id | Verb | Tile anchor (approx) |
| --- | --- | --- | --- |
| Ground | `gear` | 检修 / 储油 | west of spine, south (near door) |
| Mid | `mid_landing` | 歇脚 / 潮汐牌 | east of spine, mid height |
| Crown | `lamp_room` | 守望航标灯 | north crown |

Center **spine aisle** `tx ≈ 7–8` reads as spiral climb. South door strip clear; TopBar + south portal return to outdoor A14.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c12_lighthouse"` |
| Scene (gen’d shell) | `scenes/interiors/c12_lighthouse/c12_lighthouse.tscn` |
| Outdoor portal host | `scripts/areas/lighthouse_assembler.gd` (door → C12; **do not** redo coast rocks) |
| Router const (Lead) | `SceneRouter.C12_LIGHTHOUSE_INT_PATH` |
| This doc | `docs/LIGHTHOUSE_C12.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A14 outdoor lighthouse south foot | `make_portal("进入灯塔", C12_LIGHTHOUSE_INT_PATH)` | C12 interior |
| C12 south door / TopBar 返回室外 | `return_path` + craft portal | `scenes/areas/lighthouse/lighthouse.tscn` |
| C12 TopBar 世界总览 | Hub | hub |
| A14 lake / hub | unchanged | lake / hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Run outdoor **灯塔** area: `res://scenes/areas/lighthouse/lighthouse.tscn`  
   - From Hub → 湖泊 → **→灯塔**，或 Hub 若已挂灯塔入口。  
3. Click glowing portal **进入灯塔** at the tower south foot (was InfoPanel-only).  
4. Walk north: gear → mid landing → lamp room; click props for InfoPanel.  
5. Exit: south **← 返回** portal or TopBar **返回室外** → outdoor lighthouse.  

Scene path constant: `res://scenes/interiors/c12_lighthouse/c12_lighthouse.tscn`.

## 禁止偷懒

1. 禁止灯塔门只剩 InfoPanel、无 `scene_path`  
2. 禁止室内无返回室外  
3. 禁止三层做成三个互不连通的房间却声称 DONE（本包允许一间高塔三簇）  
4. 禁止堵死中轴通廊或南门带  
5. 禁止重做海岸礁石 / 大改 A14 布局（只换门 portal）  
6. 禁止改其他 profile（只 enrich `c12_lighthouse`）  
7. 禁止棋盘格地板 / 整屋橙色洗色  
8. 禁止未写本 MD 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS | Peer PASS (tower shaft) | Scene-fit PASS (oil/gear + lamp)
      Territory SOFT (open shaft, no enclosure needed) | Composition PASS (3 verbs)
      Ensemble PASS (primary lamp north, open spine) | Interact-ready PASS (via_stands off props)
Art: reuse existing props; no new sheet this pass
Assembly: Corridor PASS (door→spine ≥2) | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c12_lighthouse` profile: 3 named clusters + actor route + layered lights  
- [x] Outdoor assembler: building hotspot → portal to C12  
- [x] Lake / hub portals kept  
- [x] Return path = outdoor lighthouse  
- [x] This package MD  
- [ ] User Godot enter / climb / return QA  
