# Scene layout rules (Village Square)

Reference: A09 — meandering west river, plaza-centered buildings, trees on land only.  
Skill: `.cursor/skills/realistic-scene-craft/`.

## Hard rules

1. **Water** is a meandering mask (sine/cove), not a straight rectangle. Corridor aims for ~3–5 tile width.
2. **Bank grass** uses `damp` tiles on cells that touch water.
3. **No trees in water / on stone or dirt walks.** Footprint AABB check.
4. **West road** stops before the river; **bridge band** at `ty=14–15` spans water with ±1 land anchors (ACNH-like 3–5 width).
5. **Buildings** south-facing art → lots **north of plaza**; doors toward civic space.
6. **Door spurs**: dirt tiles (`dirt_seamless_atlas`) from plaza/arms to door aprons.
7. **Props**: civic on plaza; yard props on plantable grass only.
8. **NPCs**: sparse waypoint loops on walk surfaces (stone preferred); contact shadows at feet.
9. **Water overlay**: atlas frame shimmer on water cells only (not under bridge deck).

## Pass order

masks → ecological grass → dirt spurs → water → stone path → buildings → props → bridge hotspot → trees → actors → water overlay

## Forbidden shortcuts (anti-lazy)

- Straight `Rect2i` river
- Trees without `_footprint_ok`
- Random building yaw without matching door art
- Slap-on scatter without plaza-relative slots
- NPC roam off the walk graph

## Rebuild terrain art

```powershell
python dream/tools/make_seamless_terrain.py
```
