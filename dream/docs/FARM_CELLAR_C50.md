# Farm Cellar C50 — 农场地窖（酒窖 / 腌菜 / 奶酪陈化）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_E.md`](./PHASE5_WAVE_E.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C50, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft` (keg mass + shelf volume), `painting-asset-craft` (aging/crock/wine signatures), `interior-visual-qa` (desk PASS)  
**Peer silhouette:** farm production cellar — west diamond wine rack + keg stack mass, east cheese aging boards + pickle crock cluster (real dairy/wine cave; ≠ home basement storage, ≠ C39 press/vat shed)

## Goal

One enterable farm cellar with **readable late-stage production**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West wine | `wine` | 陈酿 / 装瓶 | `(5, 5)` — wine_rack + keg mass + bottle crate + lamp_farm |
| East cure | `cure` | 腌渍 / 陈化 | `(16, 5)` — cheese_aging + pickle_crock + jar shelf + salt/bran + lamp_farm |

South door strip `tx 9–12` stays clear (≥2-tile aisle). `return_path` = farm residential (`FARM`). Hint has no 「占位」.

## Diff vs C15 家用地下室

| | C15 `c15_basement` | C50 `c50_farm_cellar` |
| --- | --- | --- |
| Intent | 家用储藏 + 返回楼梯 | **农场后期生产**：酒窖 / 腌菜 / 奶酪陈化 |
| Clusters | `stores` + `cellar` + `stair` | `wine` + `cure` only（无梯脚杂箱簇） |
| Signature | 普通 `P_SHELF` / `P_MUG_SHELF` / 通用桶 | **`wine_rack_00` / `pickle_crock_00` / `cheese_aging_00`** |
| Cheese | 无 | 多层奶酪轮陈化架（**禁止** `cheese_press` 冒充） |
| Lamp | `lamp_indoor` | **`lamp_farm` only** |
| Return | → C01 主角宅 | → `farm_residential` |
| Actor | none | 地窖农丁 wine ↔ cure |
| Modulate | 偏暖灰 `0.62,0.58,0.52` | 更冷湿 `0.52,0.54,0.50` |
| Territory | 散放储物 | 西桶垛体量 + 东架/缸生产体量 |

**Also distinct from:** C37 warehouse (箱袋垛/手推车), C39 processing (螺杆压机/铜酿釜 — 前期加工，非地窖陈化).

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c50_farm_cellar"` (+ `P_CHEESE_AGING` / `P_PICKLE_CROCK` / `P_WINE_RACK`) |
| Unique props | `assets/sprites/interior/props/cheese_aging_00.png`, `pickle_crock_00.png`, `wine_rack_00.png` |
| Prop regen | `tools/gen_farm_cellar_c50_props.py` |
| Diag strip | `assets/sprites/interior/props/_diag_farm_cellar_c50_props.png` |
| Scene shell (Lead) | `scenes/interiors/c50_farm_cellar/c50_farm_cellar.tscn` |
| Outdoor portal host (Lead) | farm residential ~`(560,400)` 「进入地窖」 |
| Router const (Lead) | `SceneRouter.C50_FARM_CELLAR_PATH` |
| This doc | `docs/FARM_CELLAR_C50.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Farm residential | 「进入地窖」 ~`(560,400)` | C50 interior |
| C50 south door / TopBar 返回室外 | `return_path` + craft portal | `scenes/areas/farm_residential/farm_residential.tscn` |
| C50 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测）。  
2. Hub → **农舍区** → 地标 ~`(560,400)`.  
3. Click portal **进入地窖**.  
4. Confirm west diamond wine rack + keg mass, east aging rack + pickle crocks, cool stone floor, mid door corridor open; farmer patrols wine ↔ cure.  
5. Exit: south **← 返回** or TopBar **返回室外** → farm residential.  

Scene path: `res://scenes/interiors/c50_farm_cellar/c50_farm_cellar.tscn`.

## 禁止偷懒

1. 禁止地窖门只有 InfoPanel、无 `scene_path`（Lead 已挂）  
2. 禁止室内无返回农舍区  
3. 禁止用 `cheese_press` / `mug_shelf` 冒充陈化架/酒架却声称 Name≠pixels PASS  
4. 禁止抄 C15 家用储藏剪影（stores+stair+lamp_indoor）  
5. 禁止家用台灯进农场地窖（必须 `lamp_farm`）  
6. 禁止堵死南门 `9–12` 通廊  
7. 禁止改其他 profile / assembler / scene_router  
8. 禁止棋盘格地板 / 整屋橙色洗色  
9. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
10. 禁止「放下就算」——须可读酒窖 vs 腌化两动词 + 桶垛体量  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (farm production cellar in ≤3s: wine rack + crocks + aging cheeses)
      Peer PASS (dairy/wine cave dual zones; cite vs C15 home basement)
      Scene-fit PASS (lamp_farm only; stone + cool damp modulate)
      Territory PASS (west keg mass + wine_rack volume; east shelf + crock/aging mass)
      Composition PASS (wine / cure verbs; satellites |d|≤3)
      Ensemble PASS (west primary rack+kegs, east aging+crocks, ≥30% open mid aisle)
      Interact-ready PASS (via_stands south of anchors; door 9–12 free; approach tiles at rack/crocks)
Art: Style PASS (3/4 warm wood / glaze / bottle glass) | Craft PASS (aging 206 / crock 206 / wine 223 unique colors)
      Set-complete N/A (no fence set) | Bleed PASS | FX N/A
      Name≠pixels PASS (cheese_aging=wheels on boards; pickle_crock=lidded crocks; wine_rack=diamond bottles)
Assembly: Corridor PASS (door→axis ≥2) | Y-sort via craft | Multi-view N/A | Splice N/A
Meta: Size PASS (~tile-scale props) | Profile-wire PASS (P_* paths + no P_CHEESE_PRESS / P_LAMP_INDOOR)
Escalation: none
Blockers: none (desk); user confirms in Godot
```

## Files touched

- `scripts/interiors/interior_profiles.gd` — consts + `"c50_farm_cellar"` enrich only  
- `tools/gen_farm_cellar_c50_props.py` — new  
- `assets/sprites/interior/props/cheese_aging_00.png`  
- `assets/sprites/interior/props/pickle_crock_00.png`  
- `assets/sprites/interior/props/wine_rack_00.png`  
- `assets/sprites/interior/props/_diag_farm_cellar_c50_props.png`  
- `docs/FARM_CELLAR_C50.md` — this file  
