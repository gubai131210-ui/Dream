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

## Hotspot copy encoding

- All `title` / `desc` strings in assemblers must be **UTF-8 Chinese** (or intentional English ids).
- Mojibake (`éº»è¢`, `åè`, double-encoded `Ã¨…`) is a ship blocker — rewrite the file with an editor/Write tool, not PowerShell string literals with `$`.

## Animals (B13)

| Species in pack | Status |
|---|---|
| sheep / deer / cat / cow / dog | Sliced → `assets/sprites/animals/{id}/` + `AmbientCritter` |
| chicken / bird | **Missing from B13 sheets** — do not fake; import new sheets before farm poultry denser than cats |

Ambient critters: short wander; skip water + `blocked_mask` via `AreaCraft`.
