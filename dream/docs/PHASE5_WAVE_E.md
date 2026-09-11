# Phase 5 Wave E — Vertical / yard expand (C46–C50)

**Status:** DONE (code / desk QA) 2026-09-11 — user Godot playtest pending  
**User lock:** Expand residential vertical + yard + farm cellar. **Do not polish C01–C04 / Wave A2 / B / C / D** unless broken portals.  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft` (unique props), `interior-visual-qa` (desk PASS), `realistic-scene-craft` (outdoor hosts — Lead only)

## Parallel teams (mutual exclusion)

| Team | Package | Own (edit only) | Portal host (Lead-seeded) | Done when |
| --- | --- | --- | --- | --- |
| **SecondFloor** | C46 | `c46_second_floor` + `docs/SECOND_FLOOR_C46.md` | C01 `extra_portals` 「↑二楼」 | stub → enrich |
| **Attic** | C47 | `c47_attic` + `docs/ATTIC_C47.md` | C46 stub `extra_portals` 「↑阁楼」 | stub → enrich |
| **Roof** | C48 | `c48_roof` + `docs/ROOF_C48.md` | C46 stub `extra_portals` 「↑屋顶」 | stub → enrich |
| **Backyard** | C49 | `c49_backyard` + `docs/BACKYARD_C49.md` | Residential 「进入后院」 | stub → enrich |
| **FarmCellar** | C50 | `c50_farm_cellar` + `docs/FARM_CELLAR_C50.md` | Farm residential 「进入地窖」 | stub → enrich |

**Shared (Lead only):** `scene_router.gd`, `gen_interior_scenes.py` (`--only-new`), outdoor assembler portal appends, C01/C46 stair portals, stub profiles, this MD, `PHASE5.md`.

### Portal / return map

| From | Control | Interior | Return |
| --- | --- | --- | --- |
| C01 主角宅 | 「↑二楼」 | C46 | → C01 |
| C46 二楼 | 「↑阁楼」 | C47 | → C46 |
| C46 二楼 | 「↑屋顶」 | C48 | → C46 |
| `village_residential` | 「进入后院」 ~`(400,260)` | C49 | → RES |
| `farm_residential` | 「进入地窖」 ~`(560,400)` | C50 | → FARM |

## SceneRouter (pre-seeded)

```
C46_SECOND_FLOOR_PATH → c46_second_floor
C47_ATTIC_PATH → c47_attic
C48_ROOF_PATH → c48_roof
C49_BACKYARD_PATH → c49_backyard
C50_FARM_CELLAR_PATH → c50_farm_cellar
```

## Patterns

1. Profile-driven interiors via `InteriorProfiles` + shell `.tscn` from `gen_interior_scenes.py`.
2. Vertical rooms use `extra_portals` stairs — **never** InfoPanel-only.
3. Outdoor enter = `craft.make_portal(..., scene_path, ...)`.
4. Each room: `return_path` + south door aisle clear; TopBar 返回.
5. Agents: **search-replace only their profile key(s)** in `interior_profiles.gd` — never rewrite whole file.
6. Distinct silhouettes: bedroom floor ≠ dusty attic ≠ open roof deck ≠ backyard yard ≠ farm production cellar (≠ C15 home basement).

## Library Done-when (INTERIOR_LIBRARY)

| ID | Done when |
| --- | --- |
| C46 | ≥1 二楼房间：卧室/阳台可读（可含轻起居） |
| C47 | ≥1 可搜刮阁楼：老家具/箱/蛛网/秘密可读 |
| C48 | ≥1 可站立屋顶区：烟囱/晾衣/观星/猫可读 |
| C49 | ≥1 后院：菜园/晾衣/柴/鸡窝或狗屋可读 |
| C50 | ≥1 农场地窖：酒窖/腌菜/奶酪后期生产可读（≠ C15 家用储藏） |

## 禁止偷懒（全队）

1. 禁止门只有 InfoPanel、无 `scene_path`  
2. 禁止室内无 `return_path` / 堵死南门通廊  
3. 禁止整文件重写 `interior_profiles.gd`（只改自己的 key）  
4. 禁止改其他团队 profile / assembler / scene_router（Lead 除外）  
5. 禁止抛光 C01–C04 / Wave A2/B/C/D 已完成包（C01 仅保留楼梯 portal）  
6. 禁止把控件堆在一页冒充多房间  
7. 禁止棋盘格地板 / 整屋橙色洗色 / 家用台灯进农场地窖与后院工作区  
8. 禁止未写包 MD + desk Interior Visual QA 就标 DONE  
9. 禁止五包剪影雷同（二楼卧 ≠ 蛛网阁楼 ≠ 露天屋顶 ≠ 后院 ≠ 农场地窖）；禁止 C50 抄 C15  
10. 禁止中文路径下强跑易损 Godot CLI（用户本机 QA）  
11. 禁止「放下就算」——须过 Ensemble / Interact-ready  
12. 禁止文件名对像素错；缺独特签名 prop 却声称 Name≠pixels PASS  

## Integration checklist (Lead)

- [x] All five profiles enriched (not stub 占位)  
- [x] Package MDs + desk QA PASS  
- [x] Vertical stairs + outdoor portals pickable; returns work (code-wired; user Godot QA pending)  
- [x] Mark teams DONE in this table  
- [ ] Commit + push `origin/master`  
- [ ] User Godot QA note  

| Team | Status |
| --- | --- |
| SecondFloor C46 | DONE (desk) |
| Attic C47 | DONE (desk) |
| Roof C48 | DONE (desk) |
| Backyard C49 | DONE (desk) |
| FarmCellar C50 | DONE (desk) |
