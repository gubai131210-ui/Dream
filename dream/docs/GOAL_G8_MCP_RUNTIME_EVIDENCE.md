# Goal G8 MCP runtime evidence

**Date:** 2026-09-13  
**MCP:** tomyud1 `godot-mcp-server` 0.6.0 · Godot connected · `MCPRuntime` OK  
**Errors:** 0 hard errors on key surfaces (square / C01 / museum / market / river)

## Captures

| Shot | Path | What it proves |
| --- | --- | --- |
| Square idle | `docs/evidence/g8_square_idle.png` | Outdoor district art + UI; C58 props present |
| Square interact | `docs/evidence/g8_square_well_click.png` / `g8_square_lamp_click.png` | Click → InfoPanel feedback |
| Portal enter | `docs/evidence/g8_portal_museum_enter.png` | Square portal → C40 museum interior (return UI visible) |
| C01 idle | `docs/evidence/g8_c01_home_idle.png` | Interior art + fire FX + return portals |
| C01 dresser open | `docs/evidence/g8_c01_dresser_open.png` | InfoPanel「衣柜」+ runtime `OpenFX_drawer_open` |
| Market idle | `docs/evidence/g8_market_idle.png` | 商业街木棚摊位 + DistrictInteract 提示方块 |
| River idle | `docs/evidence/g8_river_idle.png` | bobber + fish cage sprite on shore |
| River cage ready | `docs/evidence/g8_river_fish_cage_ready.png` | place → soak ~6s → title「可收」+ `fish_cage_full` path |
| Lake idle | `docs/evidence/g8_lake_idle.png` | 湖泊岸边渔笼/浮漂区 + 门户 |
| Farmland idle | `docs/evidence/g8_farmland_idle.png` | 垄线/栅栏/DistrictInteract；farmer 无白底盘 |
| Residential idle | `docs/evidence/g8_residential_idle.png` | 住宅区门阶/DistrictInteract |
| Forest entrance idle | `docs/evidence/g8_forest_entrance_idle.png` | 林口 DistrictInteract |
| Waterfall idle | `docs/evidence/g8_waterfall_idle.png` | 瀑布动画层 + DistrictInteract |
| Station idle | `docs/evidence/g8_station_idle.png` | 轨枕精灵站台 + DistrictInteract |

## Runtime queries

- Museum portal children: `DoorFacade` + `DoorstepCue` + `DoorArchCue`
- Well hotspot `Visual/Marker.visible = false`; `PropSprite` present
- Lamp `Visual` includes `PropSprite` + `PointLight2D` (`LampLight`)
- Dresser after click: `FocusCorners` + `OpenFX_drawer_open` (`AnimatedSprite2D`)
- Portal click at museum cue → scene change to museum interior (header「博物馆」)
- River `FishCage_river_west_bend_cage`: after soak → `prompt_text=收取渔获` / fish_name 河鲦；collect resets empty

## Still required for Goal complete

User Godot QA §7 **用户勾选** (visual fidelity / Waves A2–F) — Agent MCP 列不等于用户手感签收。
