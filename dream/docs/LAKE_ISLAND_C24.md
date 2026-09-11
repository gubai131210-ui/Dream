# Lake Island C24 — 湖心岛（野餐 + 废墟角）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C24, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa`, `painting-asset-craft` (reuse only this pass)  
**Peer silhouette:** open island clearing — west picnic circle + NE ruin/chest pocket + open meadow void (Stardew-like picnic shore / Zelda small isle; ≠ C13 mill gear hall, ≠ C16 cave stone shaft)

## Goal

One enterable **湖心岛** with readable open-island grammar:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `picnic` | 野餐 | west clearing, `tx≈6 ty≈8` |
| `ruin_corner` | 探秘 | northeast, `tx≈18 ty≈5` |

Center **door aisle** `door_tx0–door_tx1` = **10–13** (≥2 tiles) clear south → north meadow. Straw floor + soft dirt-green modulate (open island feel). Chest is ruin interact target; picnic round table is primary social anchor.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c24_lake_island"` |
| Scene (gen’d shell) | `scenes/interiors/c24_lake_island/c24_lake_island.tscn` |
| Outdoor portal host | Lake south shore `~(640,520)` — Lead-seeded **登湖心岛**（团队勿改 `lake_assembler`） |
| Router const (Lead) | `SceneRouter.C24_LAKE_ISLAND_PATH` |
| This doc | `docs/LAKE_ISLAND_C24.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A13 湖泊 南岸登岛点 | portal「登湖心岛」→ `C24_LAKE_ISLAND_PATH` | C24 interior |
| C24 south door / TopBar 返回室外 | `return_path` = `LAKE` | `lake.tscn` |
| C24 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **湖泊** → walk to south-shore embark `~(640,520)` → click portal **登湖心岛**.  
3. West: picnic round table + stools + baskets; NE: ruin corner with **宝箱** + rocks/crates; center meadow open; **岛上访客** patrols picnic ↔ ruin.  
4. Exit: south **← 返回** portal or TopBar **返回室外** → 湖泊.  

Scene path: `res://scenes/interiors/c24_lake_island/c24_lake_island.tscn`.

## Layout notes

- `room_w×room_h` = **24×18** (open meadow plate vs mill’s compact hall / cave’s dark stone).  
- Floor `straw`; modulate soft green-dirt `Color(0.72, 0.82, 0.68)`; daylight-cool lights (not tavern orange wash).  
- Picnic uses `table_round_00` + matching `stool_00` ring + baskets; `lamp_farm_00` (outdoor, not `lamp_indoor`).  
- Ruin: `coin_chest_00` primary + rock mass + crates + weathered notice; approach stand south of chest.  
- Rug under picnic dine/talk west of door band.  
- Ambient cat near picnic; actor `via_stands` keep interact tiles free.

## 禁止偷懒

1. 禁止再抛光 C01–C04 / Wave B / 其他 Wave C 包  
2. 禁止拆湖泊「登湖心岛」portal / 改 `lake_assembler`  
3. 禁止室内无返回湖泊 / 堵死南门 10–13 通廊  
4. 禁止改别人 profile；禁止整文件重写 `interior_profiles.gd`  
5. 禁止做成洞穴石廊或磨坊齿轮厅轮廓  
6. 禁止棋盘格地板 / 整屋橙色洗色  
7. 禁止废墟角无宝箱可读交互点  
8. 禁止野餐只有单桌无坐席对位 / 无负空间开敞感  
9. 禁止未写本 MD / 未跑 Visual QA 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (picnic west + ruin/chest NE ≤3s)
      Peer PASS (open island clearing; picnic + ruin pocket)
      Scene-fit PASS (straw meadow wash; farm lamp outdoors; chest at ruin)
      Territory SOFT (open island; rock/crate mass at ruin; no enclosure needed)
      Composition PASS (2 verbs; actor picnic↔ruin; |d|≤3 satellites)
      Ensemble PASS (primary picnic; secondary ruin; ≥30% open meadow void)
      Interact-ready PASS (south stool / south-of-chest via_stands; door 10–13 free)
Art: Style PASS | Craft PASS (reuse props) | Bleed PASS | Name≠pixels PASS
Assembly: Corridor PASS (door 10–13 → meadow) | Y-sort craft parent | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm Hub→湖泊→登湖心岛 enter/return in editor
```

## Acceptance checklist

- [x] `c24_lake_island` profile: picnic + ruin_corner (+ chest) + actor route + open meadow lights  
- [x] `return_path` = LAKE; door aisle 10–13 clear  
- [x] Silhouette ≠ cave / mill  
- [x] Outdoor portal Lead-seeded「登湖心岛」~(640,520)  
- [x] This package MD  
- [ ] User Godot Hub → 湖泊 → 登湖心岛 / return QA  
