# Well C14 + Basement C15

**Status:** DONE (Wave A2 Well team)  
**Date:** 2026-09-11  
**Locks:** [`PHASE5_WAVE_A2.md`](PHASE5_WAVE_A2.md), [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](INTERIOR_FOUNDATION.md)

## Goal

| Room | Enter from | Return |
| --- | --- | --- |
| **C14 井底** | A08 住宅区东北石井 `make_portal` → `SceneRouter.C14_WELL_PATH` | 南门 / TopBar → `RES`（住宅区） |
| **C15 地下室** | C01 `extra_portals` 楼梯 → `SceneRouter.C15_BASEMENT_PATH` | 南门 / TopBar → `C01_HOME_PATH` |

## Ownership

| Piece | Path |
| --- | --- |
| Profiles | `scripts/interiors/interior_profiles.gd` → `c14_well`, `c15_basement`, `c01_home.extra_portals` |
| Extra portal spawn | `scripts/interiors/interior_craft.gd` → `_spawn_extra_portals`（append-only） |
| Outdoor well portal | `scripts/areas/village_residential_assembler.gd` → NE well → C14 |
| Scenes | `scenes/interiors/c14_well/`, `scenes/interiors/c15_basement/` |

## Flow

```
住宅区东北井 ──portal──► C14 井底 ──return──► 住宅区
C01 主角宅西厨旁楼梯 ──extra_portal──► C15 地下室 ──return──► C01
```

## Profile notes

- **C14:** stone floor, cool modulate, pool + ledge + secret_mark clusters; `return_path = RES`.
- **C15:** stores + cellar kegs + stair landing; `return_path = C01`.
- **C01:** one `extra_portals` entry at `(tx=3, ty=16)` labeled `↓地下室` — no other C01 layout polish.

## 禁止偷懒

- 禁止井只有 InfoPanel、无 `scene_path`
- 禁止 C14/C15 无返回
- 禁止大改住宅区布局（只换井 portal）
- 禁止深抛光 C01–C04（仅一条地下室楼梯 portal）
- 禁止未写本 MD 就声称 DONE

## QA（用户本地 Godot）

1. 住宅区 → 东北井「↓井底」→ 进入 C14 → 返回室外到住宅区  
2. 进入 C01 → 西侧「↓地下室」→ C15 → 返回到 C01  
