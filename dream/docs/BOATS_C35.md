# Boats C35 — 停靠船 / 半沉船（甲板≠破壳）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C35, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft` (`wreck_hull`), `interior-visual-qa`  
**Peer silhouette:** tidy fishing skiff cabin vs half-sunken wreck — docked = deck cargo + helm stool; wreck = broken hull cue + reef + cache chest (RM ship interiors; **not** C34 pier, **not** C23 open dive)

## Goal

Two boat **states** with readable difference:

### Docked (`c35_boat_docked`)

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West deck | `deck` | 整货 | `(5, 4)` — barrels/crates/rod/basket |
| East cabin | `cabin` | 操舵 | `(13, 4)` — stool + ledger + `lamp_farm` |

`return_path` = C34 fish dock. Door `tx 7–10` clear. Enter via fish dock 「登船」.

### Wreck (`c35_boat_wreck`)

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West hull | `hull` | 探壳 | `(5, 4)` — `wreck_hull` + broken crate/keg + rocks |
| East cache | `cache` | 搜箱 | `(13, 4)` — coin chest + wet sacks + residual tavern lamp |

Dark floor + cool modulate. `return_path` = lake. Door `tx 7–10` clear.

## Ownership

| Piece | Path |
| --- | --- |
| Profiles | `"c35_boat_docked"` / `"c35_boat_wreck"` (+ `P_WRECK_HULL`) |
| Unique prop | `wreck_hull_00.png` |
| Prop regen | `tools/gen_transit_dive_wave_f_props.py` |
| Scene shells (Lead) | `scenes/interiors/c35_boat_*` |
| Hosts (Lead) | C34 fish extra 「登船」; lake ~(900,640) 「半沉船」 |
| This doc | `docs/BOATS_C35.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| C34 fish SW | 「登船」 | C35 docked |
| C35 docked south / TopBar | `return_path` | C34 fish |
| Lake | 「半沉船」 | C35 wreck |
| C35 wreck south / TopBar | `return_path` | lake |

## How to enter (user QA)

1. 渔码头 → **登船** — tidy deck + cabin lamp_farm; return to fish dock.  
2. Hub → 湖泊 ~(900,640) **半沉船** — broken hull + chest; dark cool tone; return lake.  
3. Confirm docked ≠ wreck in ≤3s (no 「占位」).

## 禁止偷懒

1. 禁止两船状态剪影雷同（完整甲板≠破壳礁石）  
2. 禁止船舱家用台灯（docked 必须 `lamp_farm`）  
3. 禁止堵死门轴 `7–10`  
4. 禁止改 lake assembler / 其他 profile  
5. 禁止未 desk Visual QA 就 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (docked skiff vs wreck in ≤3s) | Peer PASS (cabin boat / sunken hull)
      Scene-fit PASS (lamp_farm cabin; tavern residual on wreck OK) | Territory PASS (wreck_hull mass)
      Composition PASS (deck/cabin vs hull/cache) | Ensemble PASS (primary west, east secondary, open door)
      Interact-ready PASS (via_stands; approach at stool/chest)
Art: Style PASS | Craft PASS (wreck_hull ~198+ colors) | Name≠pixels PASS (broken hull cue)
Assembly: Corridor PASS | Profile-wire PASS
Escalation: none
Blockers: none desk-side
```

## Acceptance checklist

- [x] ≥2 boat states; no 「占位」  
- [x] `wreck_hull_00` wired on wreck  
- [x] Docked returns to C34 fish; wreck to lake  
- [x] This MD + desk QA PASS  
- [ ] User Godot: 登船 + 半沉船  
