# Docks C34 — 渔码头 / 商码头（网垛≠货垛）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C34, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft` (dock pile mass), `painting-asset-craft` (dock piles), `interior-visual-qa` (desk PASS), `realistic-scene-craft` (dock feel only — outdoor hosts Lead-owned)  
**Peer silhouette:** lakeside working pier vs lighthouse trade quay — fish = netted crate mass + unload cart; trade = tall rope-tied cargo tower + verify desk (Stardew/RM pier grammar; **not** market backstage C32, **not** farm warehouse C37)

## Goal

Two enterable dock interiors with **distinct silhouettes**:

### C34 fish (`c34_dock_fish`)

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West nets | `nets` | 理网 / 收鱼 | `(5, 4)` — `dock_pile_fish` + basket/rod/crate + `lamp_farm` |
| East unload | `unload` | 卸鱼 | `(16, 5)` — handcart + fish crates/ice sacks + `lamp_farm` |

`extra_portals`: SW `(3, 9)` 「登船」→ C35 docked. South door `tx 9–12` clear. `return_path` = lake.

### C34 trade (`c34_dock_trade`)

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West cargo | `cargo` | 堆货 | `(5, 4)` — `dock_pile_trade` tall tower + sacks/barrel + `lamp_shop` |
| East office | `office` | 验货 / 登记 | `(16, 5)` — counter + ledger + stool + notice + `lamp_shop` |

No nets/rods. South door `tx 9–12` clear. `return_path` = lighthouse.

**Distinct from:**

| Peer | Diff |
| --- | --- |
| Fish vs trade | Fish = net mesh + buoy + rods; trade = rope-cinched crate tower + verify desk |
| C32 market back | C34 fish = lakeside catch unload; no grocery shelf / rest stool |
| C37 warehouse | C34 trade = pier cargo + shop lamp; no farm grain_stack / handcart bay |

## Ownership

| Piece | Path |
| --- | --- |
| Profiles only | `scripts/interiors/interior_profiles.gd` → `"c34_dock_fish"` / `"c34_dock_trade"` (+ `P_DOCK_PILE_*`) |
| Unique props | `dock_pile_fish_00.png`, `dock_pile_trade_00.png` |
| Prop regen | `tools/gen_transit_dive_wave_f_props.py` |
| Scene shells (Lead) | `scenes/interiors/c34_dock_fish/`, `c34_dock_trade/` |
| Outdoor hosts (Lead) | lake ~(280,620) 「进入渔码头」; lighthouse ~(360,700) 「进入商码头」 |
| This doc | `docs/DOCKS_C34.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Lake 东岸 | 「进入渔码头」 | C34 fish |
| C34 fish SW | 「登船」 | C35 boat docked |
| C34 fish south / TopBar | `return_path` | lake |
| Lighthouse 岸 | 「进入商码头」 | C34 trade |
| C34 trade south / TopBar | `return_path` | lighthouse |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **湖泊** → ~(280,620) **进入渔码头** — confirm netted pile ≠ crate tower; SW **登船**; mid aisle open.  
3. Hub → **灯塔** → ~(360,700) **进入商码头** — confirm tall rope cargo + verify desk; shop lamps only.  
4. Exit: south **← 返回** or TopBar **返回室外**.

## 禁止偷懒

1. 禁止门只有 InfoPanel、无 `scene_path`（Lead 已挂）  
2. 禁止室内无 `return_path` / 堵死南门 `9–12`  
3. 禁止渔/商剪影雷同（网垛≠绳捆货垛）  
4. 禁止去掉渔码头 「登船」→ C35  
5. 禁止家用台灯进渔商码头（必须 `lamp_farm` / `lamp_shop`）  
6. 禁止改 lake/lighthouse assembler / scene_router / 其他车道 profile  
7. 禁止棋盘格地板 / 整屋橙色洗色  
8. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
9. 禁止用 C32 休息凳或 C37 粮垛冒充码头剪影  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (fish pier vs trade quay in ≤3s) | Peer PASS (working pier / trade quay)
      Scene-fit PASS (lamp_farm fish; lamp_shop trade; no lamp_indoor) | Territory PASS (net pile vs tall cargo tower)
      Composition PASS (2 verbs each; satellites |d|≤3) | Ensemble PASS (west mass primary, east work, open mid aisle)
      Interact-ready PASS (via_stands south of anchors; door 9–12 free; 登船 clear of stacks)
Art: Style PASS (3/4 wood dock) | Craft PASS (dock_pile_fish ≥250 / trade ≥200 unique colors) | Bleed PASS
      Name≠pixels PASS (netted fish pile ≠ rope cargo tower)
Assembly: Corridor PASS | Y-sort via craft | Profile-wire PASS (P_DOCK_PILE_* + extra_portals)
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c34_dock_fish` + `c34_dock_trade` enriched; no 「占位」  
- [x] Distinct dock piles wired; fish ≠ trade silhouette  
- [x] `lamp_farm` / `lamp_shop` only; door aisles clear  
- [x] Fish dock keeps 「登船」→ C35 docked  
- [x] Actors route nets↔unload / cargo↔office  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: lake 渔码头 + 登船; lighthouse 商码头 → return  
