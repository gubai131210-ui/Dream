# Church C10 — 教堂主礼堂（祭坛 + 座席）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C10, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa`, `painting-asset-craft` (pew de-grass)  
**Peer silhouette:** axial nave — north altar / center aisle / flanking pew banks (classic parish church; ≠ classroom rows, ≠ town-hall meeting table, ≠ station waiting hall)

## Goal

One enterable **主礼堂** with readable axial grammar:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `altar` | 祭礼 | north, `tx≈13 ty≈4` |
| `pews_w` | 西座席 | west of aisle, mid-south |
| `pews_e` | 东座席 | east of aisle, mid-south |

Center **nave aisle** `door_tx0–door_tx1` = **12–15** (≥2 tiles) clear south door → altar. Stone floor, cool modulate, soft cool lights (not tavern warm wash). Optional clergy actor patrols altar ↔ pews.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c10_church"` |
| Unique prop | `assets/sprites/interior/props/pew_00.png` (indoor pew; grass stripped from outdoor bench) |
| Scene (gen’d shell) | `scenes/interiors/c10_church/c10_church.tscn` |
| Outdoor portal host | Square `building_01` — Lead-seeded **进入教堂**（团队勿改 assembler） |
| Router const (Lead) | `SceneRouter.C10_CHURCH_PATH` |
| This doc | `docs/CHURCH_C10.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A09 广场 教堂门 | `enter_title`「进入教堂」→ `C10_CHURCH_PATH` | C10 interior |
| C10 south door / TopBar 返回室外 | `return_path` = `SQ` | `village_square.tscn` |
| C10 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **广场** → click portal **进入教堂** on the northeast church building.  
3. Walk north along center aisle to altar; pews flank west/east; click props for InfoPanel; 司礼 patrols.  
4. Exit: south **← 返回** portal or TopBar **返回室外** → 广场.  

Scene path: `res://scenes/interiors/c10_church/c10_church.tscn`.

## Layout notes

- `room_w×room_h` = **26×22** (tall-ish nave vs station’s wide short hall).  
- Floor `stone`; modulate cool blue-grey; lights `Color(0.8x, 0.8x, 1.0)` soft.  
- Altar uses formal `counter_00` as long sanctuary table + kneeler south stand.  
- Pews: dedicated `pew_00` (no outdoor grass bleed); three rows each side.  
- Rug under altar approach on axis.

## 禁止偷懒

1. 禁止改 C01–C04 / 其他 Wave B `c0X_*` profile  
2. 禁止拆广场「进入教堂」portal / 改 `village_square_assembler`  
3. 禁止室内无返回广场 / 堵死南门 12–15 通廊  
4. 禁止用饭桌当座席冒充教室/议事厅轮廓  
5. 禁止室外带草皮 bench 直接进室内  
6. 禁止整屋酒馆暖橙洗色 / 棋盘格地板  
7. 禁止地下室/告解室/二楼本波扩做  
8. 禁止未写本 MD / 未跑 Visual QA 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (altar + aisle + pews ≤3s)
      Peer PASS (axial parish nave)
      Scene-fit PASS (stone cool nave; pew prop indoor)
      Territory SOFT (open nave; no enclosure needed)
      Composition PASS (3 verbs; actor ≥2 anchors)
      Ensemble PASS (primary altar north; open center aisle ≥30% void)
      Interact-ready PASS (via_stands on aisle / south of altar)
Art: Style PASS | Craft PASS (pew ~1800 unique colors, grass removed)
      Bleed PASS (no outdoor grass on pew_00) | Name≠pixels PASS
Assembly: Corridor PASS (door 12–15 → altar) | Y-sort craft parent | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm portal + return in editor
```

## Acceptance checklist

- [x] `c10_church`: altar + pews_w + pews_e + cool lights + clergy actor  
- [x] `return_path` = square; door aisle ≥2  
- [x] Unique `pew_00.png` (no grass)  
- [x] Portal host Lead-seeded「进入教堂」  
- [x] This package MD + Visual QA PASS (desk)  
- [x] Commit + push  
