# Engineers on 2D Tilemap / Environment Crafting

Cross-engine practitioner notes for Dream (Godot 4 village). Not brand-focused: patterns used by map/tooling engineers across Godot, Tiled, Unity-style tilemaps, and procedural cartography blogs.

**Scope:** autotiles / Wang / bitmasks · seamless textures · river meanders · layered maps · variation + perf · Godot 4 `TileMapLayer` / Terrains.

---

## Patterns

### 1. Autotiles, Wang tiles, bitmask terrain blending

| Pattern | Idea | Typical tile count | Where engineers use it |
| --- | --- | --- | --- |
| **4-bit edge bitmask** | Encode N/E/S/W neighbor presence → index 0–15 | 16 | Prototypes, roads/fences, RPG Maker–simple edges |
| **8-bit blob (corners + sides)** | Cardinals + diagonals; diagonal bit only “counts” if both adjacent sides match → **47** unique shapes from 256 masks | 47 | Polished organic terrain (grass↔dirt, water banks) |
| **Wang / corner colors** | Each corner (or edge) carries a terrain *color*; shared edge/corner must match | 16 (2 terrains, corners) … up to 256 mixed | Tiled Terrain Sets; custom resolvers; dual-grid variants |
| **Dual-grid / mini-tiles** | Resolve from a half-cell corner grid; fewer authored tiles for smooth blends | ~16 with good corners | Red Blob interactive autotile notes; some procgen kits |
| **Engine terrain peering** | Author peering bits / terrain IDs; paint “terrain”, engine picks tile | Same as blob/edge sets | Godot 4 Terrains; Tiled Terrain Brush |

**Godot 4 mapping (official):** Terrains replace Godot 3 autotiles. A terrain set uses one of **Match Corners and Sides**, **Match Corners**, or **Match Sides**. Peering bits on each tile describe which neighbor terrains (or empty `-1`) are required. Paint with **Connect** (join to all surrounding same-terrain cells) or **Path** (join only within the stroke—useful for adjacent roads that must *not* merge). Incomplete peering → wrong or unexpected tiles.

**Tiled mapping:** Corner Set / Edge Set / Mixed Set mirror the same math. Mixed ≈ Godot “Match Corners and Sides”; incomplete sets are fine if Patterns view shows what you actually need.

**Engineer practice:** Treat bitmask as *authoring automation*, not gameplay truth. Keep a single terrain set for any materials that must blend with each other; split sets when transitions should never exist (e.g. plaza stone never wang-blends into river).

### 2. Seamless textures, wrap, padding, mip/filter

Two different “seam” problems are often confused:

1. **Art seams** — vignette, lighting gradient, or non-wrapping edges in the *source* tile (looks like pads even at 1× integer zoom).
2. **Sampling seams** — atlas UVs + bilinear/mip filter pull in neighbor texels or empty gutters (hairlines / dark borders when zoomed or scrolled).

**Practitioner stack (Godot-aligned):**

- **Art:** Make fill tiles wrap-matched (`L==R`, `T==B`) *or* deliberately use edge-only transition tiles via terrains—don’t mix “almost seamless” fill with hard vignette borders.
- **Import:** Prefer **Nearest** for pixel / crisp village art; disable mipmaps on atlas textures used at fixed tile size.
- **Atlas:** Keep Godot `TileSetAtlasSource.use_texture_padding = true` (1px pad around each tile). Docs: leave on unless padding itself causes issues. Extrude edge colors into gutters when using filtered/mipmapped atlases outside Godot’s pad path.
- **Camera:** Integer zoom / pixel snap when possible; subpixel camera + linear filter → classic tile hairlines (long-standing engine reports).
- **Variation without seams:** Prefer multiple full wrap tiles (or probability among same-peering tiles) over scrolling a non-tileable bitmap.

### 3. River meander algorithms

Engineers pick complexity by *map scale*:

