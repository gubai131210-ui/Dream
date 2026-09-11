# Tavern Up C45 — 酒馆二楼（西客房 / 东密会帷幕）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C45  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** tavern upstairs — west guest bed + east heavy curtain alcove with secret meeting table; **not** ground-floor bar (C04) or plain residential loft

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West guest | `guest` | 住宿 | `(5, 5)` — bed + dresser + tavern lamp |
| East secret | `secret` | 密会 | `(16, 6)` — `secret_curtain` + round table + stools + cipher notice |

South door `tx 9–12` clear. **`return_path` = C04 tavern** (keep return to ground tavern).

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c45_tavern_up"` + `P_SECRET_CURTAIN` |
| Prop | `secret_curtain_00.png` |
| Doc | `docs/TAVERN_UP_C45.md` |
| Portal host (Lead) | C04 `extra_portals` 「↑二楼」 |

## How to enter (user QA)

1. Godot 本机测。  
2. Hub → 市集 → **进入酒馆** (C04) → 点 **↑二楼**.  
3. Confirm west guest bed, east heavy purple curtain + meeting table; aisle open; 老板 patrols; south return → C04.  
4. Do **not** expect outdoor return (must land in C04 tavern).  

Scene: `res://scenes/interiors/c45_tavern_up/c45_tavern_up.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel（C04→C45 Lead 已挂）  
2. 禁止 `return_path` 不是 C04 / 堵南门 `9–12`  
3. 禁止用告示牌冒充密会帷幕  
4. 禁止只有客房无密会可读区（或反过来）  
5. 禁止抛光 C04 吧台布局（仅保留 ↑二楼 portal）  
6. 禁止改他队 / 整文件重写  
7. 禁止家用台灯（必须 `lamp_tavern`）  
8. 禁止未 desk QA 标 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (tavern loft guest+secret ≤3s) | Peer PASS (curtain alcove ≠ C04 bar / C46 balcony)
      Scene-fit PASS (dark floor + tavern lamp) | Territory PASS (curtain mass east)
      Composition PASS (住宿/密会) | Ensemble PASS | Interact-ready PASS
Art: Craft PASS (secret_curtain_00 ≥600 colors) | Name≠pixels PASS (rod+drape+glow gap)
Assembly: Corridor PASS | Profile-wire PASS (P_SECRET_CURTAIN, return=C04)
Escalation: none
```

## Acceptance checklist

- [x] Guest + secret meeting readable, no 占位  
- [x] `return_path` = C04 tavern  
- [x] Signature `secret_curtain_00`  
- [x] Desk QA PASS  
- [ ] User Godot: C04 → ↑二楼 → return C04  
