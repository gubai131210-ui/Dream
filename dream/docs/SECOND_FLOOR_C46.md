# Second Floor C46 — 建筑二楼（卧室睡区 / 阳台眺望）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_E.md`](./PHASE5_WAVE_E.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C46, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft` (bedroom/balcony clusters), `painting-asset-craft` (balcony_rail), `interior-visual-qa` (desk PASS)  
**Peer silhouette:** residential upper floor — west sleep (C01/C02 bed+dresser+lamp) + east balcony railing look-out; **not** dusty attic crates, open roof deck, backyard yard, or farm cellar

## Goal

One enterable second-floor room with **readable bedroom + balcony**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West sleep | `bedroom` | 睡 / 更衣 | `(5, 5)` — single bed + dresser + indoor lamp + laundry basket + bedside stool |
| East look-out | `balcony` | 眺望 | `(16, 5)` — balcony rail + stool + flower box + herbs |

South door strip `tx 9–12` stays clear (≥2-tile aisle). Stairs 「↑阁楼」`(3,11)` / 「↑屋顶」`(18,11)` kept. `return_path` = C01 home. Hint has no 「占位」.

**Distinct from:**

| Peer | Diff |
| --- | --- |
| C47 attic | C46 = lived-in bedroom + railing balcony; no crate mass / cobweb secret |
| C48 roof | C46 = indoor plank floor + sleep cluster; not open chimney/laundry deck |
| C01 ground | C46 = upper floor only (no kitchen/hearth); stairs return to C01 |

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c46_second_floor"` (+ `P_BALCONY_RAIL` const) |
| Unique prop | `assets/sprites/interior/props/balcony_rail_00.png` |
| Prop regen | `tools/gen_second_floor_c46_props.py` |
| Scene shell (Lead) | `scenes/interiors/c46_second_floor/c46_second_floor.tscn` |
| Portal host (Lead) | C01 `extra_portals` 「↑二楼」 |
| Router const (Lead) | `SceneRouter.C46_SECOND_FLOOR_PATH` |
| This doc | `docs/SECOND_FLOOR_C46.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| C01 主角宅 东楼梯 | 「↑二楼」 | C46 interior |
| C46 south door / TopBar 返回 | `return_path` | C01 home |
| C46 SW stair | 「↑阁楼」 | C47 attic |
| C46 SE stair | 「↑屋顶」 | C48 roof |
| C46 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **住宅区** → 进入 **主角宅** (C01)。  
3. Click portal **↑二楼**（东侧楼梯 ~tx 30）。  
4. Confirm west bed/dresser/lamp, east wooden balcony railing + look-out stool + flower box; mid door corridor `9–12` open; attic/roof stairs pickable; resident patrols bedroom ↔ balcony.  
5. Exit: south **← 返回** or TopBar → C01；或试 **↑阁楼** / **↑屋顶**。  

Scene path: `res://scenes/interiors/c46_second_floor/c46_second_floor.tscn`.

## 禁止偷懒

1. 禁止二楼门只有 InfoPanel、无 `scene_path`（Lead 已挂 C01→C46）  
2. 禁止室内无返回 C01 / 堵死南门 `9–12` 通廊  
3. 禁止用鸡窝/畜栏/篱笆冒充阳台栏杆却声称 Name≠pixels PASS  
4. 禁止卧室与阳台贴死、无 ≥30% 中轴开放地板  
5. 禁止堵死 「↑阁楼」`(3,11)` / 「↑屋顶」`(18,11)`  
6. 禁止改其他 profile / assembler / scene_router / 整文件重写 `interior_profiles.gd`  
7. 禁止农仓灯进二楼卧室（必须 `lamp_indoor`）  
8. 禁止棋盘格地板 / 整屋橙色洗色  
9. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
10. 禁止剪影雷同阁楼箱垛、露天屋顶、后院或农场地窖  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (second-floor bedroom+balcony in ≤3s) | Peer PASS (C01/C02 sleep + east rail look-out)
      Scene-fit PASS (lamp_indoor residential) | Territory PASS (sleep mass west; rail edge east)
      Composition PASS (2 verbs; satellites |d|≤3) | Ensemble PASS (bed primary, balcony secondary, mid aisle ≥30% open)
      Interact-ready PASS (via_stands south of bed/stool; dresser approach; door 9–12 free; stairs free)
Art: Style PASS (3/4 warm wood TL) | Craft PASS (balcony_rail_00 ≈472 unique colors) | Bleed PASS
      Name≠pixels PASS (balcony_rail_00 = wooden three-post balcony railing with deck strip + hanging planter)
Assembly: Corridor PASS (door→axis ≥2) | Y-sort via craft | Profile-wire PASS (P_BALCONY_RAIL)
Escalation: none
Blockers: none desk-side; confirm portal pick + return + attic/roof stairs in editor
```

## Acceptance checklist

- [x] `c46_second_floor` profile: bedroom + balcony, indoor lamp, clear aisle, no 占位 hint  
- [x] Unique balcony rail prop wired (`P_BALCONY_RAIL`)  
- [x] West sleep readable vs east look-out; mid floor open  
- [x] Distinct from C47 attic / C48 roof / backyard / cellar  
- [x] Optional resident actor route bedroom ↔ balcony + cat ambient on balcony  
- [x] `return_path` = C01; Lead stairs 「↑阁楼」「↑屋顶」 kept  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: Hub → 主角宅 → ↑二楼 → return / attic / roof  
