# Goal — Agent §7 walkthrough (does not replace user)

**Date:** 2026-09-13 (extended)  
**Note:** Runtime probes only. User must still confirm hand-feel via「§7验收」and reply「§7 已勾」.

| Checklist id | Probe | Result |
| --- | --- | --- |
| square C58 | `mcp_spawn_c58_fx(shake_tree)` | ok, FX_leaf_fall frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(well_water)` | ok, FX_well_rope frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(crate_search)` | ok, FX_crate_lid frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(feed_critter)` | ok, FX_bird_peck frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(sit_bench)` | ok, FX_bench_dust frames=4 playing |
| square C58 | `mcp_spawn_c58_fx(notice_board)` / `read_sign` | ok, FX_board_rustle frames=4; `g8_c58_board_rustle_live.png` |
| square outdoor | hover `WorldHS_木箱` → AreaInteractHost | target=crate; `ProximityPrompt` text「互动」visible; `g8_walkthrough_outdoor_prompt.png` |
| square C59 | `BreakablesKit.mcp_clear(weed)` | ok, cleared=1 |
| square C60 | `ProgressGates.mcp_unlock(locked_door)` | ok, sprite_alpha≈0.45 |
| river cage | `FishCage.mcp_cycle_to_ready` | ok, phase=ready, full sprite |
| lake cage | `FishCage_lake_east_dock_cage.mcp_cycle_to_ready` | ok, phase=ready, title「可收」, full sprite |
| waterfall | `WaterfallAnim.is_playing` | true, animation=fall |
| C01 | `mcp_play_open_fx(衣柜)` | ok, OpenFX_drawer_open frames=4 |
| C02 | `mcp_play_open_fx(钱箱)` | ok, OpenFX_chest_lid frames=4 |
| C62 | forest_deep `WorldPortal_树洞密道` | secret_chain=true; facade Sprite2D; to c16; `g8_walkthrough_c62_portal.png` + prior chain smoke PASS |
| district FX | market `mcp_spawn_fx(mkt_crate_stack)` + forest `fent_sign` | crate_lid / board_rustle frames=4; `g8_district_market_crate_fx.png` |
| C59 clear FX | `mcp_clear(rock/crate)` | leaf_fall / crate_lid then free; `g8_c59_crate_clear_fx.png` |
| C61 well chest | `HiddenChests_well.mcp_open` | ChestLidFX frames=4; `g8_c61_well_chest_open.png` |
| C60 unlock FX | `mcp_unlock` door/log/boulder | board_rustle / leaf_fall / bench_dust; `g8_c60_unlock_fx_door.png` |
| C61 all sites | tree/waterfall/cave/island `mcp_open` + shots | 5/5 lids; smoke `g8_c61_chests_smoke.gd` |
| C05 stall cycle | `MarketStall.mcp_cycle` | crate_lid/board_rustle/leaf_fall; `g8_c05_stall_cycle_fx.png` |
| integer zoom | plaza `CameraController.zoom=(1,1)` + `cycle_work_ring` | `g8_square_zoom1_work_pose_v3.png`；顶栏「工作:打铁环」 |
| lighthouse / hill_farm / lake_house | runtime idle + DistrictInteractKit | shots `g8_walkthrough_lighthouse_idle` / `hill_farm_idle` / `lake_house_idle` |
| §7 checklist UI | `user_qa_checklist.tscn` | **21** rows（户外全表+室内抽样）；复制「§7 已勾」；`g8_user_qa_checklist_v2.png` |
| portals D/E | prior `g8_wave_de_portal_smoke` + live enter | PASS (separate evidence) |

**QA re-run (this extend):** `qa_no_placeholder_visuals` / `qa_interact_sprite_inventory` / `qa_interaction_frames` / `qa_orphan_hotspot_visuals` / `qa_portal_hover_only` / `qa_semantic_interior_props` → all **GREEN**.

Still open: user visual/hand-feel confirmation (§7).
