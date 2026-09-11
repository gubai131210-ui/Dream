# School C07 — 学校内部（教室可读）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C07, [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa` (mandatory desk QA), reuse props (no new sheet this pass)  
**Peer silhouette:** classic village classroom — north blackboard wall + facing desk grid + side book nook (Stardew/RM school interiors; ≠ town-hall meeting table, ≠ clinic counter/bed)

## Goal

One enterable **教室** readable in ≤3s:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `blackboard` | 授课 / 板书 | north center `~(14,3)` — board + west lectern |
| `desks` | 听课 / 写字 | west+east columns `~(6,7)` / `~(20,7)` — 3 rows facing board |
| `books` | 取书 / 短阅 | east wall `~(23,5)` |

Center **door aisle** `tx 12–15` stays clear south→north. South door + TopBar return to village square.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c07_school"` |
| Scene (seeded shell) | `scenes/interiors/c07_school/c07_school.tscn` |
| Outdoor portal host | Square `building_02` ·「进入学校」→ C07 (**Lead-seeded; do not edit assembler**) |
| Router const (Lead) | `SceneRouter.C07_SCHOOL_PATH` |
| This doc | `docs/SCHOOL_C07.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A09 广场 学校门 | `进入学校` → `C07_SCHOOL_PATH` | C07 interior |
| C07 south door / TopBar 返回室外 | `return_path` = `SQ` | village square |
| C07 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **广场** → walk to 学校 building (~320,280).  
3. Click glowing portal **进入学校**.  
4. Read room in 3s: north 黑板 → middle 课桌阵列 → east 教材角; click desks/board for InfoPanel.  
5. Exit: south **← 返回** portal or TopBar **返回室外** → square.  

Scene path: `res://scenes/interiors/c07_school/c07_school.tscn`.

## Layout notes

- **Silhouette ≠ C06/C08:** classroom desk **grid** facing a north board (not hall+office, not front+exam).  
- Lectern offset **west** of aisle so `door_tx0`–`door_tx1` (12–15) is a free 2+ tile corridor to the board.  
- Each desk: table north, stool south (students face board); aisle-side tiles free for Interact-ready approach.  
- Teacher `elder_woman` patrols `blackboard` → `desks` (mid-aisle stand) → `books` via `via_stands`.  
- Props reused: `notice` / `table_dining` / `stool` / `stool_tea` / `shelf` / `ledger` / `basket` / `lamp_indoor`.

## 禁止偷懒

1. 禁止只改标题不改 `clusters` / 无课桌阵列却声称教室  
2. 禁止堵死南门廊道或中轴通廊  
3. 禁止改其他 `c0X_*` profile / assembler / scene_router  
4. 禁止做成村公所议事桌或医馆诊床轮廓  
5. 禁止棋盘格地板 / 整屋橙色洗色  
6. 禁止未写本 MD / 未跑 desk Visual QA 就声称 DONE  
7. 禁止用户中文路径强跑易损 Godot CLI  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (classroom grid readable ≤3s)
      Peer PASS (north board + facing desk rows + book nook)
      Scene-fit PASS (lamp_indoor classroom; shelf/ledger/basket as books)
      Territory SOFT (no enclosure needed; desk mass = classroom body)
      Composition PASS (3 verbs: teach / sit / browse)
      Ensemble PASS (primary board north, desk grid mid, books secondary, ≥30% open aisle)
      Interact-ready PASS (stool-south + aisle approaches; via_stands off prop centers)
Art: Style/Craft reuse PASS | Bleed PASS | Set-complete PASS (table+stool pairs)
Assembly: Corridor PASS (door 12–15 → board) | Y-sort shared craft | Profile-wire PASS
Meta: Name≠pixels SOFT (notice titled 黑板 — accepted reuse per Wave B) | Size PASS
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c07_school` enriched: blackboard + desk grid + books + teacher actor  
- [x] `return_path` = square; south door aisle clear  
- [x] Square portal「进入学校」seeded (Lead) — enter Hub→广场→进入学校  
- [x] This package MD  
- [x] Interior Visual QA desk PASS  
- [ ] User Godot QA (local)