| Approach | When | Sketch |
| --- | --- | --- |
| **Sine-generated curve (meander curve)** | Decorative village river, floodplain strip | Direction angle = `ω · sin(s)` along arc length `s`; integrate steps |
| **Bearing + 1D noise offset** | Heightmap / distance-field carving | Distance to a centerline; offset centerline by `noise(along) * meanderAmp` |
| **Bezier / cubic banks** | Hand-authored shorelines, bridges | Centerline as path; left/right banks as offset curves or dual Beziers |
| **Drainage / flow accumulation** | Whole continents (mapgen) | Downslope graph → accumulate flow → widen by Strahler / log flow (Red Blob mapgen4) |
| **Designer-directed growth** | Hybrid authored + proc | Seed path or painted mask; grow basins toward ocean / follow sketch |

**Village-scale recommendation:** Mask from sine or noise-offset polyline → rasterize to water cells → bank ring = cells touching water. Skip full hydrology unless the map is large enough for tributaries to matter.

### 4. Layered TileMaps (ground / path / water / deco)

Official Godot guidance: use **multiple `TileMapLayer` nodes** (old multi-layer `TileMap` is deprecated). One cell per layer → overlap by stacking layers.

**Common engineering stack:**

| Layer | Role | Notes |
| --- | --- | --- |
| Ground / biome fill | Base grass, meadow, damp, dirt | Terrains + probability variants |
| Path / plaza | Stone, roads | Path-mode terrain so parallel roads don’t auto-merge |
| Water | River / pond mask | Often own layer + collision/nav rules |
| Deco / clutter | Flowers, reeds, cracks | Sparse scatter; low probability or second pass |
| Overhead / canopy | Tree tops, bridges | Y-sort or separate draw order |

**Rules of thumb:** Separate by *update frequency* and *collision ownership*. Don’t put navigation on every visual layer—Godot docs warn TileMap navigation is limited; bake `NavigationRegion2D` for quality. Never stack conflicting nav meshes.

### 5. Performance + variation (noise on atlas variants)

- **Batching:** `TileMapLayer` draws by **quadrants** (`rendering_quadrant_size`). Tune for map size; Y-sorted layers group by Y instead.
- **Variation without unique draw calls:** Same atlas, many atlas coords sharing identical terrain peering + different **probability weights**; or editor **scattering** when painting deco.
- **Alternatives vs random fill:** Godot *alternative tiles* = same atlas cell, different flip/modulate/collision—not a random texture picker. Random looks = multiple tiles (or sources) selected together / probability among matching terrain tiles.
- **Noise usage:** Use value/simplex noise to *choose among* preauthored variants or ecological types (mowed vs tall vs damp)—not to UV-warp atlas samples at runtime (that reintroduces seams).
- **Padding cost:** `use_texture_padding` spends memory/CPU when the atlas source changes; leave on for correctness on villages.

### 6. Godot 4 TileMapLayer / Terrain best practices

From docs + engineer writeups:

1. Save **TileSet as an external `.tres`/`.res`**; reuse across scenes.
2. Prefer **`TileMapLayer` nodes** over deprecated `TileMap`.
3. Build **complete enough peering** for every transition you paint (`set_cells_terrain_connect` / `path` require combinations to exist).
4. Use **Connect** for blobs of grass/dirt; **Path** for roads/rivers-as-strokes that must stay separate when adjacent.
5. Leave **`use_texture_padding` on**; Nearest + integer zoom for pixel art.
6. Randomize with **tile probability** + multi-select / scatter—not only alternatives.
7. Patterns live in the **TileSet**, so share plaza motifs across maps.
8. Bake navigation off the visual layers when path quality matters.

---

## Formulas

### Edge bitmask (4-bit)

```text
mask = N*1 + E*2 + S*4 + W*8    # neighbor present ⇒ 1
# → atlas index via lookup[mask]  (16 entries)
```

### Blob / 47-tile reduction (8-bit)

```text
# bits: N, NE, E, SE, S, SW, W, NW
# then clear diagonal bits unless both adjacent cardinals are set
# e.g. NE := NE AND N AND E
# map remaining masks → ≤47 authored tiles (Hamming-nearest if incomplete)
```

### Wang corner pack (2 terrains → 16)

