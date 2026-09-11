# Aquarium C41 — 水族馆（西水缸墙 / 东钓鱼捐赠台）

**Status:** DONE 2026-09-11 (desk)  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C41  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`  
**Peer silhouette:** indoor aquarium gallery — west glass tanks with fish/plants + east fish-donate counter with rod+ledger; **not** grocery shelf wall

## Goal

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West tanks | `tanks` | 观缸 / 喂食 | `(6, 5)` — dual `fish_tank` + filter barrel + feed basket |
| East donate | `donate_fish` | 钓鱼捐赠 | `(16, 6)` — counter + bamboo rod + fish ledger (donate hook) |

South door `tx 9–12` clear. `return_path` = lake.

## Ownership

| Piece | Path |
| --- | --- |
| Profile | `"c41_aquarium"` + `P_FISH_TANK` |
| Prop | `fish_tank_00.png` · regen `tools/gen_civic_tour_c40_c45_props.py` |
| Doc | `docs/AQUARIUM_C41.md` |

## How to enter (user QA)

1. Godot `dream/` 本机测。  
2. Hub → **湖区** → ~`(420,480)` **进入水族馆**.  
3. Confirm west tanks with fish, east donate desk+rod+鱼谱; aisle `9–12` open; keeper patrols.  
4. Exit → lake.  

Scene: `res://scenes/interiors/c41_aquarium/c41_aquarium.tscn`.

## 禁止偷懒

1. 禁止门只有 InfoPanel  
2. 禁止堵南门 `9–12` / 无返回湖区  
3. 禁止用杂货架冒充水缸  
4. 禁止捐赠钩子无竿/鱼谱可读锚  
5. 禁止改他队 key / 整文件重写  
6. 禁止家用台灯（必须 `lamp_shop`）  
7. 禁止未 desk QA 标 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (aquarium tanks in ≤3s) | Peer PASS (glass tank ≠ grocery shelf)
      Scene-fit PASS (cool modulate + shop lamp) | Territory PASS (dual fish_tank mass)
      Composition PASS (观缸/捐赠) | Ensemble PASS | Interact-ready PASS (via_stands; door 9–12)
Art: Craft PASS (fish_tank_00 ≥800 colors) | Name≠pixels PASS (tank+fish+plants+filter)
Assembly: Corridor PASS | Profile-wire PASS (P_FISH_TANK)
Escalation: none
```

## Acceptance checklist

- [x] Tank zone + fish-donate hook, no 占位  
- [x] Signature `fish_tank_00` wired  
- [x] Desk QA PASS  
- [ ] User Godot: 湖区 → 进入水族馆 → return  
