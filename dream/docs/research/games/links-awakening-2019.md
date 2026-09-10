# Scene CRAFT — The Legend of Zelda: Link's Awakening (2019 Switch remake)

**Scope:** Grezzo/Nintendo diorama remake (often compared to HD-2D, but **not** Octopath HD-2D: full 3D meshes + tilt-shift miniature look, not sprites on 3D floors).  
**Use for Dream:** village square / coast / soft ground transitions / NPC life / draw-order when mimicking the layered look.  
**Related project docs:** `dream/docs/LAYOUT.md`, `dream/docs/SEAMLESS.md`.

---

## Techniques

### 1. Water / coast / rivers (tile × diorama hybrid)

- **Grid truth, mesh lie:** The remake keeps the **Game Boy tile map structure** (bush, fence, grass clumps occupy the same cells) while artists replace flat tiles with **3D chunk models + textured surfaces** so seams read as diorama pieces, not a heightmap landscape ([Digital Foundry tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)).
- **Coast as opening statement:** Toronbo Shores opens with **soft-focus DOF + water lapping on sand**, recreating the original beat in-engine; sand textures **recall wavy GB patterns** reinterpreted as continuous beach material ([Digital Foundry first look](https://www.digitalfoundry.net/articles/digitalfoundry-2019-links-awakening-switch-first-look); DF tech analysis note on wavy sand → new textures).
- **Material split by biome:** Gloss/plastic is ramped up on many surfaces for the toy look; **sand is deliberately more diffuse** so coast reads soft and matte against glossy cliffs/water ([DF tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)).
- **Water cost:** Large water fills (e.g. Goponga Swamp) are GPU-expensive — full-screen water can pull the game toward 30fps under double-buffer vsync ([DF performance analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-performance-analysis)). Craft implication: **prefer bounded water volumes + bank strips** over ocean-sized continuous sheets in a Godot village scene.
- **Bank composition (observed craft, aligned with Dream rules):** Wet zone = water fill → **damp bank ring** (mud/reed) → dry grass → props. Cliffs/rock walls meet water as **orthogonal tile steps** (GB heritage: mostly 90° walls), dressed with small 3D detail so the grid softens ([DF first look](https://www.digitalfoundry.net/articles/digitalfoundry-2019-links-awakening-switch-first-look) on 90° tile limits retained).
- **Rivers vs coast:** Island rivers/ponds sit in **tile cutouts** with short shore transitions; fishing pond in NW Mabe is a **contained water room**, not an open bay ([Zelda Wiki — Mabe Village](https://zeldawiki.wiki/wiki/Mabe_Village)).

### 2. Ground materials and soft transitions

- **Minimize the tiled look without killing the grid:** Same cell footprint as GB; softness comes from **modelling + texturing + light/shadow**, not from erasing the grid ([DF tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)).
- **Color discipline from GBC DX:** Strong color contrast kept; repetition and harsh junctions are fought with **material variety + specular/shadow**, not more albedo noise ([DF tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)).
- **Cliff ↔ floor blend (community craft observation):** Environments are **tiled mesh chunks**, not continuous landscapes; grass often **fades at cliff bases via vertex color** into the floor grass ([r/gamedev discussion](https://www.reddit.com/r/gamedev/comments/1aity56/how_to_links_awakening_replicate_style/)).
- **Ecological patches (read from scenes + Dream mapping):** Mowed/plaza paths near houses; open meadow yards; taller edge grass; disturbed weed patches; **damp** at water. Pair with seamless wrap-matched tiles (see `SEAMLESS.md`).
- **Props as transition glue:** Flower pairs, stacked-trunk trees, butterflies — small life props that **break flat ground** without changing walkable topology ([DF first look](https://www.digitalfoundry.net/articles/digitalfoundry-2019-links-awakening-switch-first-look)).

### 3. Building facing and village square (Mabe Village)

Mabe is a **compact ~11-structure hub** on a clear cardinal grid with a soft “center” around Marin/Tarin’s house + weathercock axis ([VGKAMI Mabe layout](https://vgkami.com/walkthrough/links-awakening/mabe-village/); [Nintendo Life guide](https://www.nintendolife.com/guides/zelda-links-awakening-leaving-mabe-village-finding-the-sword); [Zelda Wiki](https://zeldawiki.wiki/wiki/Mabe_Village)):

| Quadrant | Landmark role |
| --- | --- |
| **Center / SE** | Marin & Tarin’s house (spawn hub); telephone booth south; Trendy Game SE corner; grass field for cutting |
| **N** | Weathercock plaza landmark (Marin sings later); civic “face” of the town |
| **NE** | Tool shop; Quadruplets house on a **raised cliff ledge**; Dream Shrine; east exit to prairie |
| **NW** | Madam MeowMeow + BowWow (social landmark); fishing pond; Mysterious Forest gate |
| **SW** | Ulrira; library; well; **south road to Toronbo Shores** |

**Facing / composition craft:**

- Houses are **dollhouse volumes** with exaggerated GB proportions; doors read clearly from the overhead-tilted camera ([Aonuma / Hollywood Reporter](https://www.hollywoodreporter.com/news/general-news/zelda-producer-eiji-aonuma-explains-hook-links-awakening-1241422/)).
- Landmark **weathercock north of hub house** creates a north–south civic axis; kids playball on the **south shore road** — social life brackets the square ([Zelda Wiki](https://zeldawiki.wiki/wiki/Mabe_Village)).
- Functional buildings (shop, trendy game, library) sit on **edge slots**, not stacked in the plaza center — one job per corner.
- Vertical variety: **one raised house terrace (Quadruplets)** so the diorama has a height beat without open-world topography.
- Interiors are packed diorama rooms (Haruhana urges players to peek inside) — exterior façades stay readable; richness lives **behind the door** ([Haruhana Nintendo blog](https://www.nintendo.com/en-gb/News/2019/October/Discover-what-graphic-refining-director-Yoshiki-Haruhana-aimed-for-with-the-visual-style-of-The-Legend-of-Zelda-Link-s-Awakening--1656228.html)).

Dream alignment (`LAYOUT.md`): south-facing door art → place lots **north of plaza** so doors face the square.

### 4. NPC idle / walk patterns

Public sources do **not** document exact Switch pathfinding numbers; craft must combine **observed role placement**, actor catalogs, and GB-faithful staging.

**Observed role patterns (Mabe):**

| Pattern | Who / where | Behavior sketch |
| --- | --- | --- |
| **Anchored vendor** | Shopkeeper, Trendy Gamester, Fisherman | Idle at workplace; short talk radius; almost no roam |
| **Chained/fixed animal** | BowWow | Rooted to house front — landmark + soft blocker |
| **Landmark singer** | Marin @ weathercock (story beat) | Idle pose / song at civic prop |
| **Paired play loop** | Kidoh & Joonya on south road to beach | Short reciprocal throw / catch — **loop animation as life** |
| **Scattered siblings** | Quadruplet kids | Dispersed around town for dialogue breadcrumbs, not flock AI |
| **Ambient fauna** | Butterflies, cuccos, fish | Tiny motion loops; butterflies inherited from GB life dressing |
| **Indoor dwellers** | Ulrira, Mamasha, etc. | Mostly room-bound; town feels lived-in without crowded streets |

**Systems notes:** Switch actors use an **entity-component** model; village NPCs are discrete actors (`NpcMarin`, `NpcTarin`, `NpcToolShopkeeper`, …) ([ZeldaMods Actors](https://zeldamods.org/las/Actors)). RE notes exist but are incomplete ([leoetlino/la-re-notes](https://github.com/leoetlino/la-re-notes)).

**Player motion craft (affects how NPCs feel):** Remake uses **stark 8-way facing without blend** for responsiveness — NPCs should stay **simple cardinal faces** too, not full locomotion blending ([DF tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)).

**Agent takeaway:** Prefer **few high-legibility loops** (play, pace 2–3 tiles, bob idle) over crowd sim. Place NPCs as **landmarks that explain a building**, not filler.

### 5. Grezzo / Nintendo on construction, lighting, “toy-like” depth

| Source | Claim (paraphrased) |
| --- | --- |
| **Yoshiki Haruhana** (graphic refining director) | World should feel like **peeking into a diorama**; Link imagined as ~**10 cm figurine**; balance rich miniature detail vs **not over-detailing** past that scale; interiors packed with craft; E3 physical diorama validated the look ([Nintendo UK Haruhana post](https://www.nintendo.com/en-gb/News/2019/October/Discover-what-graphic-refining-director-Yoshiki-Haruhana-aimed-for-with-the-visual-style-of-The-Legend-of-Zelda-Link-s-Awakening--1656228.html)). |
| **Eiji Aonuma** | Style from faithful 3D of exaggerated GB proportions + **diorama intent**; **tilt-shift** applied to emphasize miniature; fits “small but deep” island + comical characters; handheld = peering into miniature, docked = elaborate realistic miniatures ([Hollywood Reporter](https://www.hollywoodreporter.com/news/general-news/zelda-producer-eiji-aonuma-explains-hook-links-awakening-1241422/)). |
| **Satoshi Terada (Grezzo)** | On LA remake: led **art style, 3D backgrounds, and lighting**; later framed LA as Grezzo’s modern top-down Zelda graphic approach ([Ask the Developer — Echoes of Wisdom Pt.1](https://www.nintendo.com/us/whatsnew/ask-the-developer-vol-13-the-legend-of-zelda-echoes-of-wisdom-part-1/)). |
| **Digital Foundry** | Glossy, plastic-like materials + strong specular; sand more diffuse; raised/tilted FOV; delayed camera bounding box; tile structure retained; soft image + tilt-shift DOF ([tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)). |
| **Presentation critique** | Bottom-screen blur is often a **screen-space tilt-shift strip**, not perfect optical DOF — top blur can respect depth better than bottom ([DF / community discussion, e.g. blur critique](https://www.youtube.com/watch?v=PjwZsBe9q-k)). For Dream: prefer a **controlled focus band** that reads miniature without destroying UI readability. |

**Not HD-2D:** HD-2D = HD sprites + 3D stage (Octopath). LA2019 = **3D characters + 3D diorama world + miniature post**. Mimic the **layered depth recipe**, not the Octopath pipeline name.

### 6. What to draw / build first (layered look order)

Recommended **craft order** when mimicking this look (Godot TileMap + mesh hybrid):

1. **Camera & scale contract** — overhead tilt, figurine scale (~toy Link), focus/soft edges; lock zoom to integer-friendly values (`SEAMLESS.md`).
2. **Walkable grid / plaza silhouette** — roads, plaza stone, lot footprints; no decoration yet.
3. **Ecological ground fills** — mowed → meadow → tall/edge → damp; seamless materials; **soft transitions via adjacency**, not vignette pads.
4. **Water mask + banks** — meander/cove (not rectangle); damp ring; then water shader/plane; keep water **bounded**.
5. **Vertical hardscape** — cliffs, steps, one raised terrace if needed; vertex-color / tile blend at feet of walls.
6. **Buildings as dollhouses** — doors facing plaza; roofs as strong color blocks; clear silhouettes under tilt camera.
7. **Landmark props** — weathercock / well / booth / shop sign — one civic icon per axis.
8. **Life dressing** — flower pairs, tree clumps (land only), butterflies.
9. **NPC anchors** — vendors fixed; 1–2 play loops; animals as landmarks.
10. **Post last** — glossy specular pass + gentle tilt-shift; do **not** start with blur (blur without readable silhouettes looks muddy).

---

## Math / procedural

Useful approximations for a Dream-like assembler (not reverse-engineered Grezzo code):

### Tile occupancy

- Keep a discrete grid \(G(x,y)\). Every prop/building claims cells; collision/footprint = cells ∪ small AABB (see `LAYOUT.md`).
- Soft look ≠ soft collision: **visual blend width** 0.5–1.5 tiles; **logic** stays cell-snapped.

### Ground type from distance fields

```
d_path  = distance to road/plaza
d_water = distance to water mask
d_edge  = distance to map border

if d_water <= 1:   damp
elif d_path <= 1:  mowed
elif d_edge <= 2:  tall
elif noise:        weed patch
else:              meadow
```

Matches Dream `SEAMLESS.md` / `LAYOUT.md` spirit and LA’s readable foot-traffic zones.

### Water meander (avoid canal)

For a west-band river of width \(w\), centerline:

\[
x(y) = x_0 + A\sin(2\pi y / L) + B\sin(2\pi y / L_2)
\]

Paint water where \(|x - x(y)| \le w/2\); bank = morphological dilate of water by 1 cell → `damp`.

### Coast bands (Toronbo-style)

```
ocean → wet sand (1–2 cells) → dry sand → grass fringe → inland grass
```

Wet sand = darker/diffuse; dry sand = wavy albedo; avoid glossy specular on sand.

### Cliff foot blend

Vertex color or tile blend weight:

\[
\alpha = \mathrm{saturate}(1 - h / h_{\mathrm{blend}})
\]

Mix wall-base grass tint into floor grass so the joint does not hard-cut ([community observation](https://www.reddit.com/r/gamedev/comments/1aity56/how_to_links_awakening_replicate_style/)).

### Camera / miniature

- Pitch camera ~35–55° from top-down; widen FOV vs classic GB screen.
- Optional delayed follow: Link biased away from travel direction (DF “bounding box” camera).
- Tilt-shift approximation: blur weight \(b = \mathrm{smoothstep}(y_0, y_1, v)\) on screen \(v\) (artistic, not true CoC). Keep mid-band sharp for gameplay.

### NPC loops

- Idle: timer \(T \in [2,6]\) s → play bob/look.
- Patrol: 2–4 waypoints on plaza edge; wait at each end.
- Pair play: two agents share a ball entity; state machine `throw → wait → catch`.

---

## Asset pipeline

| Layer | LA2019 practice (observed / reported) | Dream-friendly pipeline |
| --- | --- | --- |
| **Layout** | Faithful GB tile map as authority | Author mask/JSON/TileMap first; art second |
| **Terrain** | Tiled 3D chunks + textures, not heightmap | `TileMapLayer` fills + optional MeshInstance accents |
| **Materials** | Albedo + normal + occlusion + smoothness (`_alb/_nml/_occ/_smt` on ripped interiors) ([Models Resource examples](https://models.spriters-resource.com/nintendo_switch/thelegendofzeldalinksawakening/)) | Flat-ish albedo, moderate smoothness (~0.6–0.7 on toys; lower on sand/soil); soft AO |
| **Palette** | GBC-like strong local colors | Limit hues per biome; plaza stone vs grass contrast |
| **Buildings** | Exaggerated dollhouse meshes; rich interiors | Exterior LOD simple; optional interior scene later |
| **Water** | Dedicated, costly water rendering | Single plane/shader; bank tiles carry most readable edge |
| **Post** | Tilt-shift / soft focus + lighting directed by Terada’s team | Lightweight DOF or gradient blur; directional key + soft fill |
| **Seamless ground** | Artists hide tile repetition | `tools/make_seamless_terrain.py` wrap-matched ecological set |

**Do not** import copyrighted Nintendo meshes/textures into the shipping game — use them only as **reference** for proportions, facing, and material response.

---

## Agent rules

### Do

1. Keep **grid topology** (plaza, roads, water mask) before dressing meshes.
2. Paint **ecological ground** with soft adjacency (mowed/meadow/tall/weed/damp).
3. Meander water; **damp banks**; no trees in water or on plaza stone.
4. Face doors toward the square; place main lots **north of plaza** if art is south-facing.
5. One **civic landmark** (weathercock-equivalent) on the north axis.
6. NPCs = **anchors + 1–2 loops**, not crowds.
7. Specular/gloss for toy depth; **matte sand/soil** for coasts.
8. Draw/build in the **order in §6**; post-process last.
9. After layout changes, re-run seamless terrain tooling when ground art changes.
10. Spawn a **review subagent** after scene edits (per project user rule).

### Forbidden shortcuts (anti-lazy)

- Do **not** call the style “HD-2D” and ship sprite floors without diorama depth.
- Do **not** start with tilt-shift blur before silhouettes read.
- Do **not** use a straight rectangle river/canal.
- Do **not** carpet one grass swatch (vignette pads / seams).
- Do **not** pile every building on one side with backs to the plaza.
- Do **not** rotate buildings randomly without matching door art.
- Do **not** scatter NPCs without workplace or play-loop roles.
- Do **not** put trees in water or on stone plaza.
- Do **not** make ocean-sized water fills that dominate the frame budget.
- Do **not** over-detail props past figurine scale (Haruhana’s contradiction: rich but not too rich).
- Do **not** copy Nintendo assets into the repo as production content.

---

## Sources

1. Yoshiki Haruhana — graphic direction / diorama / 10 cm Link — [Nintendo UK](https://www.nintendo.com/en-gb/News/2019/October/Discover-what-graphic-refining-director-Yoshiki-Haruhana-aimed-for-with-the-visual-style-of-The-Legend-of-Zelda-Link-s-Awakening--1656228.html) (also [Nintendo ZA mirror](https://www.nintendo.com/en-za/News/2019/October/Discover-what-graphic-refining-director-Yoshiki-Haruhana-aimed-for-with-the-visual-style-of-The-Legend-of-Zelda-Link-s-Awakening--1656228.html))
2. Eiji Aonuma — diorama intent, tilt-shift, handheld vs docked miniature feel — [The Hollywood Reporter](https://www.hollywoodreporter.com/news/general-news/zelda-producer-eiji-aonuma-explains-hook-links-awakening-1241422/)
3. Satoshi Terada — art style, 3D backgrounds, lighting on LA remake — [Ask the Developer Vol. 13 (Echoes of Wisdom) Part 1](https://www.nintendo.com/us/whatsnew/ask-the-developer-vol-13-the-legend-of-zelda-echoes-of-wisdom-part-1/)
4. Digital Foundry — materials, gloss/toy look, tile fidelity, camera, sand reinterpretation — [tech analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-tech-analysis)
5. Digital Foundry — beach opening, DOF, GB-faithful placement, 90° grid heritage — [E3/first look](https://www.digitalfoundry.net/articles/digitalfoundry-2019-links-awakening-switch-first-look)
6. Digital Foundry — water GPU cost (swamp), traversal/lighting streaming cost — [performance analysis](https://www.digitalfoundry.net/articles/digitalfoundry-2019-zelda-links-awakening-performance-analysis)
7. Zelda Wiki — Mabe Village layout, landmarks, Kidoh/Joonya playball on shore road — [Mabe Village](https://zeldawiki.wiki/wiki/Mabe_Village); remake overview — [LA Switch](https://zeldawiki.wiki/wiki/The_Legend_of_Zelda:_Link%27s_Awakening_(Nintendo_Switch))
8. VGKAMI / Nintendo Life — Mabe structure tour — [VGKAMI](https://vgkami.com/walkthrough/links-awakening/mabe-village/), [Nintendo Life](https://www.nintendolife.com/guides/zelda-links-awakening-leaving-mabe-village-finding-the-sword)
9. ZeldaMods — actor list / EC architecture — [Actors](https://zeldamods.org/las/Actors)
10. Community craft — tiled meshes + vertex-color cliff blends — [r/gamedev](https://www.reddit.com/r/gamedev/comments/1aity56/how_to_links_awakening_replicate_style/)
11. Material response discussion — [r/Unity3D](https://www.reddit.com/r/Unity3D/comments/v1es7d/links_awakening_graphics/)
12. Tilt-shift accuracy critique — [YouTube: Fixing The Inaccurate Blur…](https://www.youtube.com/watch?v=PjwZsBe9q-k)
13. Extracted material naming reference (alb/nml/occ/smt) — [Models Resource — LA Switch](https://models.spriters-resource.com/nintendo_switch/thelegendofzeldalinksawakening/)

---

*Research note for Dream scene CRAFT. Prefer primary Nintendo/Grezzo quotes + DF technical reporting; layout/NPC items combine wiki/guides with craft inference where code is unpublished.*
