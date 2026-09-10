# Scene layout rules (Village Square)

Reference: A09 — meandering west river, plaza-centered buildings, trees on land only.  
Skill: `.cursor/skills/realistic-scene-craft/`.  
**Buildings (all areas):** [`BUILDING_PLACEMENT.md`](BUILDING_PLACEMENT.md) — full sprite AABB must stay inside the play/farm **build** zone.

## Hard rules

1. **Water** is a meandering mask (sine/cove), not a straight rectangle. Corridor aims for ~3–5 tile width.
2. **Bank grass** uses `damp` tiles on cells that touch water.
3. **No trees in water / on stone or dirt walks.** Footprint AABB check.
4. **West road** stops before the river; **bridge band** at `ty=14–15` spans water with ±1 land anchors (ACNH-like 3–5 width).
5. Buildings use south-facing art → lots **north of plaza**; doors toward civic space.
6. **Full building sprite AABB** inside play/farm build zone — see [`BUILDING_PLACEMENT.md`](BUILDING_PLACEMENT.md). Never foot-only placement; fenced scenes use an inset past the fence, not the fence line itself.
7. **Door spurs**: dirt south of building footprints (`dirt_seamless_atlas`); do not paint aprons under feet then reject dirt in footprint search.
8. **Props**: civic on plaza; yard props on plantable grass only (yard props also ⊆ build/play zone when fenced).
9. **NPCs**: sparse waypoint loops on walk surfaces (stone preferred); contact shadows at feet.
10. **Water overlay**: atlas frame shimmer on water cells only (not under bridge deck).

## Pass order

masks → ecological grass → dirt spurs → water → stone path → buildings → props → bridge hotspot → trees → actors → water overlay

## Forbidden shortcuts (anti-lazy)

- Straight `Rect2i` river
- Trees without `_footprint_ok`
- Random building yaw without matching door art
- Slap-on scatter without plaza-relative slots
- NPC roam off the walk graph
- Building foot inside zone while roof straddles fence/map edge
- Using outer `FARM_ZONE` as building containment instead of inset `FARM_BUILD_ZONE`

## Rebuild terrain art

```powershell
python dream/tools/make_seamless_terrain.py
```
