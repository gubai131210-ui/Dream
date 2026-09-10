# Practitioners: District spatial grammar (plaza / residential / farm / market)

**Batch:** B — practitioners  
**Scope:** How level / environment designers make **plaza·civic**, **residential**, **farm / farmland**, and **market / commercial street** *read as different places* — via **space syntax** (openness, path width, density, landmarks, vegetation, water role), not gameplay genre labels.  
**Consumers:** [`AREA_FRAMEWORK.md`](../../AREA_FRAMEWORK.md), [`LAYOUT.md`](../../LAYOUT.md), realistic-scene-craft skill.  
**Method:** Primary / high-trust sources (GDC, Epic LD curriculum, peer-reviewed morphology, urban-design guidelines, environment-art pipeline interviews). Game titles appear only as *evidence of a spatial pattern*, never as a list substitute for grammar.

**Compression note (games ≠ GIS):** Real walking times and street metres must be scaled down for play. GDC 2024 (Bulavina / CDPR): a 15-minute real walk feels “close”; the same duration in-game reads as boring — design for *believable structure*, not 1:1 metres ([GDC YouTube — Urban Planning in Games](https://www.youtube.com/watch?v=Q3Scw3dzxWE); [GDC Vault](https://gdcvault.com/play/1034528/Level-Design-Summit-Urban-Planning)).

---

## 0. Shared vocabulary (before districts)

| Term | Working definition for Dream | Key sources |
| --- | --- | --- |
| **Street / path** | Directed corridor with façades (or hedges) on sides; has hierarchy (main vs spur) | Bulavina: street / square / backyard are the three core city spaces ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)); Epic: paths always lead somewhere ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)) |
| **Square / plaza / node** | Open civic room defined by surrounding frontages; congregation + orientation | Norwalk civic standards: plaza spatially defined by building frontages, mostly pavement ([ART5](https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL)); Epic: nodes = squares/parks where people gather ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)) |
| **Backyard / yard** | Semi-private negative space behind living fabric; not confused with plaza | Bulavina: backyard ≠ square ≠ street ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)) |
| **District** | Area with shared materials, massing, and land-use identity; edges + landmarks make it imageable | Lynch five elements via Epic Part 5 ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)); Lynch overview ([Kaarwan summary of Lynch](https://www.kaarwan.com/blog/architecture/kevin-lynchs-5-elements-that-shape-cities-urban-design?id=1638)) |
| **Landmark** | Local / district / far: readable at distance *and* close-up | Bulavina landmark section ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)); Epic landmark tiers ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)); Kraus / 80.lv statues + arches ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender)) |
| **Integration (Space Syntax)** | How easily a segment is reached / used for through-movement; commercial uses cluster on high-integration lines | [Space Syntax approach](https://spacesyntax.com/the-space-syntax-approach/); commercial vs residential grid differences (Hillier-tradition summary: [Space Syntax Network paper (Yumpu text)](https://www.yumpu.com/en/document/view/51490110/paper-space-syntax-network)); Seoul pedestrian–integration study ([MDPI Sustainability PDF](https://mdpi-res.com/d_attachment/sustainability/sustainability-12-08647/article_deploy/sustainability-12-08647-v2.pdf?version=1603271379)) |

---

## 1. Spatial parameter table

Relative scales for a **village-scale TileMap** (Dream ~40×30 @ 32px). Absolute real-world metres are **anchors**, then compressed. Where a cell is an author synthesis across sources, mark **[low confidence]**.

| Parameter | Plaza / civic | Residential | Farm / farmland | Market / commercial street |
| --- | --- | --- | --- | --- |
| **开敞度 (openness / positive–negative)** | **High negative space** as a *room*: one clear open core framed by façades. Epic: large unmarked fields feel “void”; a framed square is a measurable node ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)). Form-based codes: plaza primarily pavement, trees optional ([Norwalk ART5](https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL)). | **Medium–low**: pockets of yard / small green, not one big civic void. Bulavina: residential often reads via **narrower streets + back façades** vs shop fronts ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). | **Very high field openness** with **low enclosure**; positive mass = barn/house islands. Epic dissolution nodes = path dissolves into open negative space ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)). Czech village-square type: farmsteads open to square, **backyards continue into fields** ([Maňas 2025](https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf)). | **Linear openness**: long sight along street, short cross-axis. Pattern “oriented to a path” (shops along a street) ([Epic](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)). |
| **路宽 / path hierarchy** | Widest civic surfaces + feeder streets; square sits at important intersections ([Norwalk](https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL); Terrace downtown plazas at key streets ([Terrace UDP](https://www.terrace.ca/sites/default/files/docs/business-development/ocp-appendix-c-terrace_downtown_action_plan_and_urban_design_guidelines_-_final_-_9-oct-2018_low_res.pdf))). Medieval planned towns often ~**11–13 m** street width as planning module ([Chorowska et al. / Brepols chapter](https://doi.org/10.1484/m.naa-eb.5.151678)). **Game:** main ≥ secondary ≥ spur (Kraus: road size scaled by importance ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender))). | Narrower lanes; branch off main street into private quarters (Kraus ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender))). Historic village paths often **2–4 m**, main village road wider (Ogimachi: paths 2–4 m, later 6 m auto road ([WHC Shirakawa](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))). | Dirt tracks / field margins; bridges/through-routes locally wider. Farm zoning: leave path network early; separate crop vs animal zones ([Switchblade farm layout guide](https://www.switchbladegaming.com/stardew-valley/farm-layouts/) — **gameplay-derived; treat as craft heuristic [low confidence]**). | Continuous **main commercial street** wider than side alleys; stalls/doors on the wide axis. Space syntax: commerce prefers high-integration / high-choice streets ([Biskra study](https://doi.org/10.20431/2456-4931.071006); [review](https://doi.org/10.3390/su18105145)). |
| **建筑密度** | Low–medium count, **larger civic massing**; square area historically ~0.37–0.58 ha in small Warmia towns, ~7.5–10.5% of walled core ([Warmia public spaces](https://doi.org/10.3390/su12208356)). | Higher roof frequency, tighter lots; commercial grids denser/more integrated than residential grids in Space Syntax city studies ([SS network paper](https://www.yumpu.com/en/document/view/51490110/paper-space-syntax-network)). Stripe / street villages: buildings open onto the road ([Maňas](https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf)). | Very low: 1–few farmsteads + sheds; paddies/fields dominate footprint (Ogimachi: plots scattered among fields ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))). | Medium strip density: continuous active frontage, shallow setbacks defining the outdoor room ([Norwalk plaza/frontage language](https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL); Terrace active uses facing plazas ([UDP](https://www.terrace.ca/sites/default/files/docs/business-development/ocp-appendix-c-terrace_downtown_action_plan_and_urban_design_guidelines_-_final_-_9-oct-2018_low_res.pdf))). |
| **功能锚点 (nodes / landmarks)** | Well / fountain / hall / church / tower on or facing the square; district landmark visible from approaches (Oxenfurt analysis: main square tower as long-range landmark ([GameDeveloper](https://www.gamedeveloper.com/design/level-design-analysis-oxenfurt-level-in-the-witcher-3-wild-hunt))). Centralized / radial / oriented-to-focal patterns ([Epic](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)). | Local landmarks: porch cluster, pocket green, lamp at junction; doors onto lane. Village-square type: entrances open into square ([Maňas](https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf)). | Barn, silo, farmhouse door, pasture gate, irrigation hub. Outbuildings often set apart for fire safety (Ogimachi ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))). | Stall row, shop signs, market gate/arch; commerce on integrated streets ([Biskra](https://doi.org/10.20431/2456-4931.071006)). Archways mark district entry (Kraus ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender))). |
| **植被密度** | Sparse *inside* paved room; trees optional / formal (plaza codes ([Norwalk](https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL))). Banks / edges carry riparian planting if water present. | Higher yard / hedge / garden planting; soft edges between plots (Ogimachi: vegetation / waterway as boundaries without fences ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))). | Crops as primary “vegetation texture”; tree belts at settlement edge; keep large trees off crop beds (craft rule; crop-zone separation also in farm planners ([Switchblade](https://www.switchbladegaming.com/stardew-valley/farm-layouts/)) **[low confidence]**). Traditional villages: productive (fields) vs ecological (forest/wetland) vs living land ([Enshi PLES](https://www.mdpi.com/2073-445X/14/8/1624)). | Street trees sparse; props (awnings, crates) read denser than canopy. Active ground-floor frontage > green cover ([Terrace](https://www.terrace.ca/sites/default/files/docs/business-development/ocp-appendix-c-terrace_downtown_action_plan_and_urban_design_guidelines_-_final_-_9-oct-2018_low_res.pdf)). |
| **水面角色** | Civic edge or amenity (river corridor, fountain); not the farm grid. Harbor / waterfront as distinct district node (Oxenfurt harbor vs square ([GameDeveloper](https://www.gamedeveloper.com/design/level-design-analysis-oxenfurt-level-in-the-witcher-3-wild-hunt))). | Small pond / well / ditch near houses; drainage to courtyard low points (Jharkhand courtyard drainage ([Archinomy](https://www.archinomy.com/case-studies/traditional-house-in-jharkhand-india/))). | **Irrigation network**: winding channels between plots (Ogimachi waterways net between houses and paddies ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))); Dharamshala springs directed between houses ([JARS](https://doi.org/10.56261/jars.v22.272106)). | Optional canal/edge water; must not replace the **street as the main open figure**. Linear markets often follow valley/river plains in village morphology ([Enshi guided / street-market layouts](https://www.mdpi.com/2073-445X/14/8/1624)) **[transfer: region-specific]**. |

### Dream-facing relative targets (tile ratios — craft translation)

Aligned with locked [`AREA_FRAMEWORK.md`](../../AREA_FRAMEWORK.md); evidence above justifies *why* columns differ:

| | Plaza | Residential | Farm home / farmland | Market |
| --- | --- | --- | --- | --- |
| Open-core shape | Large **square/rect** paved room | Pocket ≤ small / none | Yard dirt / field matrix | **Ribbon** street |
| Main path width (tiles) | 3–4 | 2 | 2 (bridge band 3–5) | 3 |
| Spur width | 2 | 1–2 | 1 | 1–2 alleys |
| Building count feel | Few, larger | Many, compact | Few + sheds | Mid, continuous frontage |

---

## 2. 反单调手法（节奏、对比、阈值）

| Technique | What practitioners do | Sources |
| --- | --- | --- |
| **Narrow ↔ open rhythm** | Alternate compressed alleys / streets with release into squares or main streets; lighting contrast follows (dim alley → bright open). | Bulavina: alternate narrow and open ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)); Kraus: open places vs linear roads + bright/dim contrast ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender)); Oxenfurt: narrow gate → large reveal ([GameDeveloper](https://www.gamedeveloper.com/design/level-design-analysis-oxenfurt-level-in-the-witcher-3-wild-hunt)). |
| **Neighborhood layout first** | Different **layout proportions** per district before swapping façade skins (otherwise districts feel same). | Bulavina: foundations of diversity = layout + architecture + landmarks ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). |
| **Path hierarchy as contrast** | One arterial + branching private paths; never uniform path width. | Kraus ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender)); Oxenfurt main vs secondary roads ([GameDeveloper](https://www.gamedeveloper.com/design/level-design-analysis-oxenfurt-level-in-the-witcher-3-wild-hunt)); Epic paths/edges ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)). |
| **Frequency of massing** | Plaza: few large anchors; residential: mid-frequency roofs; farm: high-frequency crop rectangles; market: high-frequency stall/door beats along one axis. | Epic pattern break / dissonance to call attention ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals)); landmark uniqueness vs fabric (Bulavina ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE))). |
| **Material / color coding** | Per-district ground + wall palette (stone plaza vs dirt farm vs mixed residential). | Kraus color-coding blockout ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender)); Bulavina neighborhood color ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). |
| **Elevation / vista rhythm** | Hills open long views to landmarks; flat farm uses crop rows as rhythm instead. | Bulavina elevation/vistas ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)); Kraus elevation to highlight landmarks ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender)). |
| **Avoid endless straight corridors** | Long straight streets feel monotonous; break with squares / bends. | Bulavina caution on straight streets ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). |
| **Big streets don’t dead-end** | Arterials merge or terminate in a square, then split to smaller streets that may end. | Bulavina ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). |
| **Detail density ≠ always more** | Walking districts get more unique detail; fast-movement districts emphasize large forms. | Bulavina size / proportions / LOD tied to movement speed ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE)). |

