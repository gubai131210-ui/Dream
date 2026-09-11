# Attic C47 — 阁楼（旧箱垛 / 蛛网 / 秘密）

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_E.md`](./PHASE5_WAVE_E.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C47, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft` (crate/trunk mass), `painting-asset-craft` (trunk + cobweb), `interior-visual-qa` (desk PASS)  
**Peer silhouette:** residential dusty attic — west stacked trunks/crates, east cobweb-hidden chest + old rocking (Stardew loft / real house attic: forgotten luggage + secret stash; **≠** C15 stone cellar wine/shelves)

## Goal

One enterable **lootable attic** with readable **old furniture / crates / cobwebs / secret**:

| Zone | Cluster id | Verb | Tile anchor |
| --- | --- | --- | --- |
| West mass | `trunks` | 堆垛 / 搜刮 | `(5, 4)` — `trunk_old` + stacked crates/sacks + cobweb + indoor lamp |
| East secret | `secret` | 揭秘 / 搜刮 | `(15, 5)` — coin chest behind cobweb + rocking + dresser + basket |

South door strip `tx 8–11` stays clear (≥2-tile aisle). `return_path` = C46 二楼. Hint has no 「占位」. Optional attic cat at trunks. No NPC actor (empty loft).

**Distinct from:**

| Peer | Diff |
| --- | --- |
| C15 basement | C47 = **plank** dusty loft + cobwebs + steamer trunk + secret; C15 = **stone** cellar + kegs/shelves |
| C46 second floor | C47 = storage loft under rafters, no bedroom bed/balcony |
| C37 warehouse | C47 = forgotten residential luggage, not farm outbound cart |

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c47_attic"` (+ `P_TRUNK_OLD`, `P_COBWEB`) |
| Unique props | `assets/sprites/interior/props/trunk_old_00.png`, `cobweb_00.png` |
| Prop regen | `tools/gen_attic_c47_props.py` |
| Scene shell (Lead) | `scenes/interiors/c47_attic/c47_attic.tscn` |
| Portal host (Lead) | C46 `extra_portals` 「↑阁楼」 |
| Router const (Lead) | `SceneRouter.C47_ATTIC_PATH` |
| This doc | `docs/ATTIC_C47.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| C46 二楼 | 「↑阁楼」 | C47 attic |
| C47 south door / TopBar 返回 | `return_path` + craft portal | C46 second floor |
| C47 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **住宅区** → **进入主角宅** → **↑二楼** → **↑阁楼**.  
3. Confirm west dusty trunk/crate mass, east cobweb-fronted secret chest + old rocking; mid door corridor open; optional cat near trunks.  
4. Exit: south **← 返回** or TopBar → C46 二楼.  

Scene path: `res://scenes/interiors/c47_attic/c47_attic.tscn`.

## 禁止偷懒

1. 禁止阁楼门只有 InfoPanel、无 `scene_path`（Lead 已挂 C46→C47）  
2. 禁止室内无 `return_path` 回 C46 / 堵死南门 `8–11` 通廊  
3. 禁止整文件重写 `interior_profiles.gd`（只改 `c47_attic` + 本包 const）  
4. 禁止改其他团队 profile / assembler / scene_router / C46  
5. 禁止抄 C15 石窖酒桶或 C50 农场地窖却声称阁楼 PASS  
6. 禁止棋盘格地板 / 整屋橙色洗色 / 无蛛网却声称 Name≠pixels  
7. 禁止用普通 crate 冒充 `trunk_old` / 用灰尘颗粒冒充 `cobweb`  
8. 禁止未写本 MD / 未 desk Visual QA 就声称 DONE  
9. 禁止「放下就算」——须过 Ensemble / Interact-ready（箱前/宝箱前可站）  
10. 禁止中文路径下强跑易损 Godot CLI（用户本机 QA）  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (dusty loft storage+secret in ≤3s) | Peer PASS (residential attic mass+web stash)
      Scene-fit PASS (lamp_indoor OK residential loft; plank; no window) | Territory PASS (stacked crate height + trunk_old mass west)
      Composition PASS (2 verbs trunks/secret; satellites |d|≤3) | Ensemble PASS (west mass primary, east secret, open mid aisle ≥30%)
      Interact-ready PASS (south of trunk/sacks; south of chest/basket; door 8–11 free)
Art: Style PASS (3/4 TL dusty wood) | Craft PASS (trunk_old ≥400 colors; cobweb ≥200) | Bleed PASS
      Name≠pixels PASS (trunk_old_00 = steamer trunk; cobweb_00 = corner web)
Assembly: Corridor PASS (door→axis ≥2) | Y-sort via craft | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm ↑阁楼 portal + return in editor
```

## Acceptance checklist

- [x] `c47_attic` profile: trunk/crate mass + cobweb secret + old rocking, darker dusty modulate, clear aisle, no 占位 hint  
- [x] Unique `trunk_old_00` + `cobweb_00` wired (`P_TRUNK_OLD`, `P_COBWEB`)  
- [x] Distinct from C15 (plank+web ≠ stone+keg) and C46 bedroom  
- [x] Optional cat ambient; no NPC actor  
- [x] `return_path` = `SceneRouter.C46_SECOND_FLOOR_PATH`  
- [x] This package MD + desk Visual QA PASS  
- [ ] User Godot: Hub → 住宅区 → 进入主角宅 → ↑二楼 → ↑阁楼 → return C46  
