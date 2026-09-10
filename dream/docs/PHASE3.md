# Dream Phase 3 — Farmland + Market ring

**Status:** IN PROGRESS  
**Depends on:** Phase 2 (A08 / A02 / Hub + `AreaCraft`), `SCALE.md`, `LAYOUT.md`, `BUILDING_PLACEMENT.md`, skill `realistic-scene-craft`

Phase 2 is **DONE** for scope A08/A02/Hub wiring (building AABB lock documented). This phase expands the village ring with gameplay farmland and a commercial street.

## Scope (locked)

| ID | Scene | Goal |
|---|---|---|
| A03 | 农田区 | Meandering irrigation stream, **≥6 fenced crop plots**, central shed/windmill-like hub buildings **fully inside** farm build zone, dirt paths + bridges, link from A02 |
| A10 | 商业街/市集 | Stone market plaza with **≥4 stalls**, shop-facing buildings on north/east of plaza, props (crates/barrels/lamps), link from A09 |
| Hub | A01 / A16 | TopBar + map hotspots enter A03 / A10 (separate buttons; no stacked popup) |
| Core | Shared | `SceneRouter` paths; optional crop-bed paint helper on `AreaCraft`; portal links A02↔A03, A09↔A10 |

**Out of scope this phase:** crop growth simulation / inventory, combat, A04–A07 / A11–A15 full scenes, shop UI economy.

## Skill / docs (mandatory)

- `.cursor/skills/realistic-scene-craft/` checklist  
- `docs/BUILDING_PLACEMENT.md` — **full sprite AABB ⊆ build/play zone**; farm uses inset past fence  
- Door dirt **south of** footprints; buildings may `allow_path=true`  
- Pass: masks → grass → dirt → water → path → buildings → props/crops/stalls → trees → actors → FX → portals  

## Architecture (locked paths)

```
scripts/core/scene_router.gd
  + FARMLAND_PATH  := res://scenes/areas/farmland/farmland.tscn
  + MARKET_PATH    := res://scenes/areas/market_street/market_street.tscn
  + go_farmland() / go_market_street()

scripts/areas/farmland_assembler.gd
scripts/areas/farmland_controller.gd
scenes/areas/farmland/farmland.tscn

scripts/areas/market_street_assembler.gd
scripts/areas/market_street_controller.gd
scenes/areas/market_street/market_street.tscn

# Existing scenes get portal/TopBar links only (no full rewrite):
scripts/areas/farm_residential_assembler.gd   # →农田
scripts/areas/farm_residential_controller.gd
scripts/areas/village_square_assembler.gd     # →商业街
scripts/areas/village_square_controller.gd
scripts/hub/hub_controller.gd
scenes/hub/world_hub.tscn
scenes/hub/connection_overview.tscn
```

Scene node skeleton (match A02):

`Assembler`, `Ground`, `Path`, `Water`, `YSortRoot`, `DebugGrid`, `CameraController`, `InfoPanel`, `UI/TopBar` (Hint + BackHub + BackConnections + neighbor buttons).

Map size default: **40×30** tiles, `BASE_TILE=32`.

### A03 layout targets (from `assets/raw/references/A03_farmland.png`)

1. Forest belt outside; **PLAY/FARM_ZONE** inset; fence on zone edge; **BUILD_ZONE** further inset for buildings.  
2. Central dirt hub with 1–2 buildings (reuse `building_01`/`building_02`/`building_04` as shed/barn stand-ins; no windmill art → shed + lamp OK).  
3. Multiple **rectangular dirt crop beds** with low fence posts; crop visuals = colored `Polygon2D`/`ColorRect` rows OR prop sacks if no B12 slices yet (label hotspots 小麦/蔬菜).  
4. Meandering stream (not straight rect) + 1–2 path bridges.  
5. Portals: `→农场住宅`, `→广场`, `→总览`.

### A10 layout targets (from `assets/raw/references/A10_*`)

1. Central **stone plaza** (`path_mask`) with stall props (crates + barrels + benches as stalls; awning = ColorRect stripe if needed).  
2. Shop/houses **north of plaza**, south-facing, full AABB inside `PLAY_ZONE`.  
3. Optional west river band if it fits without crowding (prefer short meander).  
4. Portals: `→广场`, `→住宅区`, `→总览`.

## Multi-agent split

| Agent | Owns (ONLY these files) | Must deliver |
|---|---|---|
| **Systems** | `scene_router.gd`; additive helpers in `area_craft.gd` if needed (`paint_crop_bed` optional) | Paths + go_* API; do not rewrite assemblers |
| **Level-A03** | `farmland_*` scene/scripts only; may patch **A02** portal/TopBar → farmland | Playable A03 vs ref craft |
| **Level-A10** | `market_street_*` only; may patch **A09** portal/TopBar → market | Playable A10 vs ref craft |
| **Hub** | `hub_controller.gd`, `world_hub.tscn`, `connection_overview.tscn` | Enter A03/A10 from hub; camera bounds |
| **QA** | review only | Checklist vs skill + BUILDING_PLACEMENT |

**Wave order:** Systems first (or parallel if paths already committed) → A03 ∥ A10 → Hub → QA.

## 禁止偷懒

- 禁止把 A03/A10 参考图整张贴进场景交差  
- 禁止复制 A02/A09 assembler 后只改类名与坐标、不按参考分区（农田菜畦 vs 农舍院落；市集摊位 vs 广场喷泉）  
- 禁止建筑只用脚底检测；必须 `find_building_inside` + inset build zone（见 BUILDING_PLACEMENT）  
- 禁止作物/树进水或上石板主路；禁止门背对主路  
- 禁止 A03/A10 各自再造一套 mask API（必须 `AreaCraft`）  
- 禁止 Hub 只加一个「更多」弹层塞所有入口；商业街/农田各自顶栏按钮 + 地图热点  
- 禁止孤岛场景（无 portal / 无返回 Hub）  
- 禁止跳过相机 bounds 与 TopBar 返回  
- 禁止未切片 B12 时假装有完整作物生长系统；占位作物必须成畦且可点击说明  
- UI：导航在 TopBar，信息用现有 InfoPanel，不要新堆一页仪表盘  

## Acceptance

1. Hub → A03 and A10 run without script errors  
2. A02 ↔ A03 and A09 ↔ A10 via edge portals + TopBar  
3. Skill checklist + BUILDING_PLACEMENT pass on both assemblers  
4. User local Godot test (Chinese paths) — agent 不代替用户跑完整编辑器测试  
5. Commit; push if `git remote` exists, else remind user to add GitHub remote  

## References

- `dream/assets/raw/references/A03_farmland.png`  
- `dream/assets/raw/references/A10_commercial_street.png` (or `A10_market_street.png`)  
- Prior pattern: `farm_residential_*`, `village_square_*`