---

## 3. 与现实一致的规则（简化后可用于 2D 村镇）

### 3.1 门对路 / 门对公共空间

- **Village-square morphology:** farmstead entrances open onto the square; yards/fields behind ([Maňas 2025](https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf)).
- **Stripe / street village:** buildings open onto the central road ([Maňas](https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf); street-village literature cited therein).
- **Game craft:** south-facing door art → place lots **north of** the path/plaza so doors address the public space ([LAYOUT.md](../../LAYOUT.md) project rule; door/apron practice also in artists pipeline doc).
- **Culture caveat:** some vernaculars orient entrances to **east / river / sun**, not the road (Baiga: face east or river even when beside a path ([ISVS](https://doi.org/10.61275/isvsej-2025-12-04-10))). For Dream default fantasy-village kit, prefer **door→public**; use sun/river overrides as deliberate variants **[low confidence if applied globally]**.

### 3.2 日照 / 朝向（简化）

- Consistent roof/gable orientation can make a village *imageable* (Ogimachi: north–south ridges so east–west thatch dries evenly ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))).
- Courtyard houses often use N–S plan with south entrance for climate response (Andhra case ([Archinomy](https://www.archinomy.com/case-studies/traditional-house-in-andhra-pradesh/))).
- Cluster orientation can maximize courtyard sun (Dharamshala ([JARS](https://doi.org/10.56261/jars.v22.272106))).
- **2D simplification:** pick one light quadrant + one door facing per district kit; don’t randomize yaw without matching door art ([artists-tile-pipeline](./artists-tile-pipeline.md)).

### 3.3 排水

- Courtyards as lowest level; grade storage uphill so water doesn’t enter rooms (Jharkhand ([Archinomy](https://www.archinomy.com/case-studies/traditional-house-in-jharkhand-india/))).
- Settlement follows contour and natural drainage; springs/channels between houses (Dharamshala ([JARS](https://doi.org/10.56261/jars.v22.272106))).
- Farm villages: waterways weave with paths between paddies and houses (Ogimachi ([WHC](https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/))).
- **TileMap:** meander water / ditches along low edges; damp bank tiles; don’t put buildings in flow corridors ([LAYOUT.md](../../LAYOUT.md)).

### 3.4 步行距离

- Classic **5-minute / ~400 m** pedestrian shed around a plaza / main street / school-like center ([Morphocode](https://morphocode.com/the-5-minute-walk/); New Urbanist / mixed-use guidelines language ([doczz guidelines excerpt](https://doczz.net/doc/3760463/commercial-mixed-use-design-guidelines))).
- Daily destinations often work best in roughly **400–800 m** bands for walking frequency ([Safe Routes Partnership summary](https://saferoutespartnership.org/resource/identifying-destination-distances/)).
- **Game compression (Bulavina):** shrink metres so residential → plaza → market stays a short, interesting walk, but keep **relative rings**: civic/market near integrated center, farms outer ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE); village PLES production–living–ecological rings ([Enshi](https://www.mdpi.com/2073-445X/14/8/1624))).

### 3.5 可读性结构（Lynch → LD）

Paths, edges, districts, nodes, landmarks — organize towns so players form cognitive maps ([Epic Parts 4–5](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals); GDC: [Stop Getting Lost — cognitive maps](https://gdcvault.com/play/1027206/Stop-Getting-Lost-Make-Cognitive); architecture-in-LD workshop ([GDC Vault](https://gdcvault.com/play/1023554/Level-Design-Workshop-Architecture-in))).

---

## 4. 可迁移到 TileMap 的 checklist

Use while painting Godot `TileMapLayer` / assemblers. Pass order still: masks → ground → water → path → buildings → props → trees → actors ([LAYOUT.md](../../LAYOUT.md)).

### 4.1 Blockout / metrics

- [ ] Lock **player / cart / door** size first; path widths are multiples of that unit (Kraus metrics; Epic measurement culture ([80.lv](https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender); [Epic](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals))).
- [ ] At least **two path widths** on the map (main vs spur).
- [ ] District identity readable in **greyblock** (cubes only) — if not, skins won’t save it (Bulavina cube street vs chaos ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE))).

### 4.2 Masks by district

- [ ] **Plaza:** one large paved `path_mask` room + framing lots; water as edge corridor, not crop grid.
- [ ] **Residential:** lane network + optional pocket; yards as dirt/grass pockets, not civic stone.
- [ ] **Farm:** dirt hub + rectangular `crop_beds`; irrigation polyline; fence inset for build zone.
- [ ] **Market:** **strip** `path_mask` (long axis), stall slots along both long edges — not a centered square.

### 4.3 Frontage & doors

- [ ] Doors face the public path/plaza; dirt/stone **apron** south of footprint.
- [ ] Market: frequent door/stall beats on the main street; residential: doors on spurs.
- [ ] Full building AABB inside build zone ([BUILDING_PLACEMENT.md](../../BUILDING_PLACEMENT.md)).

### 4.4 Landmarks & edges

- [ ] One **district landmark** (well, barn, stall gate, civic tower) visible from entry path.
- [ ] Orient a main path toward a landmark when possible (Bulavina ([talk](https://www.youtube.com/watch?v=Q3Scw3dzxWE))).
- [ ] District **edge**: fence, river, crop line, or tree belt (Epic edges ([LD Fundamentals](https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals))).

### 4.5 Vegetation & water

- [ ] No trees on stone walks / in water / on crop beds ([LAYOUT.md](../../LAYOUT.md)).
- [ ] Vegetation density matches district column in §1.
- [ ] Water role matches district (edge river / yard pond / irrigation / optional canal).

### 4.6 Rhythm & anti-clone

- [ ] Thumbnail test: 1/8 screenshot still distinguishable as plaza vs residential vs farm vs market ([AREA_FRAMEWORK](../../AREA_FRAMEWORK.md)).
- [ ] Narrow→open→narrow (or field→hub→field) at least once on the walk graph.
- [ ] Do **not** reuse the same plaza Rect + same river formula for every district.

### 4.7 Walk graph / NPCs

- [ ] NPC waypoints only on walk surfaces; idles at anchors (well, door, stall).
- [ ] Market: linear patrol + stall dwell; plaza: loop; farm: door↔barn↔pond.

### 4.8 Terrain art handoff

- [ ] Separate terrain peering when materials must not blend (plaza stone ≉ irrigation mud) ([engineers-tilemap-terrain](./engineers-tilemap-terrain.md)).
- [ ] Ground filler before props; landmarks on prop layer, not repeating fill tiles ([artists-tile-pipeline](./artists-tile-pipeline.md)).

---

## 5. Claim → URL index (compact)

| # | Claim | URL |
| --- | --- | --- |
| 1 | Core urban spaces: street, square, backyard; readable instantly | https://www.youtube.com/watch?v=Q3Scw3dzxWE |
| 2 | Same talk on GDC Vault (Bulavina, CDPR, 2024) | https://gdcvault.com/play/1034528/Level-Design-Summit-Urban-Planning |
| 3 | Neighborhood diversity = layout + architecture + landmarks | https://www.youtube.com/watch?v=Q3Scw3dzxWE |
| 4 | Compress real walking times for games | https://www.youtube.com/watch?v=Q3Scw3dzxWE |
| 5 | Path width by importance; districts with function; Totten reference | https://80.lv/articles/creating-a-fantasy-medieval-city-in-unreal-engine-5-blender |
| 6 | Main vs secondary roads; landmark tower; narrow→open reveal | https://www.gamedeveloper.com/design/level-design-analysis-oxenfurt-level-in-the-witcher-3-wild-hunt |
| 7 | Paths, edges, districts, nodes, landmarks; commercial vs residential districts | https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals |
| 8 | Positive/negative space; open fields as void | https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals |
| 9 | Centralized / path-oriented / pattern-break patterns | https://dev.epicgames.com/community/learning/tutorials/3VKJ/unreal-engine-fortnite-level-design-fundamentals |
| 10 | Cognitive maps GDC | https://gdcvault.com/play/1027206/Stop-Getting-Lost-Make-Cognitive |
| 11 | Architecture mood in LD (GDC) | https://gdcvault.com/play/1023554/Level-Design-Workshop-Architecture-in |
| 12 | Village-square: doors to square, yards to fields; stripe: doors to road | https://karolinum.cz/data/clanek/15021/Geogr_61_1_0069.pdf |
| 13 | Medieval street ~11–13 m modules; market form evolution | https://doi.org/10.1484/m.naa-eb.5.151678 |
| 14 | Small-town market squares ~0.37–0.58 ha; ~8–10% of core | https://doi.org/10.3390/su12208356 |
| 15 | Angerdorf / rope modules for greens & farmstead rows | https://doi.org/10.21014/acta_imeko.v10i1.881 |
| 16 | Plaza = pavement room defined by frontages | https://www.norwalkct.gov/DocumentCenter/View/32246/Norwalk-Building-Regulations-ART5-DevParcel-Stds---Updated_FINAL |
| 17 | Plaza framing, sun/wind, active uses | https://www.terrace.ca/sites/default/files/docs/business-development/ocp-appendix-c-terrace_downtown_action_plan_and_urban_design_guidelines_-_final_-_9-oct-2018_low_res.pdf |
| 18 | 5-minute walk ≈ 400 m ped shed around plaza/center | https://morphocode.com/the-5-minute-walk/ |
| 19 | Walking destinations ~400–800 m | https://saferoutespartnership.org/resource/identifying-destination-distances/ |
| 20 | Space Syntax accessibility / through-movement | https://spacesyntax.com/the-space-syntax-approach/ |
| 21 | Commercial grids more integrated; residential more segregated | https://www.yumpu.com/en/document/view/51490110/paper-space-syntax-network |
| 22 | Integration correlates with pedestrian volume (Seoul) | https://mdpi-res.com/d_attachment/sustainability/sustainability-12-08647/article_deploy/sustainability-12-08647-v2.pdf?version=1603271379 |
| 23 | Shops on high integration/choice streets | https://doi.org/10.20431/2456-4931.071006 |
| 24 | Space syntax commercial-district review | https://doi.org/10.3390/su18105145 |
| 25 | Ogimachi path widths; houses in fields; irrigation net; roof orientation | https://whc-shirakawa-goandgokayama.jp/en/three_villages/ogimachi/ |
| 26 | Production–living–ecological village patterns | https://www.mdpi.com/2073-445X/14/8/1624 |
| 27 | Courtyard drainage / south entry cases | https://www.archinomy.com/case-studies/traditional-house-in-jharkhand-india/ · https://www.archinomy.com/case-studies/traditional-house-in-andhra-pradesh/ |
| 28 | Contour settlement + spring channels | https://doi.org/10.56261/jars.v22.272106 |
| 29 | Entrance may prioritize sun/river over road | https://doi.org/10.61275/isvsej-2025-12-04-10 |
| 30 | Lynch five elements (secondary explainer) | https://www.kaarwan.com/blog/architecture/kevin-lynchs-5-elements-that-shape-cities-urban-design?id=1638 |
| 31 | Farm zone / path habits (game craft; **[low confidence]**) | https://www.switchbladegaming.com/stardew-valley/farm-layouts/ |
| 32 | Mixed-use ped-shed / plaza size language | https://doczz.net/doc/3760463/commercial-mixed-use-design-guidelines |

---

## 6. Gaps / [low confidence]

- Exact **tile counts** in Dream are **project craft locks**, not measured from a single GDC slide; they are *ratios* justified by hierarchy literature + compression.
- **Farm TileMap grids** lean on farming-game layout practice more than historic cadastral modules — mark gameplay sources when used.
- Space Syntax **numerical** integration thresholds are city-scale; for a 40×30 map, use the *qualitative* rule: market/plaza on the most connected walk lines, residential on broken spurs, farm off the arterial.
- Solar/door customs vary by culture; default Dream kit ≠ universal vernacular.

---

## 7. Related project docs

- [`AREA_FRAMEWORK.md`](../../AREA_FRAMEWORK.md) — locked district parameter table  
- [`LAYOUT.md`](../../LAYOUT.md) — hard placement rules  
- [`artists-tile-pipeline.md`](./artists-tile-pipeline.md) — tile/prop pipeline  
- [`engineers-tilemap-terrain.md`](./engineers-tilemap-terrain.md) — terrain peering / layers  
