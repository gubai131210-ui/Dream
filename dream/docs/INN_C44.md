# Inn C44 — 旅馆（西大厅前台铃 / 东客房）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C44  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** village inn lobby — west reception desk with service bell + east single guest room bed; **not** tavern bar (C04) or plain shop counter

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West lobby | `lobby` | 登记 / 接待 | `(7, 6)` — `inn_desk` (bell) + ledger + visitor stool |
| East guest | `guest` | 住宿 | `(19, 7)` — single bed + dresser + lamp |

South door `tx 11–14` clear. `return_path` = market street. Rug under lobby.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c44_inn"` + `P_INN_DESK` |
| Prop | `inn_desk_00.png` |
| Doc | `docs/INN_C44.md` |

## How to enter (user QA)

1. Godot 本机测。  
2. Hub → **市集街** → ~`(200,400)` **进入旅馆**.  
3. Confirm front desk with service bell, east guest bed; aisle `11–14` open; 店主 patrols.  
4. Exit → market.  

Scene: `res://scenes/interiors/c44_inn/c44_inn.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel  
2. 禁止堵南门 `11–14` / 无返回市集  
3. 禁止用普通 counter 冒充带铃前台却声称 Name≠pixels PASS  
4. 禁止只有大厅无客房  
5. 禁止改他队 / 整文件重写  
6. 禁止农仓/店灯错配（大厅用 `lamp_indoor`）  
7. 禁止未 desk QA 标 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (inn lobby+guest ≤3s) | Peer PASS (bell desk ≠ shop counter / tavern bar)
      Scene-fit PASS (plank + indoor lamp) | Territory PASS (desk west, bed east)
      Composition PASS (接待/住宿) | Ensemble PASS (≥30% mid aisle) | Interact-ready PASS
Art: Craft PASS (inn_desk_00 ≥550 colors) | Name≠pixels PASS (desk+bell+key rack)
Assembly: Corridor PASS | Profile-wire PASS (P_INN_DESK)
Escalation: none
```

## Acceptance checklist

- [x] Lobby + ≥1 guest room, no 占位  
- [x] Signature `inn_desk_00`  
- [x] Desk QA PASS  
- [ ] User Godot: 市集 → 进入旅馆 → return  
