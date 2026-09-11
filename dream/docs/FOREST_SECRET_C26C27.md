# ForestSecret C26 / C27 — waterfall cave + deep-forest hides

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**Locks:** [`PHASE5_WAVE_A2.md`](./PHASE5_WAVE_A2.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Outdoor hosts:** A07 `waterfall_assembler`, A05 `forest_deep_assembler` (portal **append only**)

## Goal

| ID | Place | Enter from | Return |
| --- | --- | --- | --- |
| **C26** | 瀑后洞窟（水幕→洞→遗迹宝箱） | A07 west overlook | TopBar + south door → waterfall |
| **C27A** | 猎人隐所 | A05 trail bend pocket | → forest_deep |
| **C27B** | 蘑菇窝棚 | A05 trail bend pocket | → forest_deep |

Acceptance (Wave A2 Forest): **cave + ≥2 forest secrets**, each with `scene_path` portal (not InfoPanel-only) and interior return.

## SceneRouter (pre-seeded — do not reorder)

```
C26_WATERFALL_CAVE_PATH → res://scenes/interiors/c26_waterfall_cave/c26_waterfall_cave.tscn
C27_FOREST_HIDE_A_PATH  → res://scenes/interiors/c27_forest_hide_a/c27_forest_hide_a.tscn
C27_FOREST_HIDE_B_PATH  → res://scenes/interiors/c27_forest_hide_b/c27_forest_hide_b.tscn
```

Scenes are InteriorProfiles + InteriorCraft stubs (`profile_id` wired). Enrichment is **profile-only** for these three keys.

## Outdoor portal positions

| Portal | Assembler | Tile | World (BASE_TILE=32) | Label |
| --- | --- | --- | --- | --- |
| C26 cave | `waterfall_assembler` | `(11, 12)` | `(368, 400)` | 进入瀑后洞窟 |
| C27A hunter | `forest_deep_assembler` | `(12, 10)` | `(400, 336)` | 进入猎人隐所 |
| C27B mushroom | `forest_deep_assembler` | `(22, 18)` | `(720, 592)` | 进入蘑菇窝棚 |

- **C26** sits on the **west overlook dirt spur** (tx 10–11), west of the fall column / pool — reads as “behind / beside the curtain,” not a road through the cascade.  
- **C27A/B** sit on existing **bend dirt pockets** from `_paint_winding_dirt` — no canopy wipe, no new clearing plaza.

## Interior profiles (functional clusters)

### `c26_waterfall_cave`

| Cluster | Anchor | Verb |
| --- | --- | --- |
| `drip_ledge` | (5, 7) | Wet entry — rocks, drip barrel, damp sack |
| `relic` | (17, 5) | Primary — coin chest + rock plinth |
| `wet_cache` | (20, 10) | East spare crates / probe rack |

Door mid **10–13** kept clear; cool stone modulate; no window.

### `c27_forest_hide_a` (猎人隐所)

| Cluster | Anchor | Verb |
| --- | --- | --- |
| `camp` | (4, 6) | Hay bedroll + lamp |
| `hunt_gear` | (15, 6) | Tool rack + game crates + ledger |
| `dry` | (15, 11) | Herbs / basket dry corner |

Actor: 隐林猎人 patrols `camp` ↔ `hunt_gear` (south approach stands).

### `c27_forest_hide_b` (蘑菇窝棚)

| Cluster | Anchor | Verb |
| --- | --- | --- |
| `forage` | (4, 5) | Twin mushroom baskets + sort stool |
| `apothecary` | (13, 5) | Herbs, medicine, shelf |

## Ownership / files touched

| Path | Role |
| --- | --- |
| `scripts/interiors/interior_profiles.gd` | Enrich **only** `c26_waterfall_cave`, `c27_forest_hide_a`, `c27_forest_hide_b` |
| `scenes/interiors/c26_waterfall_cave/**` | Stub scene (unchanged structure) |
| `scenes/interiors/c27_forest_hide_a/**` | Stub scene |
| `scenes/interiors/c27_forest_hide_b/**` | Stub scene |
| `scripts/areas/waterfall_assembler.gd` | Append C26 portal |
| `scripts/areas/forest_deep_assembler.gd` | Append C27A + C27B portals |
| `docs/FOREST_SECRET_C26C27.md` | This package doc |

**Not owned:** Env canopy long-term work; C01–C04 interiors; `scene_router.gd` constant order.

## 禁止偷懒

1. 禁止门/瀑后/树洞只有 InfoPanel、无 `scene_path`  
2. 禁止室内无返回（TopBar + south portal）  
3. 禁止大改瀑布/深林室外剪影（只 append portal）  
4. 禁止改 C01–C04 profile / 踢脚线抛光  
5. 禁止抢改 Env 树冠长期方案  
6. 禁止棋盘格地板 / 整屋橙色洗色  
7. 禁止单簇 junk 堆满、堵死门轴中廊  
8. 禁止未写本包 MD 就声称 DONE  
9. 禁止用户中文路径下强跑易损 Godot CLI；交付后由用户本地测  

## Demo checklist (user Godot)

1. Hub → 瀑布 → west overlook **进入瀑后洞窟** → 宝箱簇可读 → 返回室外 / Hub  
2. Hub → 深林 → bend **进入猎人隐所** → 猎人巡逻 → 返回深林  
3. 同图 **进入蘑菇窝棚** → 双篮+药架 → 返回深林  
4. 瀑布剪影仍是竖瀑+潭；深林仍是密冠+蜿蜒土径（无新广场）  
