# Roof C48 — 屋顶（烟囱 / 晾衣 / 观星 / 猫）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_E.md`](./PHASE5_WAVE_E.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C48, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft` (open deck zones), `painting-asset-craft` (chimney / clothesline / telescope), `interior-visual-qa` (desk PASS)  
**Peer silhouette:** open elevated deck (apiary C51 open feel) — **not** meadow: cool stone night wash, tall chimney + laundry + star deck; mid south door aisle clear

## Goal

One standable residential roof with **readable chimney / clothesline / stargazing / cat**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West stack | `chimney` | 烟囱 / 猫憩 | `(5, 4)` — brick chimney + rain barrel + foot stool + tile crate |
| East laundry | `clothesline` | 晾衣 | `(15, 4)` — two-post clothesline + baskets |
| SE sky | `star_deck` | 观星 | `(17, 7)` — telescope + stool + tavern candle + chart crate |

South door strip `tx 9–12` stays clear (≥2-tile aisle). `return_path` = C46 second floor. Hint has no 「占位」.

**Distinct from:**

| Peer | Diff |
| --- | --- |
| C51 apiary | C48 = cool stone night deck + chimney/laundry/scope; **no** straw meadow / flower beds / farm lamp |
| C46 balcony | C48 = elevated roof with outdoor chimney pot + clothesline; not indoor plank bedroom/balcony |
| C01 hearth | C48 chimney = **roof stack** (`chimney_00`), not indoor `fireplace_00` |

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c48_roof"` (+ `P_CHIMNEY` / `P_TELESCOPE`; shared `P_CLOTHESLINE`) |
| Unique props | `assets/sprites/interior/props/chimney_00.png`, `telescope_00.png` (+ `clothesline_00.png` shared with C49) |
| Prop regen | `tools/gen_roof_c48_props.py` |
| Scene shell (Lead) | `scenes/interiors/c48_roof/c48_roof.tscn` |
| Portal host (Lead) | C46 `extra_portals` 「↑屋顶」 |
| Router const (Lead) | `SceneRouter.C48_ROOF_PATH` |
| This doc | `docs/ROOF_C48.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| C46 二楼 | 「↑屋顶」 | C48 interior |
| C48 south door / TopBar 返回 | `return_path` + craft portal | C46 second floor |
| C48 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **住宅区** → **主角宅** → 「↑二楼」→ C46 → 「↑屋顶」。  
3. Confirm west tall brick chimney (not indoor fireplace), east laundry on clothesline, SE telescope + stool; cat near chimney; mid door corridor open; cool night modulate (not orange).  
4. Exit: south **← 返回** or TopBar → C46 二楼.  

Scene path: `res://scenes/interiors/c48_roof/c48_roof.tscn`.  
User path: Hub → 住宅区 → 主角宅 → ↑二楼 → ↑屋顶 → return C46.

## Ambient note

Cat ambient stays on `chimney` cluster (`dx/dy` south-east of stack) — fits warm foot / rain-barrel perch.

## 禁止偷懒

1. 禁止屋顶门只有 InfoPanel、无 `scene_path`（Lead 已从 C46 挂）  
2. 禁止室内无 `return_path` 回 C46 / 堵死南门 `9–12`  
3. 禁止用 `fireplace_00` 改名冒充屋顶烟囱、或用 `herbs_00` 冒充晾衣绳  
4. 禁止整屋橙色洗色 / 农场工业灯进住宅屋顶（用 `lamp_tavern`）  
5. 禁止改其他 profile / assembler / scene_router / C46 portals  
6. 禁止棋盘格地板 / 把屋顶做成蜂场草甸剪影  
7. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
8. 禁止「放下就算」——须 Ensemble（烟囱主锚 + 东晾衣 + 东南观星 + ≥30% 空地）与 Interact-ready  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (standable night roof: chimney/laundry/stars/cat in ≤3s)
      Peer PASS (open elevated deck vs C51 meadow; chimney ≠ C01 fireplace)
      Scene-fit PASS (stone + cool blue modulate + lamp_tavern candle)
      Territory PASS (west stack mass + east laundry span + SE scope; mid aisle open)
      Composition PASS (3 verbs; satellites |d|≤3) | Ensemble PASS (chimney primary, open sky-deck)
      Interact-ready PASS (stool south of chimney; basket south of line; stool west of telescope; door 9–12 free)
Art: Style PASS (3/4 TL light) | Craft PASS (chimney≈200 / clothesline≈277 / telescope≈111 unique colors)
      Bleed PASS | Name≠pixels PASS (chimney_00 = brick pot stack; clothesline_00 = posts+laundry; telescope_00 = brass scope)
Assembly: Corridor PASS | Y-sort via craft | Profile-wire PASS (P_CHIMNEY / P_CLOTHESLINE / P_TELESCOPE)
Escalation: none
Blockers: none desk-side; confirm C46「↑屋顶」pick + return in editor
```

## Acceptance checklist

- [x] `c48_roof` profile: chimney + clothesline + star_deck, cool night stone, clear aisle, no 占位 hint  
- [x] Unique chimney + telescope props wired; clothesline signature (shared PNG OK)  
- [x] Cat ambient on chimney; tavern candle (not farm lamp)  
- [x] Distinct from C51 meadow / C01 fireplace  
- [x] `return_path` = C46  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: Hub → 住宅区 → 主角宅 → ↑二楼 → ↑屋顶 → return C46  
