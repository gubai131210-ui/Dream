# Mill C13 — 磨坊内部（磨盘 / 齿轮 / 面粉簇）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C13, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft` (flour mass), `painting-asset-craft` (millstone / gear), `interior-visual-qa` (desk PASS)  
**Peer silhouette:** village watermill / windmill grind floor — west runner stone + gear frame, east sack flour mass, clear south door aisle (Stardew mill exterior-led; interior grammar follows real mill: stone+drive → bagged product)

## Goal

One enterable mill room with **readable work + storage**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West work | `millstone` | 碾磨 / 检修 | `(5, 5)` — stone + gear frame + farm lamp |
| East mass | `flour` | 堆垛 / 出货 | `(15, 6)` — dual grain stacks + sacks + basket/crate |

South door strip `tx 8–11` stays clear (≥2-tile aisle). `return_path` = farmland (`FLD`). Hint has no 「占位」.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c13_mill"` (+ `P_MILLSTONE` / `P_MILL_GEAR` consts) |
| Unique props | `assets/sprites/interior/props/millstone_00.png`, `mill_gear_00.png` |
| Prop regen | `tools/gen_mill_c13_props.py` |
| Scene shell (Lead) | `scenes/interiors/c13_mill/c13_mill.tscn` |
| Outdoor portal host (Lead) | farmland ~`(720,400)` 「进入磨坊」 |
| Router const (Lead) | `SceneRouter.C13_MILL_PATH` |
| This doc | `docs/MILL_C13.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Farmland east 磨坊 | 「进入磨坊」 | C13 interior |
| C13 south door / TopBar 返回室外 | `return_path` + craft portal | `scenes/areas/farmland/farmland.tscn` |
| C13 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **农田** → 东侧磨坊地标 ~`(720,400)`。  
3. Click portal **进入磨坊**。  
4. Confirm west stone+gears, east flour stacks, open mid aisle; miller patrols work ↔ flour.  
5. Exit: south **← 返回** or TopBar **返回室外** → farmland.  

Scene path: `res://scenes/interiors/c13_mill/c13_mill.tscn`.

## 禁止偷懒

1. 禁止磨坊门只有 InfoPanel、无 `scene_path`（Lead 已挂）  
2. 禁止室内无返回农田  
3. 禁止用饭桌冒充磨盘 / 工具架冒充齿轮却声称 Name≠pixels PASS  
4. 禁止面粉垛贴死磨盘、两簇不可分读  
5. 禁止堵死南门 `8–11` 通廊  
6. 禁止改其他 profile / assembler / scene_router  
7. 禁止家用台灯进磨坊（必须 `lamp_farm`）  
8. 禁止棋盘格地板 / 整屋橙色洗色  
9. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (grind floor in ≤3s) | Peer PASS (village mill stone+drive+bags)
      Scene-fit PASS (farm lamp + mill props) | Territory PASS (flour mass east ≠ millstone work)
      Composition PASS (2 verbs; |d|≤3 satellites) | Ensemble PASS (west primary stone, east mass, open aisle)
      Interact-ready PASS (via_stands south of anchors; door 8–11 free)
Art: Style PASS (3/4 warm wood/stone) | Craft PASS (millstone/gear ≥200 unique colors) | Bleed PASS
      Name≠pixels PASS (millstone_00 / mill_gear_00 match titles)
Assembly: Corridor PASS (door→axis ≥2) | Y-sort via craft | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c13_mill` profile: millstone + flour clusters, farm lamp, clear aisle, no 占位 hint  
- [x] Unique millstone + gear props wired  
- [x] Flour mass (dual stacks + sacks) separate from gears/stone  
- [x] Optional miller actor route millstone ↔ flour  
- [x] `return_path` = FLD (farmland)  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: Hub → 农田 → 进入磨坊 → return  
