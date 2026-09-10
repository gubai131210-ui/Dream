# Building placement — full sprite inside zone

**Status:** LOCKED  
**Date:** 2026-09-10  
**Applies to:** All area assemblers (square, residential, farm, future scenes)  
**Code:** `scripts/areas/area_craft.gd` (`building_offset_for`, `sprite_world_rect`, `sprite_fully_inside`, `find_building_inside`, `map_play_rect`)  
**Skill:** `.cursor/skills/realistic-scene-craft/`

This is a hard layout lock. Agents must not place buildings by foot tile alone.

---

## Problem (what went wrong)

Cottage sprites are tall (often **160–224 px**). Assemblers used to:

1. Put the **foot** (sprite origin) inside a zone / north of a plaza, and  
2. Only clear a small **tile footprint** (`half_w` / `half_h`).

With `offset.y = -height * 0.35`, most of the art hangs **above** the foot. Roofs and backs then:

- Stick out past the **map top**
- Straddle a **farm fence** (half in yard, half in forest belt)
- Look “only partly in the farm / residential area”

**Rule of thumb:** if the roof can leave the play/farmyard visually, the placement is wrong — even when the foot is “inside.”

---

## Locked rule

**The full sprite world AABB must lie strictly inside the area’s build/play zone.**

- Footprint tile check is still required (no water under the lot).  
- Footprint alone is **not** enough.  
- For fenced yards: zone = **inside the fence**, not the outer forest/map rect that the fence sits on.

---

## Math (must use)

Current building draw offset:

```text
offset = (0, -height * 0.35)     # AreaCraft.BUILDING_Y_OFFSET_FACTOR
AABB top-left = foot + offset - size/2
AABB size     = (width, height)
```

Useful roof estimate (same factor):

```text
sprite_top_y ≈ foot_y - 0.85 * height
```

Example: `height = 224`, `foot_y = 288` → `top ≈ 97.6`.  
If the north fence is at `y = 104`, that cottage **straddles** the fence. Raise the foot (or inset the build zone) until `sprite_top_y` is south of the fence / zone top with margin.

Measured building sheets (px):

| Asset | Size |
| --- | --- |
| `building_00` | 174×160 |
| `building_01` | 103×160 |
| `building_02` | 125×160 |
| `building_03` | 201×224 |
| `building_04` | 208×224 |

Always load the texture and use real `get_width()` / `get_height()` — do not hardcode these forever.

---

## Solution (required API)

Use `AreaCraft` helpers; do not reinvent a center-only check.

| Helper | Role |
| --- | --- |
| `building_offset_for(tex)` | Same offset as runtime sprites |
| `sprite_world_rect(pos, tex, offset)` | Full AABB in world space |
| `sprite_fully_inside(pos, tex, offset, zone)` | AABB ⊆ `zone` |
| `find_building_inside(ideal, tex, offset, zone, hw, hh, …)` | Search: clear footprint **and** full AABB inside zone |
| `map_play_rect(margin_tiles)` | Default map inset for unfenced scenes |

Placement loop pattern:

```gdscript
var offset := craft.building_offset_for(tex)
var cleared := craft.find_building_inside(
	ideal, tex, offset, BUILD_ZONE, half_w, half_h, 16, allow_dirt_or_path
)
if cleared == Vector2.ZERO:
	push_warning("… could not place fully inside zone")
	continue  # never place outside
```

---

## Zones by scene type

| Scene | Zone to pass into `find_building_inside` | Notes |
| --- | --- | --- |
| Village square | `craft.map_play_rect(1.5)` (or similar) | Keep tall north lots south enough that roofs clear map top |
| Village residential | `PLAY_ZONE` inset from map edge | Same roof clearance for north row |
| Farm residential | **`FARM_BUILD_ZONE`**, not bare `FARM_ZONE` | Fence hugs `FARM_ZONE ± ~8px`; build zone must inset **past posts** (e.g. +32px) so roofs stay inside the yard |

Props that belong “in the yard” should use the same build/play zone (`sprite_fully_inside`), not only a tile footprint.

---

## Dirt / door lane conflict (second bug)

Door dirt aprons painted **under** the building footprint make `footprint_ok(..., allow_path=false)` fail. Search then shoves the building far away (e.g. coop deep south) while still “passing” AABB.

**Do this:**

1. Paint door lanes / aprons **south of** the foot tiles (clear of `half_h` around the foot).  
2. For buildings, prefer `allow_path=true` in `find_building_inside` so intentional door dirt/stone may touch the lot; **water remains forbidden**.  
3. After changing foot Y, re-check door-lane tile indices (`DOOR_LANE_TY*`).

---

## Checklist (every new or moved building)

```
Building placement checklist:
- [ ] Ideal foot chosen for facing (south-door → north of plaza/lane)
- [ ] Zone is play rect OR fenced build inset (not outer forest belt)
- [ ] find_building_inside used with real texture + building_offset_for
- [ ] Door dirt does not cover footprint tiles (or allow_path=true for buildings)
- [ ] Tallest sheet in that slot still has margin above zone/fence top
- [ ] Visual QA: full roof/walls inside area; no straddle of fence/map edge
```

---

## Forbidden shortcuts (anti-lazy)

- Place by foot position / small `half_w`×`half_h` only  
- Treat `FARM_ZONE` (fence line) as the building containment rect  
- Paint dirt under feet then search with `allow_path=false`  
- Lower foot Y “to look more north” without recomputing `sprite_top_y`  
- Skip `push_warning` and place outside when search returns `Vector2.ZERO`

---

## Related docs

- `docs/LAYOUT.md` — scene hard rules (points here)  
- `docs/SCALE.md` — cottage height bands vs `BASE_TILE`  
- `docs/SEAMLESS.md` — terrain atlases  
- Skill formulas: `.cursor/skills/realistic-scene-craft/reference-formulas.md`
