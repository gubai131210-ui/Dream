# Goal G8 MCP runtime evidence

**Date:** 2026-09-13  
**MCP:** tomyud1 `godot-mcp-server` 0.6.0 · Godot connected · `MCPRuntime` OK  
**Errors:** 0 hard errors on key outdoor/interior surfaces after mayor/miller packs

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
| Farm residential idle | `docs/evidence/g8_farm_residential_idle.png` | 院内 DistrictInteract |
| Residential idle | `docs/evidence/g8_residential_idle.png` | 住宅区门阶/DistrictInteract |
| Forest entrance idle | `docs/evidence/g8_forest_entrance_idle.png` | 林口 DistrictInteract |
| Forest deep idle | `docs/evidence/g8_forest_deep_idle.png` | 深林区可玩壳 |
| Waterfall idle | `docs/evidence/g8_waterfall_idle.png` | 瀑布动画层 + DistrictInteract |
| Lighthouse idle | `docs/evidence/g8_lighthouse_idle.png` | 灯塔 DistrictInteract |
| Hill farm idle | `docs/evidence/g8_hill_farm_idle.png` | 坡田 DistrictInteract |
| Station idle | `docs/evidence/g8_station_idle.png` | 轨枕精灵站台 + DistrictInteract |
| Lake house idle | `docs/evidence/g8_lake_house_idle.png` | 湖屋 DistrictInteract |
| C06 town hall | `docs/evidence/g8_c06_town_hall_idle.png` | 议事厅室内 + 镇长 Anim + Portal_Return cues |
| C43 bathhouse | `docs/evidence/g8_c43_bathhouse_idle.png` | 浴场室内 props + return portal |
| C04 tavern | `docs/evidence/g8_c04_tavern_idle.png` | 酒馆室内抽样 |
| C04 smith | `docs/evidence/g8_c04_smith_idle.png` | 铁匠铺室内抽样 |
| Square work ring | `docs/evidence/g8_square_work_pose.png` | C53 工作环 InfoPanel（打铁环）+ 铁匠 demo actor |

## Runtime queries

- Museum portal children: `DoorFacade` + `DoorstepCue` + `DoorArchCue`
- Bath portal on square: `DoorFacade` (`facade_bath_00`) + doorstep/arch (queried live)
- Well hotspot `Visual/Marker.visible = false`; `PropSprite` present
- Lamp `Visual` includes `PropSprite` + `PointLight2D` (`LampLight`)
- Dresser after click: `FocusCorners` + `OpenFX_drawer_open` (`AnimatedSprite2D`)
- Portal click at museum cue → scene change to museum interior (header「博物馆」)
- River `FishCage_river_west_bend_cage`: after soak → `prompt_text=收取渔获` / fish_name 河鲦；collect resets empty
- C06 `镇长/Visual/Anim` present after `npc/mayor` pack; prior `no walk frames for 'mayor'` cleared
- Interior profile actor ids: **0 missing** packs (`list_missing_npc_packs.py`)
- Headless `g8_anim_fx_smoke.gd`: WorkPoseAnim frames=4 + shake_tree `FX_leaf_fall` **PASS**
- Fixed `NpcRoutineDemo` name collision on WorkPoseCue / demo actor respawn (rename before `queue_free`)

## Agent reviews this batch

- GenreQA + CanonQA: **PASS** (code) — [Review](6cdb8564-9291-4ed2-8feb-c26216bd21df)
- AnimQA mayor/miller: mayor PASS; miller foot metric disputed (alpha bbox foot_y=55 all frames)

## Still required for Goal complete

User Godot QA §7 **用户勾选** (visual fidelity / Waves A2–F) — Agent MCP 列不等于用户手感签收。
