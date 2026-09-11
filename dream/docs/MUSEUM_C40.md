# Museum C40 — 博物馆（西展厅展柜 / 东捐赠台）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C40, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** civic museum hall — west glass exhibit cases (Stardew museum / RM exhibit room) + east donation desk with ledger; **not** shop shelf aisle or grocery wall

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West hall | `exhibit` | 观展 | `(6, 5)` — dual `exhibit_case` + specimen crates + shop lamp |
| East donate | `donate` | 捐赠登记 | `(17, 6)` — counter + ledger + coin box + notice (donation hook readable) |

South door strip `tx 10–13` clear. `return_path` = village square. Hint has no 「占位」.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c40_museum"` (+ `P_EXHIBIT_CASE`) |
| Unique prop | `assets/sprites/interior/props/exhibit_case_00.png` |
| Prop regen | `tools/gen_civic_tour_c40_c45_props.py` |
| This doc | `docs/MUSEUM_C40.md` |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测）。  
2. Hub → **广场** → ~`(220,280)` 门户 **进入博物馆**.  
3. Confirm west glass fossil cases, east donation desk+ledger; mid aisle `10–13` open; curator patrols exhibit ↔ donate.  
4. Exit: south **← 返回** / TopBar → square.  

Scene: `res://scenes/interiors/c40_museum/c40_museum.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel、无 `scene_path`  
2. 禁止堵死南门 `10–13` / 无 `return_path`  
3. 禁止用货架冒充玻璃展柜却声称 Name≠pixels PASS  
4. 禁止捐赠钩子只写文案、台前无站位  
5. 禁止改其他车道 profile / assembler / scene_router / 整文件重写  
6. 禁止家用台灯进展厅（必须 `lamp_shop`）  
7. 禁止棋盘格地板 / 整屋橙色洗色  
8. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (museum hall+donate in ≤3s) | Peer PASS (civic exhibit cases ≠ shop shelf)
      Scene-fit PASS (lamp_shop) | Territory PASS (dual exhibit_case mass west)
      Composition PASS (观展/捐赠) | Ensemble PASS (west cases primary, east desk, mid open)
      Interact-ready PASS (via_stands south of cases/desk; door 10–13 free)
Art: Style PASS (3/4 TL) | Craft PASS (exhibit_case_00 ≥600 colors) | Bleed PASS
      Name≠pixels PASS (glass case + fossil + plaque ≠ shelf)
Assembly: Corridor PASS | Profile-wire PASS (P_EXHIBIT_CASE)
Escalation: none
Blockers: none desk-side
```

## Acceptance checklist

- [x] `c40_museum` enriched: exhibit hall + donation hook, no 占位  
- [x] `P_EXHIBIT_CASE` / `exhibit_case_00.png`  
- [x] Desk Visual QA PASS  
- [ ] User Godot: 广场 → 进入博物馆 → return  
