# World C58–C62 — 交互 / 破坏 / 进度门 / 隐藏箱 / 密道链

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C58–C62, [`ENV_H.md`](./ENV_H.md)  
**Owns:** `scripts/world/**`, thin outdoor controller mounts, cave secret hop via `InteriorRoomController`  
**Does not:** CivicTour / TransitDive profiles; festival megamap; popup of all systems

---

## Counts delivered

| ID | Min | Delivered | Live hooks |
| --- | --- | --- | --- |
| C58 | ≥8 interact types | **8** | plaza hotspots + **prop sprites** + pulse/FX |
| C59 | ≥4 clearable | **4** | plaza click-remove + prop sprites + **clear debris FX** |
| C60 | ≥3 progress gates | **3** | plaza unlock stub + prop sprites |
| C61 | ≥5 hidden chests | **5** | square / forest / waterfall / hill / lake + **chest_lid** + `mcp_open` |
| C62 | ≥1 chain ≥2 outdoor | **1** (3 hops) | forest → cave → waterfall → lake |

## C58 interact types (plaza)

| id | Title | Action | Visual |
| --- | --- | --- | --- |
| sit_bench | 长椅 | Info + pulse + `bench_dust`×4 | `bench_0.png` |
| well_water | 井水 | Info + pulse + `well_rope`×4 | `well_0.png` |
| shake_tree | 摇树 | Info + `leaf_fall`×4 | `trees/grounded/tree_00` |
| notice_board | 公告栏 | Info + pulse + `board_rustle`×4 | `B11-06_mailbox_board_02` |
| crate_search | 木箱 | Info + pulse + `crate_lid`×4 | `crate_1.png` |
| lamp_toggle | 路灯 | Toggle light + modulate | `lamp_0.png` + PointLight2D |
| feed_critter | 喂鸟 | Info + `bird_peck`×4 | `sack_0.png` |
| read_sign | 路牌 | Info + pulse + `board_rustle`×4 | `B11-06_mailbox_board_00` |

District hosts (`DistrictInteractKit`) reuse the same FX sheets by interact id keywords (bench/sign/crate/hay/…).

Art pass tracked in [`GOAL_INTERACT_COMPLETE.md`](./GOAL_INTERACT_COMPLETE.md).

## C59 breakables (plaza)

| id | Title | Clear |
| --- | --- | --- |
| rock | 碎石堆 | click → `queue_free` |
| stake | 木桩 | click → remove |
| weed | 杂草丛 | click → remove |
| crate | 破箱 | click → remove |

## C60 progress gates (plaza)

| id | Title | Unlock stub |
| --- | --- | --- |
| fallen_log | 倒木 | click → unlocked flag + visual soften |
| boulder | 巨石 | click → unlocked |
| locked_door | 锁门 | click → unlocked |

## C61 hidden chests

| site_id | Host scene | Approx pos |
| --- | --- | --- |
| well | village_square | (700, 500) |
| tree_behind | forest_deep | (560, 520) |
| waterfall | waterfall | (700, 420) |
| cave | hill_farm (洞口) | (980, 320) |
| island | lake | (900, 620) |

Optional sprite: `coin_chest_00.png` when present.

## C62 secret chain path

```
深林 forest_deep  「树洞密道」
        ↓
洞穴入口 c16_cave_entry  「暗河出口」
        ↓
瀑布 waterfall  「瀑后回湖」
        ↓
湖泊 lake
```

All hops are real `scene_path` portals (clickable). Cave hop is mounted by `SecretPassageChain.try_attach_interior` from `InteriorRoomController` (append-only; no CivicTour/TransitDive profile edit).

## How to toggle / QA

1. **广场** (`village_square.tscn`)
   - Season: TopBar 春花… / **S**（真 prop 簇）
   - Click ≥8 WorldInteract **props**；clear ≥4 breakables；unlock ≥3 gates；open 井边宝箱
   - 传送门应见常显门阶/拱门 cue（无需开 debug 菱形）
2. **密道链**
   - Hub → 深林 → click **树洞密道** → 洞穴 → **暗河出口** → 瀑布 → **瀑后回湖** → 湖泊
3. **隐藏箱**
   - 深林树后 / 瀑布帘后 / 山丘洞口 / 广场井边 / 湖岛岸 — click each chest once

No world-debug popup layer: systems are in-world hotspots only (+ season TopBar).

## Files

| Path | Role |
| --- | --- |
| `scripts/world/world_spawn_util.gd` | Shared hotspot/portal makers |
| `scripts/world/world_interact_kit.gd` | C58 |
| `scripts/world/breakables_kit.gd` | C59 |
| `scripts/world/progress_gates.gd` | C60 |
| `scripts/world/hidden_chests.gd` | C61 |
| `scripts/world/secret_passage_chain.gd` | C62 |
| `scripts/areas/village_square_controller.gd` | C55+C58–C61 mount |
| `scripts/areas/forest_deep_controller.gd` | C61+C62 |
| `scripts/areas/waterfall_controller.gd` | C61+C62 |
| `scripts/areas/lake_controller.gd` | C61 |
| `scripts/areas/hill_farm_controller.gd` | C61 cave site |
| `scripts/interiors/interior_room_controller.gd` | C62 cave hop thin attach |
| `docs/WORLD_C58_C62.md` | This package |

## Desk acceptance

| ID | Check | Result |
| --- | --- | --- |
| C58 | ≥8 pickable types on square | **PASS** (8) |
| C59 | ≥4 clearable | **PASS** (4) |
| C60 | ≥3 unlockable gates | **PASS** (3) |
| C61 | ≥5 chest sites across maps | **PASS** (5) |
| C62 | complete chain ≥2 outdoor | **PASS** (forest↔waterfall↔lake + cave hop) |
| UI | no 「占位」 | **PASS** |
| UX | no all-systems popup | **PASS** |

```
System QA (C58–C62): PASS (desk) — user Godot path pending
Live hotspots/portals on square + explore hosts; secret chain forest→cave→waterfall→lake
```

## 禁止偷懒

1. 禁止 C58–C62 只列清单无场景可点可走钩子  
2. 禁止门/密道只有 InfoPanel、无 `scene_path`  
3. 禁止改 CivicTour / TransitDive profiles  
4. 禁止把世界系统堆成弹层  
5. 禁止 UI 「占位」  
6. 禁止未写 desk 验收表就标 DONE  

## Acceptance checklist

- [x] C58 8 live interacts  
- [x] C59 4 clearables  
- [x] C60 3 unlock stubs  
- [x] C61 5 sites wired  
- [x] C62 real portal chain  
- [x] Docs + desk tables  
- [ ] User Godot walk of chain + plaza clicks  
