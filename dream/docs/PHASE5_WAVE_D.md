# Phase 5 Wave D — Agro / market expand (C32, C33, C37–C39, C51–C52)

**Status:** IN PROGRESS (seeded) 2026-09-11  
**User lock:** Expand market + farm production rooms. **Do not polish C01–C04 / Wave A2 / Wave B / Wave C** unless broken portals.  
**Note:** This file is **not** [`INTERIOR_WAVE_D.md`](./INTERIOR_WAVE_D.md) (that lock is C01–C04 polish — deferred).  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `realistic-scene-craft` (outdoor portal host — Lead only), `interior-territory-craft`, `painting-asset-craft` (new props), `interior-visual-qa` (desk PASS)

## Parallel teams (mutual exclusion)

| Team | Package | Own (edit only) | Portal host (Lead-seeded) | Done when |
| --- | --- | --- | --- | --- |
| **Backstage** | C32 | `c32_market_back` + `docs/MARKET_BACK_C32.md` | Market 西侧货栈 | stub → enrich |
| **NightMarket** | C33 | `c33_night_market` + `docs/NIGHT_MARKET_C33.md` | Market 南巷 「进入夜市」 | stub → enrich |
| **Warehouse** | C37 | `c37_warehouse` + `docs/WAREHOUSE_C37.md` | Farm residential 「进入仓库」 | stub → enrich |
| **Workshop** | C38 | `c38_workshop` + `docs/WORKSHOP_C38.md` | Market 铁匠旁 「进入工坊」 | stub → enrich |
| **Processing** | C39 | `c39_processing` + `docs/PROCESSING_C39.md` | Farmland 农具棚 | stub → enrich |
| **Apiary** | C51 | `c51_apiary` + `docs/APIARY_C51.md` | Farmland 北缘 「进入蜂场」 | stub → enrich |
| **OrchardStore** | C52 | `c52_orchard_store` + `docs/ORCHARD_STORE_C52.md` | Farm residential 果园旁 「进入果仓」 | stub → enrich |

**Shared (Lead only):** `scene_router.gd`, `gen_interior_scenes.py` (`--only-new`), outdoor assembler portal appends, stub profiles, this MD, `PHASE5.md`.

### Outdoor host map

| Host scene | Landmark | Portal | Interior |
| --- | --- | --- | --- |
| `market_street` | 西侧货栈 `~(448,296)` | 进入市场后台 | C32 |
| `market_street` | 南巷夜市口 `~(640,560)` | 进入夜市 | C33 |
| `farm_residential` | 谷仓东侧 `~(1080,380)` | 进入仓库 | C37 |
| `market_street` | 铁匠东侧工坊口 `~(980,320)` | 进入工坊 | C38 |
| `farmland` | 农具棚 `~(560,400)` | 进入加工棚 | C39 |
| `farmland` | 北缘蜂场 `~(360,220)` | 进入蜂场 | C51 |
| `farm_residential` | 西院果园旁 `~(200,560)` | 进入果仓 | C52 |

## SceneRouter (pre-seeded)

```
C32_MARKET_BACK_PATH → c32_market_back
C33_NIGHT_MARKET_PATH → c33_night_market
C37_WAREHOUSE_PATH → c37_warehouse
C38_WORKSHOP_PATH → c38_workshop
C39_PROCESSING_PATH → c39_processing
C51_APIARY_PATH → c51_apiary
C52_ORCHARD_STORE_PATH → c52_orchard_store
```

## Patterns

1. Profile-driven interiors via `InteriorProfiles` + shell `.tscn` from `gen_interior_scenes.py`.
2. Outdoor enter = `craft.make_portal(..., scene_path, ...)` — **never** InfoPanel-only doors.
3. Each room: `return_path` + south door aisle clear; TopBar 返回室外.
4. Agents: **search-replace only their profile key(s)** in `interior_profiles.gd` — never rewrite whole file.
5. Distinct silhouettes: cargo dock ≠ night lantern bazaar ≠ crate warehouse ≠ craft bench ≠ dual machines ≠ hive meadow ≠ fruit press store.

## Library Done-when (INTERIOR_LIBRARY)

| ID | Done when |
| --- | --- |
| C32 | ≥1 后台房：仓库/卸货/推车/休息区 readable |
| C33 | 夜市层：夜间稀有货可读（本波用可进夜市巷室内落地） |
| C37 | ≥1 仓房：箱/袋/架/推车 |
| C38 | ≥1 工坊（木工/酿/奶酪等，≠ C04 铁匠铺） |
| C39 | ≥2 可交互机具（奶酪机/酿桶/蜂蜜/果酱等） |
| C51 | ≥1 蜂场点：蜂箱/花田 |
| C52 | ≥1 果园附属：果仓/榨汁房 |

## 禁止偷懒（全队）

1. 禁止门只有 InfoPanel、无 `scene_path`  
2. 禁止室内无 `return_path` / 堵死南门通廊  
3. 禁止整文件重写 `interior_profiles.gd`（只改自己的 key）  
4. 禁止改其他团队 profile / assembler / scene_router（Lead 除外）  
5. 禁止抛光 C01–C04 / Wave B/C 已完成包  
6. 禁止把控件堆在一页冒充多房间  
7. 禁止棋盘格地板 / 整屋橙色洗色 / 家用台灯进农场工坊仓  
8. 禁止未写包 MD + desk Interior Visual QA 就标 DONE  
9. 禁止七包剪影雷同（货栈后台 ≠ 夜市巷 ≠ 农仓 ≠ 工坊 ≠ 加工双机 ≠ 蜂场 ≠ 果仓）  
10. 禁止中文路径下强跑易损 Godot CLI（用户本机 QA）

## Integration checklist (Lead)

- [ ] All seven profiles enriched (not stub 占位)  
- [ ] Package MDs + desk QA PASS  
- [ ] Outdoor portals pickable; return works  
- [ ] Mark teams DONE in this table  
- [ ] Commit + push `origin/master`  
- [ ] User Godot QA note  
