# Station C11 — 车站内部（候车厅 + 售票/站长）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C11, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa` (desk), `painting-asset-craft` (none this pass — reuse only)  
**Peer silhouette:** small-town railway waiting room — long horizontal bench bay + side ticket bay (≠ C10 church tall nave)

## Goal

Enterable **station house interior** from A11 outdoor station + return to station outdoor.

Acceptance (Wave B StationInt):

1. Hub → 车站 → outdoor portal **进入车站** → C11  
2. Interior: wide **候车厅** + **售票/站长** (+ freight mass)  
3. South door aisle clear; TopBar 返回室外 → `station.tscn`  
4. Package MD + commit/push  

## Layout (profile `c11_station`)

| Zone | Cluster | Anchor (tx,ty) | Role |
| --- | --- | --- | --- |
| West waiting | `waiting` | 6, 7 | Long bench rows (`waiting_bench_00`) + `timetable_00` + 站厅灯 |
| East ticket | `ticket` | 22, 6 | 售票窗 counter (客南主北) + 行车簿 + 票价牌 + 票箱 |
| East freight | `freight` | 25, 9 | Crate / sack / barrel mass (货运体量) |
| Corridor | door 13–16 | — | ≥2-tile aisle south→north; benches tx≤12, ticket/freight tx≥20 |

- **Room:** `30×16` plank — long horizontal ≠ C10 `24×20` stone nave  
- **Rug:** under waiting seats (`ox/oy` 7, 9)  
- **Actor:** `station_master` via waiting → ticket (staff side) → freight  
- **Lights:** waiting bay + ticket bay PointLights  
- **Art:** `waiting_bench_00` / `timetable_00` / `counter` / `ledger` / `crate_*` / `lamp_shop` / `coin_chest` / `sack` / `barrel`

## Portal host (Lead-seeded; do NOT edit assembler)

| Piece | Path |
| --- | --- |
| Outdoor | `scripts/areas/station_assembler.gd` → `_spawn_portals` |
| World pos | **~(640, 320)** station house south door |
| Hotspot | 「进入车站」 → `SceneRouter.C11_STATION_INT_PATH` |
| Interior return | `return_path` = `STN` (`scenes/areas/station/station.tscn`) + south portal |

## Ownership

| Piece | Path |
| --- | --- |
| Profile **only** | `scripts/interiors/interior_profiles.gd` → `"c11_station"` |
| Scene shell | `scenes/interiors/c11_station/c11_station.tscn` |
| This doc | `docs/STATION_C11.md` |
| Outdoor portal | Lead-owned — **no** `station_assembler` edits this team |

## How to enter (user QA)

1. 本机打开 Godot 工程 `dream/`（中文路径下请你本地测，勿强跑易损 CLI）。  
2. Hub → **车站** → 主楼南门附近点 **进入车站** (~640, 320)。  
3. 确认：西侧长候车座 + 北壁时刻表；东侧售票窗 + 货运箱垛；中轴通廊可走。  
4. 点道具 / 站长 → InfoPanel。  
5. 南门 **← 返回** 或 TopBar **返回室外** → 车站室外。  

Scene: `res://scenes/interiors/c11_station/c11_station.tscn`.

## 禁止偷懒

1. 禁止改 `station_assembler` / 其他 `c0X_*` profile / `scene_router`  
2. 禁止堵死门轴 13–16 通廊  
3. 禁止室内无返回室外（`return_path` 必须 STN）  
4. 禁止做成教堂竖厅（高窄中轴座席）冒充候车厅  
5. 禁止「放下就算」——无候车主区 / 无售票锚 / 无货运体量  
6. 禁止新画整套车站美术交差（本波优先复用既有 prop）  
7. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
8. 禁止用户中文路径强跑易损 Godot CLI  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (waiting hall + ticket in ≤3s)
      Peer PASS (horizontal waiting bay ≠ C10 nave)
      Scene-fit PASS (benches + timetable + ticket + freight)
      Territory PASS (freight crate mass east)
      Composition PASS (waiting / ticket / freight verbs; |d|≤3)
      Ensemble PASS (primary benches west, secondary ticket east, ≥30% open mid aisle)
      Interact-ready PASS (ticket customer south; staff via_stand north; freight west approach)
Art: Style/Bleed PASS (reuse indoor+crate set) | Craft N/A new | Set-complete N/A benches proxy
Assembly: Corridor PASS (door 13–16 clear) | Y-sort via craft | Profile-wire PASS
Meta: Name≠pixels PASS (titles match reuse) | Size PASS
Escalation: none
Blockers: none desk-side; confirm enter/return + actor walk in editor
```

## Acceptance checklist

- [x] `c11_station` enriched: waiting + ticket + freight clusters  
- [x] `return_path` = station outdoor (`STN`)  
- [x] `station_master` actor via ≥2 work clusters  
- [x] Door aisle 13–16 kept clear in layout  
- [x] This package MD + Visual QA desk  
- [x] Commit + push  
- [ ] User Godot Hub→车站→进入车站 / 返回 QA  
