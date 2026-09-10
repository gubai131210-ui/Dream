# Animal Crossing: New Horizons — Scene Craft Research

**Scope:** environment / terrain / town-readability craft only (not genre, economy, or social sim).  
**Goal:** transferable rules for a Godot 2D/2.5D village (TileMap layers, placement agents, paint tools).

---

## Techniques

### 1. River / cliff / waterfall terraforming

**Tile-paint tools, not freeform mesh.** Island Designer paints one **terrain unit** at a time. Water, cliffs, and paths all share the same interaction grammar: place → optional second press to **round corners** → third press / erase to remove.

**Bank curves**
- After a 2×2 water block exists, corners can be “cut” so banks become diagonal/soft instead of axis-aligned stairs.
- Same rounding exists for cliff corners and official path corners.
- Community process: dig rough shape first, then round; fill/redig to kill sharp elbows in streams ([Leia Leilani process guide](https://leialeilani.com/guides/terraforming-guide-with-full-process); [Island Designer wiki](https://animalcrossing.fandom.com/wiki/Island_Designer)).

**Width / length rules (gameplay + readability)**
| Rule | Value | Why it matters for scene craft |
|------|-------|--------------------------------|
| Fishable pond | ≥ **3×3** (each side) | Below this, water reads as “puddle,” not habitat |
| Fishable river | ≥ **3** wide, ≥ **10** long | Narrower = stream/hoppable canal |
| Pond→river convert | longest side > shortest + **6** | Elongation triggers flow identity |
| Waterfall-top pond | ≥ **3×4** (waterfall row not spawnable) | Fall lip needs a shelf |
| Bridge span | water **3–5** tiles; walkway **2×1** each bank | Forces river corridors into bridgeable bands |
| Player hop | **1–2** tile water | Stepping-stone / narrow channel language |
| River mouth | **fixed**, 1-tile non-terraform stub at ocean | Permanent drainage anchors |

Sources: [Island Designer — waterscaping](https://animalcrossing.fandom.com/wiki/Island_Designer), [TheGamer plot sizes](https://www.thegamer.com/animal-crossing-new-horizons-building-plot-size-guide/), [iMore terraforming](https://www.imore.com/animal-crossing-new-horizons-terraforming-guide).

**Waterfalls**
- Created by waterscaping **on a cliff edge** (usually top); bottom pond/river optional for “natural” read.
- Waterfalls need **straight** cliff edges — **not curved** cliff corners ([iMore](https://www.imore.com/animal-crossing-new-horizons-terraforming-guide)).
- Formation heuristic from builders: one full ground square on one side + at least a corner on the other ([Leia Leilani](https://leialeilani.com/guides/terraforming-guide-with-full-process)).
- Visual craft tip (community, not Nintendo): stagger falls across cliff planes; avoid one flat curtain ([MadFandom waterfall ideas](https://madfandom.com/acnh-waterfall-ideas/)).

**Cliffs**
- **Pyramid / stepped** stacking: next elevation must sit **≥1 tile inset** from the edge below — no sheer walls ([Island Designer wiki](https://animalcrossing.fandom.com/wiki/Island_Designer); [Island customization](https://animalcrossing.fandom.com/wiki/Island_customization)).
- Max ~4 elevation bands; top band may be unclimbable “silhouette only.”
- Round corners only when a 2×2 of full cliff squares supports them; otherwise second press collapses.

**Water edge art (data-backed)**
- Terrain is not a heightfield alone: each cell stores a **UnitModel** + **elevation** + **rotation** (0–3 × 90°) ([NHSE Field Item Editor wiki](https://github-wiki-see.page/m/kwsch/NHSE/wiki/Field-Item-Editor)).
- Datamined families: `River0A`…`River8A`, `Cliff*`, large `Fall*` set, and parallel `Road*` sets ([`TerrainUnitModel.cs`](https://raw.githubusercontent.com/kwsch/NHSE/master/NHSE.Core/Structures/Map/Terrain/TerrainUnitModel.cs)).
- Neighbor validity is combinatorial: river bank tiles encode how many of 8 half-edges are land vs water; illegal neighbors glitch ([NHSE #265](https://github.com/kwsch/NHSE/issues/265), [#251](https://github.com/kwsch/NHSE/issues/251)).
- **Variant** on river/cliff = slight texture variation only — randomize for less tiling sameness ([NHSE #251](https://github.com/kwsch/NHSE/issues/251)).
- Collision/heightmaps live in **PBC** files researched by [Treeki/CylindricalEarth](https://github.com/treeki/cylindricalearth).
- Cliff model selection by adjacency documented visually for modders ([GameBanana cliff model logic](https://gamebanana.com/tuts/18892)).

**Bridges as scene grammar**
- Cap ~10 bridges / 10 inclines (post-2.0).
- Inclines only against **flat** cliff faces (no diagonal cliff).
- Tip: paint path **before** placing bridge if you want path flush to ends (game blocks path-to-bridge edge afterward) ([iMore tips](https://www.imore.com/animal-crossing-new-horizons-terraforming-guide)).

### 2. Ground: grass / sand / path painting, soft edges, season

**Paint materials (official permits)**  
Dirt (free), grass restore, stone, brick, dark dirt, sand, terra-cotta, arched tile, wood, custom design ([Island Designer](https://animalcrossing.fandom.com/wiki/Island_Designer)).

**Soft edges**
- Same-type path tiles **merge**; different types keep a **grass separator** strip.
- A path tile does **not** fill the full square unless surrounded by same type — edge residual grass is intentional softness ([Island Designer — Paths](https://animalcrossing.fandom.com/wiki/Island_Designer)).
- Second A on a right-angle corner → rounded path lip (official paths only; custom squares do not bevel).
- Custom designs with ≥1 transparent pixel can **inherit** underlying official path silhouette/rounding ([Polygon custom paths](https://www.polygon.com/animal-crossing-new-horizons-switch-acnh-guide/2020/4/15/21222398/how-to-make-custom-paths-designs-patterns/); [Bell Tree](https://www.belltreeforums.com/threads/how-to-make-custom-designs-round-like-default-paths.548651/)).

**Material semantics**
- Dirt / dark dirt ≈ plantable like grass; sand ≈ beach plant rules (coconuts); hard paths block dig/plant ([Island customization](https://animalcrossing.fandom.com/wiki/Island_customization)).
- Footstep SFX + footprints on sand / dark dirt reinforce material identity.

**Seasonal ground**
- Base ground swaps **grass ↔ snow** material sets seasonally. Texture dumps show parallel maps: `mGrass_*` vs `mGrassSnow_*`, plus shared **`GrdEdge`** edge maps and translucent `mGrassRiverXlu` / `mGrassCliffXlu` blends at banks/cliffs ([Spriters Resource — Grass/Snow](https://textures.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/asset/512158/)).
- Official painted paths keep their material; **custom** path art does **not** auto-winterize — designers swap seasonal pattern sets ([r/AnimalCrossing snow thread](https://www.reddit.com/r/AnimalCrossing/comments/juidvh/how_do_custom_paths_interact_with_snow/)).
- Implication: treat **ground albedo** as a season layer under a stable **path overlay** layer.

### 3. Building facing rules — “reads as a town”

Nintendo constrains orientation and anchors harder than free terraforming:

| Constraint | Effect on town readability |
|------------|----------------------------|
| **No building rotation** — doors face camera / south | Every facade is readable from the default view; streets feel front-loaded |
| **Immobile plaza** (~12×10) + **Resident Services** at rear center | Permanent civic heart / wayfinding landmark |
| **Immobile airport** at island base (~9 wide) | Arrival spine; island reads “from dock to town” |
| **Fixed river mouths / beach / dock / secret beach** | Drainage + coastal silhouette set before player paint |
| **Door porch clearance** (undiggable, path OK) | Forced forecourt in front of every building |
| **One move / day**, footprint kits, no overlap | Slow, deliberate “planning board” placement |

Sources: [Island customization — Fixed Structures](https://animalcrossing.fandom.com/wiki/Island_customization), [chibisnorlax ACNH FAQ](https://chibisnorlax.github.io/acnhfaq/island-dev/), [GameRevolution — cannot rotate](https://www.gamerevolution.com/guides/648662-can-you-rotate-buildings-in-animal-crossing-new-horizons-nintendo-switch), [TheGamer footprints](https://www.thegamer.com/animal-crossing-new-horizons-building-plot-size-guide/).

**Footprint cheat-sheet (approx. tiles)**  
Villager home 4×4 (house ~4×3 + porch), player 5×4, shops/museum 7×4, Able 5×4, campsite 4×4, incline 2×4, bridge 4 × (3–5) + bank pads.

**Town-read takeaway:** Nintendo does **not** rely on free yaw. Legibility comes from (1) fixed civic anchors, (2) uniform facade direction, (3) porch setbacks, (4) player-built **bridges/inclines/paths** that stitch neighborhoods to the plaza.

### 4. Villager walking / daily routes

**Hard mobility**
- Villagers use **bridges and inclines only** (no vaulting pole / ladder). Connectivity graph = walkable town life ([r/ac_newhorizons pathing](https://www.reddit.com/r/ac_newhorizons/comments/i6qb38/do_your_animals_walk_around_your_whole_island_or/); [Bell Tree pathing](https://www.belltreeforums.com/threads/villager-pathing-ai.540778/)).

**Soft preferences (player-tested, widely agreed)**
- Prefer **official** paths ≫ custom floor designs.
- Prefer **wide + straight** paths over winding 1-tile trails.
- Attracted to **plaza / home / shop** interest spots; dead-end paths cause turnbacks.
- Can **spawn/teleport** onto connected land near player or home; can get stuck on disconnected cliff islands.

**Schedule data (datamine)**  
`NpcLife.bcsv` / `NpcInterest.bcsv` expose time-of-day indoor/outdoor weights, season weights, `MoveASType` / `WaitASType`, hobby motifs — i.e. **weighted activity slots**, not a single scripted circuit ([wuffs.org BCSV dump](https://wuffs.org/acnh/bcsv_120/html/NpcLife.html)).

**Scene craft:** design a **plaza hub + arterial official-style paths + bridge/incline graph**; treat furniture clutter as pathfinding damage.

### 5. Design docs / Treehouse / interviews / terrain layers

| Source | What it actually says about craft |
|--------|-----------------------------------|
| **E3 2019 Treehouse** (Nogami / Kyogoku) | Deserted island = blank canvas; freedom to place what/where vs preexisting village ([IGN Treehouse](https://www.ign.com/articles/2019/06/11/animal-crossing-new-horizons-reveals-world-premiere-of-new-gameplay-at-nintendo-treehouse-live-e3-2019)) |
| **Nintendo interview (Kyogoku)** | Start before the place “becomes a village”; DIY + blank canvas ([Nintendo Everything](https://nintendoeverything.com/animal-crossing-new-horizons-devs-on-the-decision-to-start-on-an-island-new-features-multiplayer-more/)) |
| **Launcher / Gamedeveloper** | Terraforming = instant landscape authorship without waiting on shops/clock ([Gamedeveloper](https://www.gamedeveloper.com/design/why-nintendo-s-new-i-animal-crossing-i-features-allow-instant-change-in-the-real-time-game)) |
| **CEDEC 2020 / Famitsu** | Series history → island development as clear one-line pitch; communication seeds — **not** a public terrain tech GDD ([Famitsu CEDEC](https://www.famitsu.com/news/202009/04205284.html)) |
| **NHSE / CylindricalEarth** | Real terrain stack: UnitModel + elevation + rotation + variants; PBC collision/height; ≥250 model IDs — image paint alone insufficient ([NHSE #115](https://github.com/kwsch/NHSE/issues/115), [CylindricalEarth](https://github.com/treeki/cylindricalearth)) |

**No public Nintendo “terrain layer GDD.”** Closest engineering truth is community reverse engineering of save terrain tiles + BFRES/PBC assets.

### 6. Asset / UI paint-tool implications — what to place first

Nintendo’s unlock + builder practice imply a **layered authoring order**:

1. **Fixed anchors** (plaza, airport, river mouths, beach) — immutable frame.  
2. **Elevation** (cliffs, stepped terraces) — silhouette + neighborhoods.  
3. **Hydrology** (rivers → waterfalls → ponds) — respect bridgeable widths.  
4. **Connectivity** (bridges, inclines) — NPC graph.  
5. **Arterial paths** (official soft-edge materials) — guide feet and AI.  
6. **Buildings** (facades south, porch clear) — civic + residential plots.  
7. **Overlay custom art / furniture / flora** — decoration last.

UI implications for a Godot designer tool:
- Separate **modes**: elevation / water / path / structure (mirror Island Designer permits).
- Second-press = **bevel/round** operator on corners.
- Show **illegal** neighbors (waterfall on curved cliff, cliff at edge of lower tier, bridge >5).
- Preview **door forecourt** and **path residual grass** so soft edges are intentional.
- Season = swap ground material set; keep path layer stable.

---

## Math / procedural

| Idea | ACNH equivalent | Godot transfer |
|------|-----------------|----------------|
| Autotile / Wang blob | `River0A`–`8A`, `Cliff*`, `Road*0A`–`8A` by 8-way adjacency + rotation | `TileSet` terrain sets; bitmask or peering bits |
| Elevation discrete | Integer elevation per cell; stepped inset constraint | Separate height layer or Y-sort bands; forbid cliff on outer rim of lower band |
| Corner round FSM | Place → round → erase cycle | Tool state machine on corner cells |
| River identity | Geometry thresholds (3×N, length, mouth/waterfall link) | Tag water bodies; min corridor width for “river” vs “stream” |
| Variant dither | Random texture variant per model | Atlas variants / `modulate` noise without changing collision |
| Path soft edge | Incomplete fill unless 4-neighbors same | Edge grass overlay when neighbor ≠ self |
| Seasonal swap | Parallel grass/snow PBR sets + edge maps | Remap tile atlas or shader param; paths stay |
| Connectivity graph | Bridges/inclines as only NPC edges | Navmesh / A* on land + structure links only |
| Activity schedule | Weighted time×season×spot tables | Weighted random goals, not hard-coded loops |

Image→terrain import fails without neighbor validation ([NHSE #115](https://github.com/kwsch/NHSE/issues/115)) — procedural generators should emit **validated UnitModel neighborhoods**, not raw heightmaps alone.

---

## Asset pipeline

1. **Base ground** — seamless grass (and snow twin) with dedicated **edge** maps (`GrdEdge`) and river/cliff translucent blends (`*Xlu*`) ([texture dump](https://textures.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/asset/512158/)).  
2. **Terrain unit meshes/tiles** — bank, inner/outer corner, waterfall composites (Fall series combines land+cliff+water).  
3. **Path material atlases** — one family per permit with 0A–8A corner language + optional round lip.  
4. **Collision / PBC** — walkable height separate from visuals ([CylindricalEarth](https://github.com/treeki/cylindricalearth)).  
5. **Building kits** — fixed facing, porch footprint, plaza brick distinct from player brick path ([Island Designer brick note](https://animalcrossing.fandom.com/wiki/Island_Designer)).  
6. **Paint UI** — mode icons, mile-gated tools, cleanup service for stuck items.

For Dream/Godot: prefer **TileMapLayer stack** — `height` → `water` → `ground_season` → `path` → `deco` — matching SEAMLESS.md’s ecological ground types + meandering river mask.

---

## Agent rules

When an agent lays out or reviews a village scene inspired by ACNH craft:

1. **Lock anchors first** — plaza/civic, arrival (dock/airport analog), at least one drainage mouth or map-edge water exit.  
2. **No free building yaw** — all primary facades share one camera-facing axis; add porch/forecourt tiles.  
3. **Cliffs are stepped** — never sheer stacks; leave climb/silhouette-only top band optional.  
4. **Rivers are corridors** — default width ≥3; reserve bridge spans 3–5; use 1–2 only for hoppable streams.  
5. **Waterfalls only on straight cliff lips**; stagger multi-falls for depth.  
6. **Round banks/paths** after blocking-in; leave grass seams between different path materials.  
7. **Paint order** — elevation → water → bridges/inclines → official-style paths → buildings → custom overlays.  
8. **NPC graph** — every residential cluster must reach plaza via walkable links (no ladder-only islands).  
9. **Prefer wide straight path arteries** for AI; treat clutter as blocked cells.  
10. **Season** — swap ground set; do not assume path overlays auto-adapt.  
11. **Autotile validity** — never place bank/cliff IDs without checking 4/8 neighbors; randomize visual variants only.  
12. **Refuse “genre” substitutes** — do not invent Animal Crossing mechanics; steal **placement grammar** only.

---

## Sources

### Official / first-party adjacent
- [IGN — Treehouse Live E3 2019](https://www.ign.com/articles/2019/06/11/animal-crossing-new-horizons-reveals-world-premiere-of-new-gameplay-at-nintendo-treehouse-live-e3-2019)  
- [Nintendo Everything — Nogami/Kyogoku island interview](https://nintendoeverything.com/animal-crossing-new-horizons-devs-on-the-decision-to-start-on-an-island-new-features-multiplayer-more/)  
- [Gamedeveloper — crafting & terraforming design intent](https://www.gamedeveloper.com/design/why-nintendo-s-new-i-animal-crossing-i-features-allow-instant-change-in-the-real-time-game)  
- [Famitsu — CEDEC 2020 series talk](https://www.famitsu.com/news/202009/04205284.html)  
- [Washington Post — philosophy of big changes](https://www.washingtonpost.com/video-games/2020/03/23/nintendo-explains-philosophy-behind-animal-crossings-big-changes-like-gender-expression-terraforming/)

### High-trust reference / measured rules
- [Animal Crossing Wiki — Island Designer](https://animalcrossing.fandom.com/wiki/Island_Designer)  
- [Animal Crossing Wiki — Island customization](https://animalcrossing.fandom.com/wiki/Island_customization)  
- [TheGamer — building/bridge/incline plot sizes](https://www.thegamer.com/animal-crossing-new-horizons-building-plot-size-guide/)  
- [iMore — Terraforming guide](https://www.imore.com/animal-crossing-new-horizons-terraforming-guide)  
- [chibisnorlax ACNH FAQ — island development](https://chibisnorlax.github.io/acnhfaq/island-dev/)  
- [GameRevolution — buildings cannot rotate](https://www.gamerevolution.com/guides/648662-can-you-rotate-buildings-in-animal-crossing-new-horizons-nintendo-switch)  
- [Polygon — custom paths](https://www.polygon.com/animal-crossing-new-horizons-switch-acnh-guide/2020/4/15/21222398/how-to-make-custom-paths-designs-patterns/)  
- [Leia Leilani — full terraforming process](https://leialeilani.com/guides/terraforming-guide-with-full-process)

### Datamine / engineering
- [NHSE `TerrainUnitModel.cs`](https://raw.githubusercontent.com/kwsch/NHSE/master/NHSE.Core/Structures/Map/Terrain/TerrainUnitModel.cs)  
- [NHSE #251 — river/cliff/waterfall tile catalog](https://github.com/kwsch/NHSE/issues/251)  
- [NHSE #265 — neighbor validation / 8-corner land-water](https://github.com/kwsch/NHSE/issues/265)  
- [NHSE #115 — why image paint ≠ terrain](https://github.com/kwsch/NHSE/issues/115)  
- [NHSE Field Item Editor wiki](https://github-wiki-see.page/m/kwsch/NHSE/wiki/Field-Item-Editor)  
- [Treeki/CylindricalEarth — PBC collision/heightmap](https://github.com/treeki/cylindricalearth)  
- [GameBanana — cliff model logic](https://gamebanana.com/tuts/18892)  
- [wuffs.org — NpcLife.bcsv](https://wuffs.org/acnh/bcsv_120/html/NpcLife.html)  
- [Spriters Resource — Grass/Snow + edge/Xlu maps](https://textures.spriters-resource.com/nintendo_switch/animalcrossingnewhorizons/asset/512158/)

### Player / AI observation (lower trust, consistent)
- [r/ac_newhorizons — villager path preferences](https://www.reddit.com/r/ac_newhorizons/comments/i6qb38/do_your_animals_walk_around_your_whole_island_or/)  
- [Bell Tree — villager pathing AI](https://www.belltreeforums.com/threads/villager-pathing-ai.540778/)  
- [Bell Tree — custom path rounding trick](https://www.belltreeforums.com/threads/how-to-make-custom-designs-round-like-default-paths.548651/)

---

*Research note for Dream Godot village — scene craft transfer only. Not an ACNH clone design doc.*
