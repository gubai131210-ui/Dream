# Train Car C36 — 客车厢（西座 / 东座 / 中廊）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C36, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft` (`train_seat_row`), `interior-visual-qa`  
**Peer silhouette:** passenger coach — twin seat-row benches flanking a clear mid aisle (RM train car / station coach; **not** tavern booth stools alone, **not** pew chapel)

## Goal

One enterable passenger car:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West seats | `seats_w` | 就座 | `(5, 4)` — `train_seat_row` + luggage + `lamp_indoor` |
| Mid aisle | `aisle_rack` | 通行 / 看牌 | `(12, 2)` — notice + small crate (north of door) |
| East seats | `seats_e` | 就座 / 邮包 | `(19, 4)` — `train_seat_row` + mail crate + lamp |

South door strip `tx 11–14` stays clear (≥2-tile aisle). `return_path` = station (`STN`). Hint has no 「占位」.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c36_train_car"` (+ `P_TRAIN_SEAT_ROW`) |
| Unique prop | `train_seat_row_00.png` |
| Prop regen | `tools/gen_transit_dive_wave_f_props.py` |
| Scene shell (Lead) | `scenes/interiors/c36_train_car/` |
| Host (Lead) | station ~(900,360) 「进入车厢」 |
| This doc | `docs/TRAIN_C36.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Station | 「进入车厢」 | C36 |
| C36 south / TopBar | `return_path` | station |

## How to enter (user QA)

1. Hub → **车站** ~(900,360) **进入车厢**.  
2. Confirm west/east purple bench rows, mid aisle open, conductor patrols seats ↔ aisle.  
3. Exit south / TopBar → station.

## 禁止偷懒

1. 禁止只用 bar stool 冒充车厢座排却声称 Name≠pixels PASS  
2. 禁止堵死中廊门轴 `11–14`  
3. 禁止改 station assembler / 其他 profile  
4. 禁止未 desk Visual QA 就 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (passenger coach in ≤3s) | Peer PASS (coach seat rows + aisle)
      Scene-fit PASS (lamp_indoor OK in passenger car) | Territory PASS (seat-row benches both sides)
      Composition PASS (3 clusters; mid notice north of door) | Ensemble PASS (symmetric seats, open corridor)
      Interact-ready PASS (via_stands south of seats; door 11–14 free)
Art: Style PASS | Craft PASS (train_seat_row ≥200 colors) | Name≠pixels PASS (bench row ≠ stool)
Assembly: Corridor PASS | Profile-wire PASS
Escalation: none
Blockers: none desk-side
```

## Acceptance checklist

- [x] ≥1 train car; seat rows wired; no 「占位」  
- [x] Mid aisle clear; `return_path` = STN  
- [x] This MD + desk QA PASS  
- [ ] User Godot: station → 进入车厢 → return  
