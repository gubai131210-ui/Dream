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
**Default plaza mapping:**

| Condition | Grass kind |
| --- | --- |
| bank / water neighbor | damp |
| dpath ≤ 2 | mowed |
| map edge ≤ 2 or dpath ≥ 8 | tall |
| rare RNG | weed |
| else | meadow |

### Zone profiles (district-weighted)

Tune thresholds so districts do not share one grass look (`AREA_FRAMEWORK.md`):

| District | mowed if | tall if | notes |
| --- | --- | --- | --- |
| plaza | dpath ≤ 2 | dpath ≥ 8 or edge | stone-adjacent short grass |
| residential | dpath ≤ 1 (lanes only) | edge ≤ 2 | yards stay meadow |
| farm_home | dpath ≤ 1 | rare | more weed RNG (~3%) |
| farmland | dpath ≤ 1 on hub rings | outside play | crop beds = dirt cells, not grass |
| market | dpath ≤ 2 on street | avoid inside stall band | keep street readable |

## Poisson-ish props (anti-clump)

```text
# Reject candidate if distance to existing prop < r_min (tiles)
# plaza civic r_min ≈ 3; residential yard r_min ≈ 2; market stalls along line spacing ≈ 2–3
```

## Crop bed grid (farmland)

```text
beds = axis-aligned Rect2i array
gap ≥ 1 tile dirt/path between beds
no bed ∩ water; no bed ∩ building AABB
```

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

Red Blob mapgen4: downslope queue → moisture → flow accumulation → width ∝ log(flow) / Strahler-like thickness.  
Village squares: prefer sine/noise meander (`cx(ty)` above). Full drainage only for continent-scale maps.

## Sources

- https://www.redblobgames.com/maps/mapgen4/
- https://www.redblobgames.com/x/1723-procedural-river-growing/
- https://ir.cwi.nl/pub/35899/35899.pdf (path hierarchy / center density)
- `docs/research/practitioners/engineers-tilemap-terrain.md`
- `docs/research/practitioners/engineers-zone-richness.md`
- `docs/AREA_FRAMEWORK.md`