```text
key = TL | (TR<<1) | (BR<<2) | (BL<<3)   # or more bits per terrain id
tile = wangTable[key]
```

### Sine-generated meander (PlayTechs / classic)

```text
# arc parameter t, step length ds, amplitude ω
θ = ω * sin(t)
x += ds * cos(θ)
y += ds * sin(θ)
t += dt
```

Vary `ω` along the river for less periodic look.

### Bearing line + noise meander (heightfield / mask)

```text
# along = projection onto river bearing
# across = signed distance to bearing line
across' = across - meanderAmp * (noise1D(along) - 0.5)
water   = abs(across') < halfWidth(along)
```

### Bank / damp ring (tile grid)

```text
water(c) = mask[c]
bank(c)  = !water(c) && any_4_or_8_neighbor water
# paint damp / reed tiles on bank(c)
```

### Drainage sketch (mapgen4-scale)

```text
assignDownslope(elevation) → each cell points downhill
assignFlow(moisture): post-order accumulate tributaries
draw river where flow > threshold; width ∝ log(flow) or Strahler
```

Small elevation noise “hills” exist mainly so channels **meander**, not so mountains read clearly.

### Godot terrain paint (runtime)

```gdscript
layer.set_cells_terrain_connect(cells, terrain_set, terrain, true)
layer.set_cells_terrain_path(path_cells, terrain_set, terrain, true)
```

Requires TileSet peering completeness.

### Probability among matching tiles

```text
# weight w_i on each tile that satisfies peering
P(i) ∝ w_i     # Godot/Tiled "probability" is a weight, not %
```

---

## Anti-patterns

| Anti-pattern | Why it fails | Prefer |
| --- | --- | --- |
| Straight `Rect2i` canal as “river” | Reads as UI bar, not geography | Meander mask + bank ring |
| One grass tile everywhere | Monotone “carpet”; seams read louder | Ecological types + probability variants |
| Vignette AI swatches as fill | Permanent art seams | Wrap-matched generation / crop / terrains for edges only |
| Linear filter + non-integer zoom on atlases | Hairline bleed | Nearest + snap; keep texture padding |
| Disabling padding “for perf” early | Visual bugs dominate | Pad on; optimize later |
| Incomplete 47-set then surprise paint | Wrong corners / empty peering | Patterns checklist; Hamming fallback only as last resort |
| Connect-mode on all roads | Adjacent roads fuse into one blob | Path mode / separate terrain |
| Mixing all materials in one terrain set | Explosive tile count / impossible transitions | Separate sets; layer paths over ground |
| Navigation on every TileMapLayer | Merge errors, bad paths | Bake `NavigationRegion2D` |
| Using alternatives as random textures | Alternatives ≠ different atlas art | Extra atlas tiles + probability |
| Full hydrology for a plaza vignette | Cost and control loss | Sine/noise mask + authored bridge band |
| Deco on ground layer | Hard to clear / regen; collision confusion | Dedicated deco layer + scatter |
| Assuming editor look = runtime | Import filter/mip differ | Reimport; test in running scene |

---

## Tooling

| Tool | Role |
| --- | --- |
| **Godot 4 TileSet / TileMapLayer editor** | Terrains paint (Connect/Path), probability, patterns, scattering |
| **Tiled** | Terrain Sets (Corner/Edge/Mixed), probability, transform-as-variation; export to engines |
| **Python / ImageMagick atlas scripts** | Wrap-match tiles, extrude padding, strip vignettes (e.g. Dream `make_seamless_terrain.py`) |
| **Red Blob mapgen4 / river notes** | Drainage, flow width, river representation experiments |
| **Bitmask template generators** | 16- / 47-tile layout sheets for art pipelines |
| **GDC (constraint / WFC talks)** | When tile adjacency is a *constraint* problem (ruins, rooms)—overkill for village grass, useful for plaza props/layouts |

**Dream-local (already aligned):**

- `dream/docs/SEAMLESS.md` — wrap tiles, ecological types, padding + Nearest, meander river.
- `dream/docs/LAYOUT.md` — water mask rules, bank damp, no trees in water, bridge band.

