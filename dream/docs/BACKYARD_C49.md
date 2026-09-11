# Backyard C49 — 后院（菜园 / 晾衣 / 柴垛 / 狗屋）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_E.md`](./PHASE5_WAVE_E.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C49, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft` (garden mass / wood height), `painting-asset-craft` (doghouse / clothesline / wood pile), `interior-visual-qa` (desk PASS), `realistic-scene-craft` (yard ≠ plaza)  
**Peer silhouette:** residential backyard yard shed — west vegetable beds, east firewood mass + kennel, SW laundry line; soft green straw wash (like C51 apiary, **not** C37 warehouse plank/orange). **No** full chicken pen (≠ C03 coop); dog ambient near doghouse.

## Goal

One enterable backyard with **readable garden / laundry / wood / doghouse**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West garden | `garden` | 种菜 / 浇水 | `(5, 5)` — ≥3 菜畦 + basket/barrel/sack + `lamp_farm` |
| East wood+kennel | `wood_dog` | 劈柴 / 喂狗 | `(16, 5)` — `wood_pile` mass + `doghouse` + crate/hay + farm lamp |
| SW laundry | `line` | 晾衣 | `(5, 10)` — `clothesline` + basket (west of door; mid aisle free) |

South door strip `tx 9–12` stays clear (≥2-tile aisle). `return_path` = village residential (`RES`). Hint has no 「占位」.

**Distinct from:**

| Peer | Diff |
| --- | --- |
| C03 chicken coop | C49 = no pen enclosure / nest stacks; doghouse + dog ambient only |
| C51 apiary | C49 = veg beds + laundry + firewood/kennel; **no** Langstroth hives |
| C37 warehouse | C49 = straw + soft green; yard props, not crate/cart mass |

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c49_backyard"` (+ `P_DOGHOUSE` / `P_CLOTHESLINE` / `P_WOOD_PILE`) |
| Unique props | `assets/sprites/interior/props/doghouse_00.png`, `clothesline_00.png`, `wood_pile_00.png` |
| Prop regen | `tools/gen_backyard_c49_props.py` |
| Scene shell (Lead) | `scenes/interiors/c49_backyard/c49_backyard.tscn` |
| Outdoor portal host (Lead) | village residential ~`(400,260)` 「进入后院」 |
| Router const (Lead) | `SceneRouter.C49_BACKYARD_PATH` |
| This doc | `docs/BACKYARD_C49.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Village residential | 「进入后院」 ~`(400,260)` | C49 interior |
| C49 south door / TopBar 返回室外 | `return_path` + craft portal | `scenes/areas/village_residential/village_residential.tscn` |
| C49 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **住宅区** → 地标 ~`(400,260)`.  
3. Click portal **进入后院**.  
4. Confirm west multi-bed garden, east wood pile + A-frame doghouse (bone cue), SW clothesline with laundry; mid door corridor open; dog near kennel; resident patrols garden ↔ wood_dog ↔ line.  
5. Exit: south **← 返回** or TopBar **返回室外** → residential.  

Scene path: `res://scenes/interiors/c49_backyard/c49_backyard.tscn`.

## Ambient note

`dog` ambient at `wood_dog` (+1,+2). No chicken pen — doghouse alone satisfies C49「鸡窝或狗屋」; keeps silhouette ≠ C03.

## 禁止偷懒

1. 禁止后院门只有 InfoPanel、无 `scene_path`（Lead 已挂）  
2. 禁止室内无返回住宅区  
3. 禁止用 `nest_00` 冒充狗屋 / `herbs_00` 冒充晾衣 / `hay_stack` 冒充柴垛却声称 Name≠pixels PASS  
4. 禁止家用台灯进后院（必须 `lamp_farm`）  
5. 禁止堵死南门 `9–12` 通廊  
6. 禁止改其他 profile / assembler / scene_router  
7. 禁止剪影雷同 C03 全鸡舍或 C51 蜂场  
8. 禁止棋盘格地板 / 整屋橙色洗色  
9. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
10. 禁止「放下就算」——须 Ensemble（西菜园主锚 + 东柴/狗 + 西南晾衣 + ≥30% 空地）与 Interact-ready  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (residential backyard in ≤3s: beds + laundry + wood/kennel)
      Peer PASS (yard shed vs plaza; cite C51 soft green straw outdoor-ish room)
      Scene-fit PASS (lamp_farm only; straw + soft green modulate)
      Territory PASS (garden multi-bed mass west; wood_pile height east; no fake nest-as-doghouse)
      Composition PASS (3 verbs; satellites |d|≤3) | Ensemble PASS (west primary garden, east wood/dog, SW line, open mid aisle ≥30%)
      Interact-ready PASS (via_stands south/approach; door 9–12 free; ≥1 approach at beds/pile/line)
Art: Style PASS (3/4 warm wood yard) | Craft PASS (doghouse 203 / clothesline 277 / wood_pile 258 unique colors)
      Bleed PASS (no indoor furniture grass bleed) | Name≠pixels PASS (A-frame+bone kennel; poles+laundry; log-end pile)
Assembly: Corridor PASS (door→axis ≥2; line at (5,10) west of 9–12) | Y-sort via craft | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c49_backyard` profile: garden + wood_dog + line, farm lamps, clear aisle, no 占位 hint  
- [x] Unique `doghouse_00` + `clothesline_00` + `wood_pile_00` wired (`P_*`)  
- [x] Garden mass readable; wood height + kennel; laundry ≠ herbs  
- [x] Distinct from C03 (no pen) and C51 (no hives)  
- [x] Dog ambient + resident actor route garden ↔ wood_dog ↔ line  
- [x] `return_path` = RES (village residential)  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: Hub → 住宅区 → 进入后院 → return  
