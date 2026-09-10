# Practitioners: district spatial grammar

**Scope:** How level / environment craft separates plaza, residential, farm, market — spatial parameters, not genre labels.  
**Dream lock:** [`AREA_FRAMEWORK.md`](../../AREA_FRAMEWORK.md).  
**Companions:** [`engineers-zone-richness.md`](engineers-zone-richness.md), game notes under `../games/`.

---

## 1. Spatial parameter table (synthesis)

Units relative; Dream absolute tiles in `AREA_FRAMEWORK.md`.

| Param | Plaza / civic | Residential | Farm home | Farmland / fields | Market / high street |
| --- | --- | --- | --- | --- | --- |
| Openness | Highest hardscape void | Medium (yards) | Medium yard + fence | Highest soft (plots) | Linear void (street) |
| Path width | Widest | Narrow lanes | Medium dirt | Narrow berms + bridges | Wide street, narrow alleys |
| Building density | Low–med, large anchors | Highest roof count | Low (1–3 + pens) | Minimal sheds | Medium shop fronts |
| Vegetation | Sparse inside; banks | Yard trees | Orchard points | Edge forest only | Sparse street trees |
| Water role | Edge corridor / fountain | Pocket pond | Yard pond | Irrigation meander | Optional edge only |
| Anchors | Well, hall, church lot | Lane lamps, pocket | House door, coop | Shed, plot labels | Stall line, shop doors |

Sources informing table:

- Center dense → farms outward; major paths wider — [Minecraft ACO villages PDF](https://ir.cwi.nl/pub/35899/35899.pdf)
- Curve roads; vary width; fields near outskirts houses — [Ostriv settlement guide](https://gameplay.tips/guides/8156-ostriv.html)
- Village skeleton seeds + roads — [Galin et al. 2012](https://perso.liris.cnrs.fr/egalin/Articles/2012-villages.pdf)
- FoMT Rose Plaza vs farm tillable — [`../games/story-of-seasons.md`](../games/story-of-seasons.md)
- Garden Lane buffer farm↔town — [`../games/coral-island.md`](../games/coral-island.md)
- Dual plaza + main spine — [`../games/my-time-at-portia.md`](../games/my-time-at-portia.md)
- Named corridors off square — [`../games/rune-factory-4.md`](../games/rune-factory-4.md)
- Plaza hub + spoke biomes — [`../games/dreamlight-valley.md`](../games/dreamlight-valley.md)

---

## 2. Anti-monotony

| Technique | Practice |
| --- | --- |
| Rhythm | Alternate open (plaza/field) and dense (housing/stalls) |
| Material contrast | Stone % vs dirt % vs grass % must differ by district |
| Frequency | Few large roofs (plaza) vs many medium (residential) vs crop rectangles (farmland) |
| Path hierarchy | ≥2 widths in any multi-block village |
| Negative space | Portia-style intentional low-traffic Park — do not fill every void |
| Buffer belts | Coral Garden Lane — farm not glued to civic stone |

---

## 3. Reality-consistent simplifications (games-scale)

| Real cue | Game simplification |
| --- | --- |
| Doors face street | Fixed art facing + lot north of path |
| Drainage / rivers | Meander mask + bank damp (not full hydrology at village scale) |
| Walkability | NPC graph on preferred surfaces |
| Sun / aspect | One light quadrant for whole art set |
| Parcel setbacks | Build zone inset + footprint AABB |

---

## 4. TileMap checklist

- [ ] `district_id` documented in assembler header  
- [ ] Path material + width match framework table  
- [ ] Water role match (corridor / pond / irrigation / none)  
- [ ] Density / openness match silhouette test  
- [ ] Ecology thresholds from zone profile (not plaza defaults everywhere)  
- [ ] Anchors named (well, stalls, shed…)  
- [ ] Buffer or portal to neighboring district typed correctly  

---

## 5. Confidence notes

- Exact tile widths in published games are often **observed**, not official specs — Dream locks its own numbers in `AREA_FRAMEWORK.md`.  
- 3D titles (Portia, DDV, RF4) contribute **topology**, not pixel recipes.  
