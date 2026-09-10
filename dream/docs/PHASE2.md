# Dream Phase 2 — Village ring expansion

**Status:** IN PROGRESS  
**Depends on:** Phase 1 (A09 square + A01/A16 hubs), `SCALE.md`, `LAYOUT.md`, skill `realistic-scene-craft`

## Scope (locked)

| ID | Scene | Goal |
|---|---|---|
| A08 | 村庄住宅区 | Layered assemble from B assets; yards, lanes, fences; link from square east/south |
| A02 | 农场住宅区 | Farmhouse, yard, coop/barn slots, small pond, dirt paths, fence |
| Hub | A01 / A16 | Hotspots + buttons to enter A08 / A02 / A09 |
| Core | Shared | Extract reusable area craft helpers (masks, footprint, ecology, patrol) |

**Out of scope this phase:** A03 farmland gameplay crops, combat, full 14 scenes, A10 commercial (Phase 3).

## Skill / docs

All area assemblers MUST follow `.cursor/skills/realistic-scene-craft/`:
- Meander / bank / plantable / facing / footprint / walk graph
- Pass order: masks → ground → water → path → buildings → props → trees → actors → FX

## Architecture

```
scripts/areas/area_craft.gd          # shared static/helpers (or RefCounted craft context)
scripts/areas/village_residential_assembler.gd
scripts/areas/farm_residential_assembler.gd
scenes/areas/village_residential/village_residential.tscn
scenes/areas/farm_residential/farm_residential.tscn
scripts/core/scene_router.gd         # + paths
scripts/hub/hub_controller.gd        # + buttons/hotspots
```

Portal pattern: edge hotspots `→广场` / `→住宅区` / `→农场` using `SceneRouter`.

## Multi-agent split

| Agent | Owns | Must deliver |
|---|---|---|
| Systems | `area_craft.gd`, `scene_router.gd`, portal helper | Shared craft API used by both assemblers |
| Level-A08 | A08 scene + assembler + controller | Realistic residential layout vs A08 ref |
| Level-A02 | A02 scene + assembler + controller | Farm residential vs A02 ref |
| Hub | world_hub + connection_overview wiring | Enter A08/A02 without dead ends |
| QA | review only after merge | Checklist vs skill + refs |

## 禁止偷懒

- 禁止整张 A08/A02 参考图当场景交差
- 禁止复制粘贴广场 assembler 后只改坐标、不按参考构图分区
- 禁止树/作物进水或上石板；禁止门背对主路
- 禁止两个场景各写一套互不兼容的 mask API（必须走共享 craft）
- 禁止 Hub 只加按钮不加重置相机 bounds / 返回路径
- 禁止不做场景间 portal（孤岛场景）
- 禁止跳过 `LAYOUT`/`SCALE` 与 skill 检查清单
- UI：导航控件放顶栏，不要把所有入口堆在一个弹层里

## Acceptance

1. From Hub → A08 and A02 run without script errors  
2. From A09 → A08 (or A02) via portal and back  
3. Skill checklist items 1–7 pass on both new assemblers  
4. User local Godot test (Chinese paths)  
5. Commit; push if remote exists  

## Rebuild art if needed

```powershell
python dream/tools/make_seamless_terrain.py
```
