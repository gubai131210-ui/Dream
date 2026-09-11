# Bathhouse C43 — 公共浴场（东矩形浴池 / 西更衣柜）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C43  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** civic public bath — rectangular tiled pool with south steps + west dual lockers; **not** mountain irregular soak (C42)

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| East bath | `bath` | 入浴 | `(16, 5)` — `bath_pool` + rinse barrel + towel basket (clear of door 9–12) |
| West locker | `locker` | 更衣 | `(5, 7)` — dual dresser mass + stool + indoor lamp |

South door `tx 9–12` clear. `return_path` = village square.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c43_bathhouse"` + `P_BATH_POOL` |
| Prop | `bath_pool_00.png` |
| Doc | `docs/BATHHOUSE_C43.md` |

## How to enter (user QA)

1. Godot 本机测。  
2. Hub → **广场** → ~`(1080,280)` **进入浴场**.  
3. Confirm rectangular tiled bath + west lockers; aisle open; 管事 patrols.  
4. Exit → square.  

Scene: `res://scenes/interiors/c43_bathhouse/c43_bathhouse.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel  
2. 禁止堵南门 / 无返回广场  
3. 禁止与 C42 山石泡池剪影雷同  
4. 禁止更衣无双柜体量 / 无南站位  
5. 禁止改他队 / 整文件重写  
6. 禁止未 desk QA 标 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (civic bath+locker ≤3s) | Peer PASS (rect tile pool ≠ C42 soak)
      Scene-fit PASS (cool stone + indoor lamp) | Territory PASS (bath mass + dual dresser)
      Composition PASS (入浴/更衣) | Ensemble PASS | Interact-ready PASS
Art: Craft PASS (bath_pool_00 ≥600 colors) | Name≠pixels PASS (tiled basin+steps)
Assembly: Corridor PASS | Profile-wire PASS (P_BATH_POOL)
Escalation: none
```

## Acceptance checklist

- [x] Bath + change, distinct from C42, no 占位  
- [x] Signature `bath_pool_00`  
- [x] Desk QA PASS  
- [ ] User Godot: 广场 → 进入浴场 → return  
