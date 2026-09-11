# Hotspring C42 — 温泉（东泡池蒸汽 / 西更衣）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C42  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** mountain indoor soak — irregular stone rim pool with painted steam + west change locker; **not** civic rectangular tiled bath (C43)

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| East pool | `pool` | 泡 / 蒸汽 | `(16, 5)` — `soak_pool` + rim rocks + stool + herbs (east of door) |
| West change | `change` | 更衣 | `(5, 8)` — dresser + basket + stool + indoor lamp |

South door `tx 9–12` clear. `return_path` = hill farm.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c42_hotspring"` + `P_SOAK_POOL` |
| Prop | `soak_pool_00.png` |
| Doc | `docs/HOTSPRING_C42.md` |

## How to enter (user QA)

1. Godot 本机测。  
2. Hub → **山地农舍** → ~`(640,360)` **进入温泉**.  
3. Confirm irregular stone soak + steam wisps, west change; aisle open; 泉守 patrols.  
4. Exit → hill farm.  

Scene: `res://scenes/interiors/c42_hotspring/c42_hotspring.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel  
2. 禁止堵南门 / 无返回山地  
3. 禁止用木桶冒充泡池 / 与 C43 矩形浴池剪影雷同  
4. 禁止蒸汽完全不可读（本包蒸汽绘入 soak_pool）  
5. 禁止改他队 / 整文件重写  
6. 禁止未 desk QA 标 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (hotspring soak+change ≤3s) | Peer PASS (irregular mountain pool ≠ C43 tile bath)
      Scene-fit PASS (warm stone + indoor change lamp) | Territory PASS (pool mass center)
      Composition PASS (泡/更衣) | Ensemble PASS | Interact-ready PASS
Art: Craft PASS (soak_pool_00 ≥600 colors + steam wisps) | Name≠pixels PASS
Assembly: Corridor PASS (9–12) | Profile-wire PASS (P_SOAK_POOL)
Escalation: none
```

## Acceptance checklist

- [x] Soak pool + change/steam readable, no 占位  
- [x] Distinct from C43 bath  
- [x] Desk QA PASS  
- [ ] User Godot: 山地 → 进入温泉 → return  
