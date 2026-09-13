# Prop orientation & scale (Dream)

**Status:** LOCKED  
**Date:** 2026-09-10  
**Locks:** `SCALE.md`, `MARKET_POLISH.md`, `realistic-scene-craft`

## Barrel orientation

| Asset | Pose | Default use |
|---|---|---|
| `barrel_1.png` | **Upright** storage / water / yard | **Default everywhere** |
| `barrel_0.png` | Horizontal keg on stand + tap | **Specialty only** — market wine/stall dressing, tavern-like alcoves |

**Rule:** Assemblers must not place `barrel_0` as a generic “木桶”. Prefer `barrel_1` titled 木桶/水桶/站台桶. Keep `barrel_0` titles as 横酒桶 / 酒桶 when used.

## Small prop display scale

Native B11/AI props are often ~150–230 px tall. Unscaled they read as half-house.

| Kind | Display scale (Sprite2D) | Approx height vs `CHARACTER_HEIGHT_PX` (56) |
|---|---|---|
| Sack / crate / upright barrel / lamp / bench | **0.45–0.55** | ≤ ~½–¾ person |
| Shoreline “yard rock” (`rock_01` etc.) | **0.28–0.35** | ~½ person; not cottage-tall |
| Stall shelf goods | ≤ **0.50** (`MARKET_POLISH.md`) | Never block awning face |

**Forbidden:** spawn small props at scale `1.0` after `spawn_sprite`.

## Rock + tree blend

- Keep shoreline boulders when they serve as pond/river bank anchors.
- Scale to ~half character height; always `add_contact_shadow`.
- **No tree crown/trunk AABB overlap** with rock AABB — nudge rock or tree ideals first.
- Prefer smaller `rock_0x` variants for yard scatter; reserve large native rocks for scaled landmarks.

### Rock biome families (`RockCatalog`)

Paths: `assets/sprites/props/rocks/{family}/rock_XX.png`, with **fallback** to legacy `props/rock_0X.png` when a family file is missing.

| Family | Use | Target height helper |
|---|---|---|
| `forest_moss` | Default / woodland yard (legacy `rock_00`–`rock_05`) | — |
| `coastal` | Beach / lighthouse / dock banks | `TARGET_H_SHORE` (22) |
| `terrace` | Hill-farm terrace lip markers | `TARGET_H_TERRACE` (24) |
| `cobble` | Plaza / lane scatter pebbles | `TARGET_H_COBBLE` (16) |
| `river_bank` | Stream / pond / waterfall shore clusters | `TARGET_H_SHORE` (22) |

Use `RockCatalog.scale_for_target_h(tex, target_h)` instead of hard-coded giant scales. Terrace lips stay **0.28–0.32**; shore clusters target **18–28 px** tall.

## Crop bed visuals

- **Forbidden:** opaque green/yellow `ColorRect` slabs covering beds (they hide animals/path/water).
- Prefer dirt furrows (thin lines, α≤0.35) or future B12 crop sprites via `AreaCraft.spawn_crop_rows`.

## Animals (B13)

| Species in pack | Status |
|---|---|
| sheep / deer / cat / cow / dog | Sliced → `assets/sprites/animals/{id}/` + `AmbientCritter` |
| chicken / bird | **Missing from B13 sheets** — do not fake; import new sheets before farm poultry denser than cats |

`AmbientCritter` normalizes display height vs NPC (`CHARACTER_HEIGHT_PX` ≈ 56):

| Species | Target height px |
|---|---|
| cat | 20 |
| dog | 28 |
| sheep | 32 |
| deer | 40 |
| cow | 42 |

Never pass raw scale ~0.4–0.5 on native 150–260px frames (that makes livestock taller than people).

## Trees: island vs grounded

| Variant | Path | Use |
|---|---|---|
| Island (water + baked rocks) | `sprites/trees/tree_XX.png` | Lake / river / waterfall banks only |
| Grounded (trunk + grass mound) | `sprites/trees/grounded/tree_XX.png` | Farm home, farmland, residential inland |

Tool: `tools/crop_tree_bases.py`. Do not place separate giant `rock_01` under island trees.

## Shore rocks (separate props)

- Prefer `river_bank` / `forest_moss` `rock_02`–`rock_05` clusters at **target height 18–28 px** (scale from native ~180–200px via `RockCatalog.TARGET_H_SHORE`).
- Always contact shadow; never overlap tree AABB.
- Match district: farm/residential = small bank pebbles (`cobble` / small moss); wild water edges may keep island trees instead of fake rocks.
- Assemblers: resolve paths through `RockCatalog.path(family, index)` so missing family art falls back cleanly.
