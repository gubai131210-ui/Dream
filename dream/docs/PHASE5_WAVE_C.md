# Phase 5 Wave C — Explore / underground (C13, C16, C24–C25, C28–C31)

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**User lock:** Expand explore + underground. **Do not polish C01–C04 / Wave A2 / Wave B civic** unless broken portals.  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `realistic-scene-craft` (outdoor portal host — Lead only), `interior-territory-craft`, `painting-asset-craft` (new props), `interior-visual-qa` (desk PASS)

## Parallel teams (mutual exclusion)

| Team | Package | Own (edit only) | Portal host (Lead-seeded) | Done when |
| --- | --- | --- | --- | --- |
| **Mill** | C13 | `c13_mill` + `docs/MILL_C13.md` | Farmland 磨坊 door | **DONE** — 见 [MILL_C13.md](./MILL_C13.md) |
| **Caves** | C16 | `c16_cave_entry` + `c16_cave_mid` + `docs/CAVES_C16.md` | Hill farm 普通洞口 | **DONE** — 见 [CAVES_C16.md](./CAVES_C16.md) |
| **LakeIsle** | C24 | `c24_lake_island` + `docs/LAKE_ISLAND_C24.md` | Lake 登岛 | **DONE** — 见 [LAKE_ISLAND_C24.md](./LAKE_ISLAND_C24.md) |
| **RiverHide** | C25 | `c25_river_hide` + `docs/RIVER_HIDE_C25.md` | River 芦苇岔 | **DONE** — 见 [RIVER_HIDE_C25.md](./RIVER_HIDE_C25.md) |
| **GiantTree** | C28 | `c28_giant_tree` + `docs/GIANT_TREE_C28.md` | Forest deep 巨树洞 | **DONE** — 见 [GIANT_TREE_C28.md](./GIANT_TREE_C28.md) |
| **Ruins** | C29 | `c29_ruins` + `docs/RUINS_C29.md` | Forest deep 遗迹门 | **DONE** — 见 [RUINS_C29.md](./RUINS_C29.md) |
| **Cemetery** | C30 | `c30_cemetery` + `docs/CEMETERY_C30.md` | Square 教堂旁墓园 | **DONE** — 见 [CEMETERY_C30.md](./CEMETERY_C30.md) |
| **Sewer** | C31 | `c31_sewer` + `docs/SEWER_C31.md` | Residential 院井 ↓下水道 | **DONE** — 见 [SEWER_C31.md](./SEWER_C31.md) |

**Shared (Lead only):** `scene_router.gd`, `gen_interior_scenes.py` (`--only-new`), outdoor assembler portal appends, stub profiles, this MD, `PHASE5.md`.

### Outdoor host map

| Host scene | Landmark | Portal | Interior |
| --- | --- | --- | --- |
| `farmland` | 磨坊 `(~720,400)` | 进入磨坊 | C13 |
| `hill_farm` | 普通洞口 `~(1000,240)` (≠矿洞) | 进入洞穴 | C16 entry |
| `lake` | 南岸登岛点 `~(640,520)` | 登湖心岛 | C24 |
| `river` | 西岸芦苇岔 `~(220,380)` | 进入芦苇岔 | C25 |
| `forest_deep` | 巨树 `tile~(16,14)` | 进入巨树洞 | C28 |
| `forest_deep` | 遗迹 `tile~(28,12)` | 进入遗迹 | C29 |
| `village_square` | 教堂南墓园 `~(1000,360)` | 进入墓园 | C30 |
| `village_residential` | 院井 `~(480,280)` | ↓下水道 | C31 |

## SceneRouter (pre-seeded)

```
C13_MILL_PATH → c13_mill
C16_CAVE_ENTRY_PATH → c16_cave_entry
C16_CAVE_MID_PATH → c16_cave_mid
C24_LAKE_ISLAND_PATH → c24_lake_island
C25_RIVER_HIDE_PATH → c25_river_hide
C28_GIANT_TREE_PATH → c28_giant_tree
C29_RUINS_PATH → c29_ruins
C30_CEMETERY_PATH → c30_cemetery
C31_SEWER_PATH → c31_sewer
```

## Patterns

- Enrich **only your profile key(s)** via search-replace; never rewrite whole `interior_profiles.gd`.
- C16: entry `extra_portals` → mid; mid `return_path` → entry (or reverse); outdoor returns to hill_farm from entry.
- Stone/straw floors for caves/sewer/ruins; clear south door aisles.
- Silhouettes must differ across packages.
- Prefer reuse props; new art unique names; no outdoor grass bleed on indoor furniture.
- Desk `interior-visual-qa` before DONE; user Godot-tests (no Chinese-path Godot CLI).

## 禁止偷懒

1. 禁止再抛光 C01–C04 / Wave B 公服 / A2 已交付包  
2. 禁止拆掉 Lead 已挂的 `scene_path` portal  
3. 禁止室内无返回 / 堵死南门廊道  
4. 禁止改别人 profile；禁止整文件重写 `interior_profiles.gd`  
5. 禁止大改室外布局（只允许 Lead 已追加的 portal/地标）  
6. 禁止复制 assembler 改名交差  
7. 禁止棋盘格地板 / 整屋橙色洗色  
8. 禁止 C16 只有一层却声称分层 Done  
9. 禁止墓园无「穴」可读簇  
10. 禁止下水道只有 InfoPanel  
11. 禁止未写本包 MD 声称 DONE  
12. 禁止一次做满水晶/熔岩/冰全主题族（C16 本波：入口+中层两主题即可）  

## Acceptance

1. 各包可从对应室外进入并返回  
2. C16 可进中层再回入口/室外  
3. 八股 MD + PHASE5/本表 DONE  
4. Commit + push  
5. User Godot QA  
