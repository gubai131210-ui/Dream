# Phase 5 Wave A2 — parallel remaining packages

**Status:** IN PROGRESS 2026-09-11  
**User lock:** **Do not polish C01–C04 interiors further** (Wave E shell/ensemble deferred). Expand missing regions first.  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `realistic-scene-craft`, `painting-asset-craft`, `interior-territory-craft` (only if room needs enclosure), `interior-visual-qa` (new enterable rooms only)

## Parallel teams (file ownership mutual exclusion)

| Team | Package | Own (create/edit) | Portal host (append only) | Done when |
| --- | --- | --- | --- | --- |
| **Stall** | C05 | `scripts/market/**`, `docs/STALL_C05.md`, market stall assets | `market_street_dressing/controller` stall-only | **DONE** — 6 态同槽 `MarketStall`；六摊初始打散；点击循环 |
| **Fish** | C18–C22 | `scripts/fishing/**`, `docs/FISH_E.md` | `river` / `lake` spots | **DONE** (code) — 见 [`FISH_E.md`](./FISH_E.md) |
| **Mine** | C17 | `c17_mine` + `docs/MINE_C17.md` | `hill_farm` mouth | **DONE** (code) — 见 [`MINE_C17.md`](./MINE_C17.md) |
| **Well** | C14+C15 | profiles + `docs/WELL_C14C15.md` | residential well + C01 stair | **DONE** (code) — 见 [`WELL_C14C15.md`](./WELL_C14C15.md) |
| **Lighthouse** | C12 | `c12_lighthouse` + `docs/LIGHTHOUSE_C12.md` | lighthouse door | **DONE** (code) — 见 [`LIGHTHOUSE_C12.md`](./LIGHTHOUSE_C12.md) |
| **Forest** | C26+C27 | caves/hides + `docs/FOREST_SECRET_C26C27.md` | waterfall + forest_deep | **DONE** (code) — 见 [`FOREST_SECRET_C26C27.md`](./FOREST_SECRET_C26C27.md) |
| **Env** | C56–C57/H | `scripts/env/**`, `docs/ENV_H.md` | Thin hook on `village_square` TopBar | **DONE** — night + 晴/雨/雾；见 [`ENV_H.md`](./ENV_H.md) |

**Shared (Lead only / append-only):** `scripts/core/scene_router.gd` constants (pre-seeded), `tools/gen_interior_scenes.py` room list, `docs/PHASE5.md` status table.

### Stall (C05) — DONE

A10 six alcove stalls spawn with spread states (`open/locked/sold_out/setup/closed/empty`). Click cycles `MarketStall` through all six visuals on the **same** `position`; B09 body PNGs + goods ≤0.5. See [`STALL_C05.md`](./STALL_C05.md).

### Env-H (C56–C57) — DONE

Village square mounts `DayNightWeather` (scene-local). TopBar **白天/夜间** · **晴/雨/雾**; keys **N** / **R**. See [`ENV_H.md`](./ENV_H.md).

## SceneRouter paths (pre-seeded)

```
C12_LIGHTHOUSE_INT_PATH → scenes/interiors/c12_lighthouse/c12_lighthouse.tscn
C14_WELL_PATH → scenes/interiors/c14_well/c14_well.tscn
C15_BASEMENT_PATH → scenes/interiors/c15_basement/c15_basement.tscn
C17_MINE_PATH → scenes/interiors/c17_mine/c17_mine.tscn
C26_WATERFALL_CAVE_PATH → scenes/interiors/c26_waterfall_cave/c26_waterfall_cave.tscn
C27_FOREST_HIDE_A_PATH → scenes/interiors/c27_forest_hide_a/c27_forest_hide_a.tscn
C27_FOREST_HIDE_B_PATH → scenes/interiors/c27_forest_hide_b/c27_forest_hide_b.tscn
```

Fish may stay in outdoor scenes (no required interior path). Env needs no SceneRouter scene.

## Patterns

- Prefer **InteriorProfiles + InteriorCraft + gen_interior_scenes** for enterable rooms (same as C01–C04).
- Outdoor portals: `craft.make_portal` / hotspot with `scene_path` meta — **not** InfoPanel-only.
- Every interior: TopBar 返回室外 + Hub; south portal return.
- New art: `painting-asset-craft`; placement: `realistic-scene-craft`.

## 禁止偷懒

1. 禁止再深挖 C01–C04 布局/踢脚线/成套抛光（本波明确延期）  
2. 禁止门/井/塔只有 InfoPanel、无 `scene_path`  
3. 禁止室内无返回  
4. 禁止改别人团队目录；禁止大改室外布局（只加 portal）  
5. 禁止六摊永远 open；禁止摊位换态改 position  
6. 禁止钓鱼只有文案无 cast→catch  
7. 禁止矿洞/井/洞无 C 编号场景  
8. 禁止复制 assembler 改名交差  
9. 禁止棋盘格地板 / 整屋橙色洗色  
10. 禁止抢改 `scene_router.gd` 已有常量顺序（只追加已声明路径下的场景文件）  
11. 禁止未写本包 MD 就声称 DONE  
12. 禁止用户中文路径下强跑易损 Godot CLI；交付后由用户本地测  

## Acceptance (Wave A2)

1. Each team package enterable (or Fish catchable / Env toggleable) from outdoor  
2. Returns work  
3. Docs updated; PHASE5 table flipped  
4. Commit + push  
5. User Godot QA  
