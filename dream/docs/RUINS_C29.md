# Ruins C29 — 遗迹主殿（残祭台 + 侧廊藏宝）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C29, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa` (desk), reuse outdoor rocks (`painting-asset-craft` N/A — no new sheet)  
**Peer silhouette:** axial ruined nave — north broken altar / rubble mass / clear center aisle / east cache alcove (≠ C10 church pew banks, ≠ dining-table altar proxy)

## Goal

One enterable **主殿** with readable ruined axial grammar:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `nave` | 残祭 | north axis, `tx≈13 ty≈5` — rock rubble mass as collapsed altar |
| `cache` | 侧藏 | east alcove, `tx≈20 ty≈10` — coin chest + crates + mask rocks |

Center **nave aisle** `door_tx0–door_tx1` = **11–14** (≥2 tiles) clear south door → broken altar. Stone floor, cool blue-grey modulate, cool PointLights (not tavern warm wash). No pews / no intact sanctuary furniture.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c29_ruins"` |
| Scene (gen’d shell) | `scenes/interiors/c29_ruins/c29_ruins.tscn` |
| Outdoor portal host | `forest_deep` 遗迹 `tile~(28,12)` — Lead-seeded **进入遗迹**（团队勿改 assembler） |
| Router const (Lead) | `SceneRouter.C29_RUINS_PATH` |
| This doc | `docs/RUINS_C29.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A05 深林 遗迹门 | 「进入遗迹」→ `C29_RUINS_PATH` | C29 interior |
| C29 south door / TopBar 返回室外 | `return_path` = `FDEEP` | `forest_deep.tscn` |
| C29 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测）。  
2. Hub → **深林** → 遗迹残垣 `tile~(28,12)` → portal **进入遗迹**.  
3. Walk north along center aisle to **残祭台** rubble; east **遗物箱** cache; click props for InfoPanel; 遗迹学者 patrols.  
4. Exit: south **← 返回** portal or TopBar **返回室外** → 深林.  

Scene path: `res://scenes/interiors/c29_ruins/c29_ruins.tscn`.

## Layout notes

- `room_w×room_h` = **26×20** (axial hall; taller than stub 18 for nave read).  
- Floor `stone`; modulate cool blue-grey `Color(0.62, 0.66, 0.72)`; lights cool `Color(0.7x–0.8x, 0.8x, 1.0)`.  
- Nave: outdoor `rock_0*` as broken altar / masonry mass (≠ `table_dining` fake altar, ≠ `pew_00` banks) + `notice` + `lamp_indoor`; south `清理箱` stand.  
- Cache: `coin_chest` + crates/sack + mask rocks; approach from west (aisle side).  
- Flanking rubble stays **west of tx 11** / **east of tx 14** so door corridor stays clear.  
- No rug / no window (ruined stone hall).

## 禁止偷懒

1. 禁止改 C01–C04 / 其他 Wave C `cXX_*` profile  
2. 禁止拆深林「进入遗迹」portal / 改 `forest_deep_assembler`  
3. 禁止室内无返回深林 / 堵死南门 11–14 通廊  
4. 禁止用教堂 `pew_00` 排座或完整祭坛家具冒充废墟  
5. 禁止饭桌当祭台交差（须碎石/坍塌体量可读）  
6. 禁止整屋酒馆暖橙洗色 / 棋盘格地板  
7. 禁止地下室/机关本波扩做（最小交付：≥1 主殿）  
8. 禁止未写本 MD / 未跑 Visual QA 就声称 DONE  
9. 禁止整文件重写 `interior_profiles.gd`（只改 `c29_ruins` 键）  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (broken altar rubble + east cache + open aisle ≤3s)
      Peer PASS (axial ruined nave; cite C10 church as anti-peer — no pews)
      Scene-fit PASS (stone cool ruins; rock mass = collapsed sanctuary)
      Territory SOFT (open nave; rubble mass as territory; no enclosure needed)
      Composition PASS (2 verbs: 残祭 / 侧藏; |d|≤3 satellites)
      Ensemble PASS (primary rubble north; ≥30% open center aisle)
      Interact-ready PASS (south of altar crate; west approach to chest)
Art: Style PASS | Craft PASS (reuse rock/crate/chest; no new sheet)
      Bleed PASS (rocks outdoor OK for ruins; no grass furniture) | Name≠pixels PASS
Assembly: Corridor PASS (door 11–14 → nave) | Y-sort craft parent | Profile-wire PASS
      Multi-view N/A (no H/V rails) | Splice N/A
Escalation: none
Blockers: none (desk); user confirms Godot enter/exit + cool light feel
```

## Done checklist

- [x] Profile `c29_ruins` enriched (nave rubble altar + east cache)
- [x] Rocks `res://assets/sprites/props/rock_0*.png` as broken altar (not table/pews)
- [x] Actor 遗迹学者; `return_path` FDEEP; no 占位 in hint
- [x] Cool blue-grey modulate + cool lights; door 11–14 clear; room 26×20
- [x] `RUINS_C29.md` written
- [ ] User Godot enter/exit QA from deep-forest portal

## Acceptance

1. Deep forest 遗迹 portal enters C29; TopBar/south door returns to `forest_deep`  
2. Profile reads as ruined main hall (rubble altar ≠ pew church)  
3. This MD + commit/push  
4. User Godot QA  
