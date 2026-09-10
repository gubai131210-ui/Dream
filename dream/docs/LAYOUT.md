# Scene layout rules (Village Square)

Reference: A09 overall art — meandering west river, plaza-centered buildings, trees on land only.

## Hard rules

1. **Water** is a meandering mask (sine/cove), not a straight rectangle.
2. **Bank grass** uses `damp` tiles (mud/reed-tinted) on cells that touch water.
3. **No trees in water.** No trees on stone plaza/roads. Footprint check covers a small ground AABB, not only the stem tile.
4. **West road stops before the river**, with a short bridge band across.
5. **Buildings** use south-facing art → prefer lots **north of the plaza** so doors face the square; never place main houses south with backs to the plaza. Multi-tile footprint must clear water and stone.
6. **Props**: civic items may sit on plaza; sacks/yards stay on plantable grass.

## Forbidden shortcuts (anti-lazy)

- Do not paint a straight `Rect2i` river.
- Do not put trees by “looks empty” without `_footprint_ok`.
- Do not rotate buildings randomly without matching door art.
- Do not pile all content into one slap-on scatter list without plaza-relative slots.

## Rebuild terrain art

```powershell
python dream/tools/make_seamless_terrain.py
```
