# Library C09 — 图书馆内部（大厅 + 可搜书架）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C09, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft` (shelf mass), `interior-visual-qa`  
**Peer silhouette:** small-town library long hall — **parallel stack wings** + center borrow island (≠ school desk grid, ≠ church nave, ≠ clinic front+exam)

## Goal

Enterable civic reading hall with **≥3 functional clusters**:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `stacks_w` | 检索 / 取书 | west wing, double-column shelf mass |
| `stacks_e` | 检索 / 还书篮 | east wing, mirror shelf mass + index |
| `desk` | 借阅登记 | center island; free approach tile **south** of counter |

Center **aisle** `tx ≈ 10–19` between wings stays clear to south door strip `door_tx0–door_tx1` (13–16). TopBar 返回室外 + Hub; `return_path` = village square.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c09_library"` |
| Scene (gen’d shell) | `scenes/interiors/c09_library/c09_library.tscn` |
| Outdoor portal host | `village_square_assembler.gd` `building_03`（Lead-seeded；本队不改） |
| Router const (Lead) | `SceneRouter.C09_LIBRARY_PATH` |
| This doc | `docs/LIBRARY_C09.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A09 广场 `building_03` 图书馆门 | `enter_title`「进入图书馆」→ `C09_LIBRARY_PATH` | C09 interior |
| C09 south door / TopBar 返回室外 | `return_path` + craft portal | `scenes/areas/village_square/village_square.tscn` |
| C09 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **广场** → 东侧 **图书馆** 门脸。  
3. Click glowing portal **进入图书馆**.  
4. Walk north up center aisle: west/east stacks readable as book mass; click shelves / 索引 for InfoPanel；借阅台南站位可交互。  
5. Exit: south **← 返回** portal or TopBar **返回室外** → 广场。  

Scene path: `res://scenes/interiors/c09_library/c09_library.tscn`.

## Layout notes

- **Mass:** repeated `shelf_00` columns (not single floating shelves).  
- **Interact-ready:** counter face south; stool on desk **east** only — `dy≥2` south of counter left empty for player.  
- **Actor:** 图书管理员 (`elder_woman`) patrols `desk` → `stacks_w` → `stacks_e` with aisle-facing stands.  
- **Props reused:** shelf / counter / ledger / notice / lamp_indoor / stool_tea / sack / crate / basket — no new sheet this pass.

## 禁止偷懒

1. 禁止门只有 InfoPanel、无 `scene_path`（Lead 已挂 portal；禁止拆掉）  
2. 禁止室内无返回广场 / 堵死南门廊道或中廊  
3. 禁止改其他 `c0X_*` profile / 广场 assembler / `scene_router`  
4. 禁止复制室外 assembler 或棋盘格地板 / 整屋橙色洗色  
5. 禁止做成教室课桌网格或教堂中殿座席轮廓  
6. 禁止只放两架空架、无书脊体量重复就声称 DONE  
7. 禁止未写本 MD / 未跑 desk Visual QA 就声称 DONE  
8. 禁止一次做满地下书库/二楼迷宫（本波只要大厅+可搜书架）  
9. 禁止用户中文路径强跑易损 Godot CLI  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (library hall in ≤3s) | Peer PASS (parallel stacks + center desk)
      Scene-fit PASS (civic reading / borrow) | Territory PASS (shelf mass = repeated columns)
      Composition PASS (3 verbs: stacks_w / stacks_e / desk) | Ensemble PASS (desk primary, wings secondary, ≥30% aisle)
      Interact-ready PASS (south approach tile; staff north of counter; via_stands off shelves)
Art: reuse existing props; no new sheet; Bleed PASS (no outdoor grass furniture)
Assembly: Corridor PASS (door 13–16 → center aisle ≥2) | Profile-wire PASS (c09_library + return SQ)
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c09_library` profile: 3 named clusters + librarian actor + layered lights  
- [x] Lead outdoor portal: 广场「进入图书馆」→ C09 (unchanged by this team)  
- [x] `return_path` = village square  
- [x] This package MD + desk Visual QA  
- [ ] User Godot: Hub → 广场 → 进入图书馆 → 巡架 / 借阅 → 返回广场  
