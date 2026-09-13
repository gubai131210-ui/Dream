# Train Car C36 — 客车厢（西座旅客 / 中廊 / 东座旅客）

**Status:** REWORK 2026-09-13  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C36, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft` (coach family sheet), `interior-visual-qa`  
**Peer silhouette:** passenger coach — twin seat banks flanking a clear mid aisle with **visible seated passengers** (RM/Stardew coach; **not** empty lounge sofas, **not** outdoor window HUD strip)

## Goal

One enterable passenger car that reads as **occupied coach** in ≤3s:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| North windows | `window_n` | 看暖窗 / 行李 | `(12, 1)` — warm-pane window wall + luggage + brass lamps |
| West seats | `seats_w` | 就座旅客 | `(5, 3)` — passenger A/B + empty seat + suitcase |
| Mid aisle | `aisle` | 通行 | `(12, 4)` — aisle runners + vestibule (south of door clear) |
| East seats | `seats_e` | 就座旅客 | `(18, 3)` — passenger C/A + empty seat + mail pouch |

South door strip `tx 10–13` stays clear (≥2-tile aisle). `return_path` = station (`STN`).  
**No** outdoor window scenery ride / bottom-screen landscape strip.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c36_train_car"` (+ `P_TRAIN_*` / `P_TRAIN_PASS_*`) |
| Family sheet | `tools/import_train_coach_family_v3.py` |
| Scene shell | `scenes/interiors/c36_train_car/` |
| Host | station 「进入车厢」 (ticket-gated) |
| This doc | `docs/TRAIN_C36.md` |

## 禁止偷懒

1. 禁止只用空凳/酒吧凳冒充车厢座排  
2. 禁止堵死中廊门轴 `10–13`  
3. 禁止把水果篮/木箱/渡轮牌塞进客车厢  
4. 禁止再挂窗外 HUD 景色条 / `TrainCarWindowRide`  
5. 禁止只有空座没有旅客剪影还声称「有乘客感」  
6. 禁止未 desk Visual QA 就 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (occupied coach in ≤3s) | Peer PASS (twin banks + mid aisle + passengers)
      Scene-fit PASS (warm coach panes / luggage / brass) | Territory PASS (seat banks both sides)
      Composition PASS (4 clusters; passengers as seat satellites) | Ensemble PASS (open corridor)
      Interact-ready PASS (via_stands; door 10–13 free)
Art: Style PASS (one family sheet) | Craft PASS | Name≠pixels PASS
Assembly: Corridor PASS | Profile-wire PASS
Escalation: none
Blockers: none desk-side — user must confirm passenger density in Godot
```

## Acceptance checklist

- [x] Window scenery ride removed  
- [x] Coach family props + seated passengers wired  
- [x] Mid aisle clear; `return_path` = STN  
- [ ] User Godot: station → 进入车厢 → 看到旅客与空座 → return  
