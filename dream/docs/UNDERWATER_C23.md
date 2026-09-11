# Underwater C23 — 潜水点（水草 / 沉木 / 宝箱）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C23, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft` (`seaweed` / `sunken_wood`), `interior-visual-qa`  
**Peer silhouette:** shallow dive site — weed meadow west, sunken timber + chest east (aquarium/dive grammar; **not** C35 wreck cabin, **not** herb garden props)

## Goal

One enterable dive site:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West weeds | `weed` | 潜游 / 观草 | `(5, 4)` — dual `seaweed` + rocks |
| East wreckage | `wreckage` | 搜箱 | `(16, 5)` — `sunken_wood` + coin chest + crate + seaweed + dive lamp |

South door `tx 9–12` clear. Cool blue modulate + stone floor. `return_path` = lake. No 「占位」.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c23_underwater"` (+ `P_SEAWEED`, `P_SUNKEN_WOOD`) |
| Unique props | `seaweed_00.png`, `sunken_wood_00.png` |
| Prop regen | `tools/gen_transit_dive_wave_f_props.py` |
| Scene shell (Lead) | `scenes/interiors/c23_underwater/` |
| Host (Lead) | lake ~(640,700) 「↓潜水」 |
| This doc | `docs/UNDERWATER_C23.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| Lake | 「↓潜水」 | C23 |
| C23 south / TopBar | `return_path` | lake |

## How to enter (user QA)

1. Hub → **湖泊** ~(640,700) **↓潜水**.  
2. Confirm seaweed fronds (not herb baskets), sunken timber beam, chest south of wood; mid aisle open.  
3. Exit → lake.

## 禁止偷懒

1. 禁止用 `herbs_00` 冒充水草却声称 Name≠pixels PASS  
2. 禁止缺沉木或缺宝箱却声称 library min  
3. 禁止堵死门轴 `9–12`  
4. 禁止改 lake assembler / 其他 profile  
5. 禁止未 desk Visual QA 就 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (dive site in ≤3s: weeds + timber + chest) | Peer PASS (shallow dive)
      Scene-fit PASS (cool modulate; dive lamp) | Territory PASS (seaweed mass + sunken_wood beam)
      Composition PASS (2 verbs) | Ensemble PASS (west weeds primary, east timber+chest, open aisle)
      Interact-ready PASS (approach south of chest; door free)
Art: Style PASS | Craft PASS (seaweed ≥200 / sunken_wood ≥170) | Name≠pixels PASS (fronds ≠ herbs; beam ≠ crate)
Assembly: Corridor PASS | Profile-wire PASS
Escalation: none
Blockers: none desk-side
```

## Acceptance checklist

- [x] ≥1 dive site with seaweed + sunken wood + chest  
- [x] No 「占位」; unique props wired  
- [x] This MD + desk QA PASS  
- [ ] User Godot: lake → ↓潜水 → return  