---

## Sources

### Official / primary docs

- [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) — terrain sets, peering bits, texture padding, alternatives.
- [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) — multiple `TileMapLayer`, terrains Connect/Path, scattering, patterns, quadrant rendering, navigation caveats.
- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html) — `set_cells_terrain_connect` / `set_cells_terrain_path`.
- [TileSetAtlasSource](https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html) — `use_texture_padding`.
- [Tiled: Using Terrains](https://doc.mapeditor.org/en/stable/manual/terrain/) — Corner/Edge/Mixed, probability, transforms.

### Engineer blogs & references

- [Red Blob: Procedural river drainage basins](https://www.redblobgames.com/x/1723-procedural-river-growing/) — basin trees, Strahler, designer-directed rivers.
- [Red Blob: mapgen4](https://www.redblobgames.com/maps/mapgen4/) — flow accumulation, meander via elevation noise.
- [Red Blob: Mapgen4 river shader](https://www.redblobgames.com/blog/2025-09-30-mapgen4-river-shader/) — bank curves / rendering (not tile masks).
- [Red Blob: Autotiling interactive guide](https://www.redblobgames.com/articles/autotile/claude/) — bitmasks, Wang, dual-grid, blob 47.
- [PlayTechs: sine-generated meander curves](http://playtechs.blogspot.com/2008/07/) — classic `θ = ω sin(s)` river paths.
- [Envato Tuts+: Tile bitmasking](https://code.tutsplus.com/how-to-use-tile-bitmasking-to-auto-tile-your-level-layouts--cms-25673t) — 16 vs ~48, dynamic retile locality.
- [Imaginary Robots: Godot 4 tileset terrain](https://www.imaginaryrobots.net/posts/2023-07-28-godot-4-tileset-terrain/) — Connect vs Path practice notes.
- [Godot issue #26734](https://github.com/godotengine/godot/issues/26734) — filter/zoom tile seams discussion.
- Atlas bleed hygiene (general): [Bugnet — texture bleeding / padding / mips](https://bugnet.io/blog/how-to-fix-texture-bleeding-and-seams-in-an-atlas).

### Talks (GDC Vault — tile adjacency / procgen; free when Vault marks free)

- [Brian Bucklew — Tile-Based Map Generation using WFC in *Caves of Qud*](https://www.gdcvault.com/play/1026263/Math-for-Game-Developers-Tile) — multi-pass structure then constraint fill.
- [Seth Cooper — Beyond WaveFunctionCollapse: Constraint-Based Tile Map Generation](https://www.gdcvault.com/play/1028723/AI-Summit-Beyond-WaveFunctionCollapse-Constraint) — editable constraint maps.

*(Use WFC/constraints for prop/plaza grammar; use Terrains + masks for ground/water.)*

---

## 10 transferable rules for Dream (Godot village)

1. **Meander the water mask** (sine or noise-offset polyline)—never a straight rectangle canal.
2. **Bank cells get damp/reed ecology**; dry fill never sits under water; trees stay on land footprints.
3. **Layer stack:** ground → path/plaza → water → deco (and overhead if needed); clear/regenerate per layer.
4. **Wrap-match fill tiles** (`L==R`, `T==B`); strip vignette pads before atlas import.
5. **Keep `use_texture_padding` + Nearest**; snap camera zoom to integers when testing seams.
6. **Ecological variants via noise/distance fields** (mowed near roads, tall at edges, damp at banks)—not one grass ID.
7. **Probability-weighted atlas variants** for the same terrain peering; reserve alternatives for flip/modulate.
8. **Roads/plaza: Path-style logic**; grass/dirt blobs: Connect-style—don’t force one peering mode for everything.
9. **Bridge as an authored band** across the meander; west road stops before water except on that band.
10. **Incomplete terrain peering is a bug**, not a style—author required transitions before batch `set_cells_terrain_*`.

---

*Compiled for Dream village terrain work. Prefer primary docs above when engine APIs drift.*
