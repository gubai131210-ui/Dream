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
| C07 school | `docs/evidence/g8_c07_school_idle.png` | 学校室内抽样 |
| C09 library | `docs/evidence/g8_c09_library_idle.png` | 图书馆室内抽样 |
| C10 church | `docs/evidence/g8_c10_church_idle.png` | 教堂室内抽样 |
| Square work ring | `docs/evidence/g8_square_work_pose.png` | C53 工作环 InfoPanel（打铁环）+ 铁匠 demo actor |
| Square C53 buttons | `docs/evidence/g8_square_c53_buttons.png` | TopBar「工作:播种环」「生活:用餐」**visible=true** |
| Square outdoor UI | `docs/evidence/g8_square_outdoor_work_season.png` | 工作/生活环 + 春花季节 TopBar；室外 Genre 路径后的广场 idle |
| Square WorkPoseCue | `docs/evidence/g8_square_work_pose_cue.png` | C53 `WorkPoseCue` + `WorkPoseAnim` + outdoor `PropSprite`（6s hold） |
| Square zoom1 + poses v2 | `docs/evidence/g8_square_zoom1_work_pose_v2.png` | `zoom=(1,1)` + farmer-based occupational poses |
| Forest deep landmarks | `docs/evidence/g8_forest_deep_landmarks.png` | C28 巨树 / C29 遗迹 `Visual/PropSprite` |
| River reed landmark | `docs/evidence/g8_river_reed_landmark.png` | C25 芦苇岔口 `Visual/PropSprite` |
| Station track band | `docs/evidence/g8_station_track_band.png` | 站台轨道 `PropSprite` + SleeperCue |
| Lake ferry boat | `docs/evidence/g8_lake_ferry_boat.png` | C24 登岛渡口 `boat_skiff_00` |
| C62 secret portal | `docs/evidence/g8_c62_secret_portal.png` | 深林 `WorldPortal_树洞密道` + `ruin_arch` façade cues |
| C16 cave entry | `docs/evidence/g8_c16_cave_entry_idle.png` | C62 链上洞穴入口室内 |
| C40 museum idle | `docs/evidence/g8_c40_museum_idle.png` | 博物馆室内（进门后 idle） |
| C11 station int | `docs/evidence/g8_c11_station_idle.png` | 车站候车厅室内 |
| C12 lighthouse int | `docs/evidence/g8_c12_lighthouse_idle.png` | 灯塔内部 |
| C17 mine | `docs/evidence/g8_c17_mine_idle.png` | 矿洞入口层 |
| C28 giant tree | `docs/evidence/g8_c28_giant_tree_idle.png` | 巨树洞室内 |
| C29 ruins | `docs/evidence/g8_c29_ruins_idle.png` | 遗迹主殿 |
| C30 cemetery | `docs/evidence/g8_c30_cemetery_idle.png` | 墓地区 |
| C44 inn | `docs/evidence/g8_c44_inn_idle.png` | 旅馆大厅 |
| C07 school semantic | `docs/evidence/g8_c07_school_semantic.png` | 黑板 + 课桌专用 prop |
| C10 church altar | `docs/evidence/g8_c10_church_altar.png` | 祭坛专用 prop（非 counter） |
| C11 station benches | `docs/evidence/g8_c11_station_benches.png` | 候车长椅专用 prop |
| C25 river hide reed | `docs/evidence/g8_c25_river_hide_reed.png` | 芦苇丛专用 prop（非 hay） |
| C31 sewer pipes | `docs/evidence/g8_c31_sewer_pipes.png` | 管道段专用 prop（非 barrel） |
| Market EMPTY | `docs/evidence/g8_market_stall_empty.png` | C05 空位专用 bay |
| Market LOCKED | `docs/evidence/g8_market_stall_locked.png` | C05 锁定专用板 |
| Market OPEN produce | `docs/evidence/g8_market_stall_produce.png` | 蔬果箱 `produce_crate_00`（非 stall_face） |

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
- Headless `g8_anim_fx_smoke.gd`: WorkPoseAnim frames=4 + shake_tree `FX_leaf_fall` **PASS** (re-run 2026-09-13 after outdoor prop remap)
- Fixed `NpcRoutineDemo` name collision on WorkPoseCue / demo actor respawn (rename before `queue_free`)
- Demo actor keeps `NpcRingDemoActor` after `PatrolActor.setup` (no clash with plaza `摊主`/`铁匠` Area2D)
- Outdoor Genre: DIK / seasonal / work cues / hidden_chests use `sprites/props/` only (`qa_no_placeholder` bans `interior/props`)
- Live `WorkPoseCue`: children `WorkPoseAnim` + `PropSprite` + `ContactShadow`; `modulate.a=1`; hold ~6s for QA/MCP
- Landmark hotspots own `Visual/PropSprite`: 巨树/遗迹残垣/芦苇岔口 (queried live); market bridge + cemetery + mine/cave/渡口 wired similarly
- Station `站台轨道` + Lake `登岛渡口` boat skiff; lake house building reparented into hotspot Visual
- `tools/qa_orphan_hotspot_visuals.py` GREEN (assembler hotspot Visual ownership)
- Landmark StyleQA: reed/ruin/grave/boat/door_facade/awning repainted to painted-grade uniq colors (`qa_landmark_style` GREEN)
- C62 full-chain headless smoke PASS (forest→cave→waterfall→lake); cave/museum/station/lighthouse/mine/tree/ruins/cemetery/inn MCP idles added 2026-09-13

## Agent reviews this batch

- GenreQA + CanonQA: **PASS** (code) — [Review](6cdb8564-9291-4ed2-8feb-c26216bd21df)
- AnimQA mayor/miller: mayor PASS; miller foot_y=55 gap=0（与 farmer/mayor 对齐；旧“foot_y=55 disputed”关闭）
- Work poses repainted from farmer walk + occupational recolor/tool stamp；uniq≈250–325；`qa_work_pose_style` floor uniq≥80

## Still required for Goal complete

User Godot QA §7 **用户勾选** (visual fidelity / Waves A2–F) — Agent MCP 列不等于用户手感签收。
