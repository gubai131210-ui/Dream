# Formulas (village scale)

Use these in assemblers / Python tools. Prefer village-scale meander over full hydrology.

## Meander centerline (current Dream style)

```text
cx(ty) = base + A1*sin(ty*w1) + A2*cos(ty*w2 + p) + A3*sin(ty*w3)
hw(ty) = h0 + B1*sin(ty*u1 + q) + B2*cos(ty*u2)
water(tx,ty) = |tx - cx(ty)| <= hw(ty)
             OR soft cove: |tx-cx| <= hw+ε AND noise/sin > thresh
```

Vary amplitudes so the channel is not a pure sinusoid stripe.

## Bearing + 1D noise (alternate)

```text
across' = across - meanderAmp * (noise1D(along) - 0.5)
water = abs(across') < halfWidth(along)
```

## Bank ring

```text
bank = !water && any_8_neighbor(water) && !path
→ paint damp
```

## Path distance field (ecology)

BFS from all path cells → `dpath`.  
Example mapping:

| Condition | Grass kind |
| --- | --- |
| bank / water neighbor | damp |
| dpath ≤ 2 | mowed |
| map edge ≤ 2 or dpath ≥ 8 | tall |
| rare RNG | weed |
| else | meadow |

## Bridge span (from ACNH craft)

```text
river_width in [3,5] tiles preferred for a proper bridge
anchors: parallel free strips on both banks (≈4 long × 1 deep)
hoppable streams: width 1–2 (no full bridge required)
```

Dream may approximate with a short path band over water; prefer a bridge prop when art exists.

## Bitmask (transitions)

```text
# 4-bit edges
mask = N + 2*E + 4*S + 8*W
# 8-bit blob: clear diagonal unless both adjacent cardinals set
```

## Y-sort key

```text
sort_y = foot_y   # contact point, not sprite center
# buildings: use south edge of footprint
```

## Building sprite AABB (LOCKED — see docs/BUILDING_PLACEMENT.md)

```text
offset = (0, -height * 0.35)          # AreaCraft.BUILDING_Y_OFFSET_FACTOR
AABB   = Rect(foot + offset - size/2, size)
sprite_top_y ≈ foot_y - 0.85 * height

# Must hold:
AABB ⊆ BUILD_ZONE
# Farm: BUILD_ZONE = FARM_BUILD_ZONE (inset past fence), NOT FARM_ZONE
# Unfenced: BUILD_ZONE = map_play_rect(margin_tiles)

# Door dirt: paint south of foot tiles (clear of half_h), or allow_path=true for buildings
```

Place with `AreaCraft.find_building_inside(...)`. Never foot-only.

## Drainage (only large maps)

Red Blob mapgen4: downslope queue → moisture → flow accumulation → width ∝ log(flow).  
Village squares: skip unless designing a whole region map.

## Sources

- https://www.redblobgames.com/maps/mapgen4/
- https://www.redblobgames.com/x/1723-procedural-river-growing/
- `docs/research/practitioners/engineers-tilemap-terrain.md`
