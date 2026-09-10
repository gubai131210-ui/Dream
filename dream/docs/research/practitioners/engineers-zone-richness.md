# Engineers on Zone Richness (Ground / Water / Props by Region Type)

Cross-engine practitioner notes for Dream (Godot 4 village ring). Focus: **math that makes plaza ≠ residential ≠ farm ≠ market look different**, not just “pretty tiles everywhere.”

**Companion (do not duplicate):** [`engineers-tilemap-terrain.md`](engineers-tilemap-terrain.md) — autotile/Wang/bitmask authoring, seamless atlas hygiene, layered `TileMapLayer`, Godot Terrains Connect/Path, bank rings.

**In-repo anchors:** [`SEAMLESS.md`](../../SEAMLESS.md) (ecological types), [`LAYOUT.md`](../../LAYOUT.md) (meander + bank), `village_square_assembler.gd` (`_build_path_distance_field` + `_paint_ecological_grass`).

---

## Thesis

| Layer | Shared math | Zone-differentiated knobs |
| --- | --- | --- |
| Ground fill | Distance fields + noise → ecological tile kind | Thresholds, variant weights, terrace/grid strength |
| Water | Meander centerline → mask → bank | Width, ω, irrigation vs scenic, bridge rules |
| Transitions | Bitmask / Wang / Godot Terrains | **Which materials may blend** per zone |
| Props / deco | Poisson disk / blue-noise peaks | `r_min`, density, exclusion masks, grid snap |

Rule of thumb: **one pipeline, many `ZoneParams` resources** — never copy-paste a second assembler that reimplements BFS + noise.

---

## 1. Distance fields (multi-source BFS)

### Claims

| Claim | Source |
| --- | --- |
| Multi-source BFS yields a distance-to-nearest-seed field in one pass (obstacles, walls, paths, coasts as seeds). | [Red Blob: BFS multiple start points](https://www.redblobgames.com/pathfinding/distance-to-any/) |
| Separate fields can be combined with `min` / `max` / `sum` / `diff` for influence-style analysis without recomputing each toggle. | Same |
| Graph distance fields from designer seeds (mountains / boundary / coast) drive elevation via scale-free blends such as `B/(A+B)` and harmonic means. | [Red Blob: Elevation control / distance fields](https://www.redblobgames.com/x/1728-elevation-control/) |
| Mapgen4 uses peak / coast / range distance fields (BFS with optional jagged increments) as primary elevation structure, not pure noise mountains. | [mapgen4](https://www.redblobgames.com/maps/mapgen4/), [Blobs: elevation painting](https://simblob.blogspot.com/2018/09/mapgen4-elevation-painting.html) |
| Island shaping mixes noise elevation with a normalized border-distance `d` (e.g. square-bump / Euclidean²). | [Red Blob: Terrain from noise — Islands](https://www.redblobgames.com/maps/terrain-from-noise/) |
| Dream already multi-sources walk surfaces at distance 0 and floods grass cells for ecology. | `village_square_assembler.gd` `_build_path_distance_field` |

### Zone use (Dream)

| Seed set | Field | Plaza | Residential | Farm | Market street |
| --- | --- | --- | --- | --- | --- |
| Stone / cobble / dirt walk | `d_path` | Tight mowed ring (≤2) | Softer mowed (≤3), yard meadow | Dirt lanes only; crops ignore mow | Narrow street mow; alcoves meadow |
| Water cells | `d_water` | Bank damp ≤1 | Same | Irrigation damp ≤1–2 | Rare; puddles optional |
| Map / fence edge | `d_edge` | Tall fringe | Tall in back lots | Tall outside fence | Tall behind stalls |
| Building footprints | `d_build` | Hard exclude props | Soft apron dirt | Shed hub clear | Stall clear |

### GDScript — multi-source distance field

```gdscript
## seeds: cells at distance 0 (paths, water, etc.). Returns PackedInt32Array row-major, INF = unset.
func build_distance_field(w: int, h: int, seeds: Array[Vector2i], blocked: Callable = Callable()) -> PackedInt32Array:
	var INF := 1_000_000
	var dist := PackedInt32Array()
	dist.resize(w * h)
	dist.fill(INF)
	var q: Array[Vector2i] = []
	for s in seeds:
		if s.x < 0 or s.y < 0 or s.x >= w or s.y >= h:
			continue
		var i := s.y * w + s.x
		dist[i] = 0
		q.append(s)
	var head := 0
	var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while head < q.size():
		var p: Vector2i = q[head]
		head += 1
		var pd: int = dist[p.y * w + p.x]
		for d in dirs:
			var n: Vector2i = p + d
			if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
				continue
			if blocked.is_valid() and blocked.call(n):
				continue
			var ni := n.y * w + n.x
			var nd := pd + 1
			if nd < dist[ni]:
				dist[ni] = nd
				q.append(n)
	return dist


func combine_min(a: PackedInt32Array, b: PackedInt32Array) -> PackedInt32Array:
	var out := PackedInt32Array()
	out.resize(a.size())
	for i in a.size():
		out[i] = mini(a[i], b[i])
	return out
```

Optional Euclidean refinement (slow, rare at village scale): after BFS, store seed id and re-measure `position.distance_to(seed_pos)` — see EDT survey linked from Red Blob’s distance page.

---

## 2. Noise layers (octaves, roles, zone params)

### Claims

| Claim | Source |
| --- | --- |
| Frequency / wavelength sets feature size; octaves sum scaled noise (`1 + ½ + ¼…`) then normalize by amplitude sum. | [Red Blob: Terrain from noise](https://www.redblobgames.com/maps/terrain-from-noise/) |
| Offset or reseed each octave so layers are independent (avoid correlated peaks at origin). | Same |
| Biomes need **≥2 fields** (e.g. elevation + moisture); thresholds are project-tuned, not universal. | Same (Biomes / Whittaker) |
| High-frequency “blue” noise + local maxima ≈ irregular object sites (cheap tree scatter without full Poisson). | Same (Tree placement) |
| Godot `FastNoiseLite`: Simplex/Perlin/Cellular, fractal FBM/Ridged, `domain_warp_*` warps sample domain. | [Godot FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) |
| `NoiseTexture2D` can bake noise (optional `seamless`); await `changed` before `get_image()`. | [Godot NoiseTexture2D](https://docs.godotengine.org/en/stable/classes/class_noisetexture2d.html) |
| Gradient / Perlin construction and lattice artifacts are classical; Simplex reduces directional bias. | [Catlike Coding: Perlin noise](https://catlikecoding.com/unity/tutorials/pseudorandom-noise/perlin-noise/) |

### Layer roles for villages (not continents)

| Layer | Typical freq (tile space) | Plaza | Residential yard | Farm field | Market |
| --- | --- | --- | --- | --- | --- |
| `n_macro` | low (~0.02–0.05) | Mild plaza wear mottling | Yard “personality” patches | Field fertility strips | Alcove clutter bias |
| `n_micro` | high (~0.15–0.4) | Pick among stone cracks / mowed variants | Weed vs meadow | Crop row noise **off** or tiny | Crate vs barrel bias |
| `n_warp` | domain warp amp small | Optional cobble swirl | Soften yard blobs | **Disable** (reads messy on crops) | Optional |
| `n_moisture` | mid | Unused or fountain splash | Unused | Irrigation stain near canals | Unused |

**Do not** UV-warp atlas samples with noise (reintroduces seams — see companion doc). Use noise only to **choose** preauthored tile/prop variants.

### GDScript — zone-parameterized noise stack

```gdscript
class_name ZoneNoiseStack
extends RefCounted

var macro := FastNoiseLite.new()
var micro := FastNoiseLite.new()
var moisture := FastNoiseLite.new()

func configure(zone: StringName, seed: int) -> void:
	macro.seed = seed
	micro.seed = seed + 17
	moisture.seed = seed + 91
	macro.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	micro.noise_type = FastNoiseLite.TYPE_SIMPLEX
	moisture.noise_type = FastNoiseLite.TYPE_SIMPLEX
	macro.fractal_type = FastNoiseLite.FRACTAL_FBM
	macro.fractal_octaves = 3
	match zone:
		&"plaza":
			macro.frequency = 0.04
			micro.frequency = 0.22
			macro.domain_warp_enabled = false
		&"residential":
			macro.frequency = 0.035
			micro.frequency = 0.18
			macro.domain_warp_enabled = true
			macro.domain_warp_amplitude = 8.0
			macro.domain_warp_frequency = 0.03
		&"farm":
			macro.frequency = 0.025
			micro.frequency = 0.12
			macro.domain_warp_enabled = false  # keep plots readable
			moisture.frequency = 0.05
		&"market":
			macro.frequency = 0.05
			micro.frequency = 0.28
			macro.domain_warp_enabled = false
		_:
			macro.frequency = 0.04
			micro.frequency = 0.2


func sample01(n: FastNoiseLite, p: Vector2) -> float:
	return clampf(0.5 * (n.get_noise_2d(p.x, p.y) + 1.0), 0.0, 1.0)


## Classic octave mix when you need an explicit FBM without fractal_type (teaching form).
func fbm_manual(n: FastNoiseLite, p: Vector2, octaves: int = 3) -> float:
	var amp := 1.0
	var freq := 1.0
	var sum := 0.0
	var norm := 0.0
	var base_f := n.frequency
	for i in octaves:
		n.frequency = base_f * freq
		# offset per octave → independence (Red Blob)
		var o := Vector2(i * 19.7, i * 31.3)
		sum += amp * sample01(n, p * freq + o)
		norm += amp
		amp *= 0.5
		freq *= 2.0
	n.frequency = base_f
	return sum / maxf(norm, 0.001)
```

---

## 3. Wang tiles & bitmask — zone-scoped (cross-ref)

Full tables live in [`engineers-tilemap-terrain.md`](engineers-tilemap-terrain.md). Here only **region differentiation**:

### Claims

| Claim | Source |
| --- | --- |
| 4-bit edge → 16 tiles; 8-bit blob with diagonal rule → 47; dual-grid / Wang corner colors → 16 for two terrains. | [Red Blob-inspired autotile guide](https://www.redblobgames.com/articles/autotile/claude/) |
| Godot Terrains: Match Corners and Sides / Corners / Sides; Connect vs Path peering. | [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) |
| Tiled Corner/Edge/Mixed terrain sets mirror the same math. | [Tiled Terrains](https://doc.mapeditor.org/en/stable/manual/terrain/) |

### Zone practice

| Zone | Terrain set policy | Why |
| --- | --- | --- |
| Plaza | Stone ↔ dirt **Path** mode; stone never Wang-blends into river | Adjacent roads must not fuse; civic materials stay crisp |
| Residential | Grass ↔ dirt **Connect**; yard dirt spurs Path | Soft organic yards |
| Farm | Dirt ↔ mud Connect on banks; **crop plots are not terrain-blended** (grid stamps) | Readable rectangles beat blob blends |
| Market | Cobble Path along street; alcove dirt separate | Long street must not merge into side pads |

```gdscript
## Pseudocode: pick terrain paint mode from zone, not from material alone.
func paint_zone_paths(layer: TileMapLayer, cells: Array[Vector2i], zone: StringName, terrain_set: int, terrain: int) -> void:
	match zone:
		&"plaza", &"market", &"farm_lane":
			layer.set_cells_terrain_path(cells, terrain_set, terrain, true)
		&"residential_yard", &"meadow_blob":
			layer.set_cells_terrain_connect(cells, terrain_set, terrain, true)
```

---

## 4. Meander rivers — scenic vs irrigation

### Claims

| Claim | Source |
| --- | --- |
| Sine-generated meander: direction angle `θ = ω · sin(s)` integrated along arc length. | [PlayTechs: A River Runs Through It](http://playtechs.blogspot.com/2008/07/river-runs-through-it.html) |
| Village-scale: mask from meander polyline + bank ring; full drainage only at continent scale. | Companion doc + [mapgen4](https://www.redblobgames.com/maps/mapgen4/) |
| Drainage basins via BFS/tree growth + Strahler widths; designer sketch can bias growth. | [Red Blob: Procedural river drainage](https://www.redblobgames.com/x/1723-procedural-river-growing/) |
| Dream LAYOUT: ~3–5 tile corridor, damp bank, bridge band — not `Rect2i` canals. | [`LAYOUT.md`](../../LAYOUT.md) |

### Zone knobs

| Knob | Plaza / village square | Farm irrigation | Market |
| --- | --- | --- | --- |
| `ω` (meander amp) | Medium–high (scenic) | Low–medium (readable plots) | Usually none |
| Half-width | 1.5–2.5 tiles | 1.0–1.5 + side ditches | — |
| Bank ecology | damp + reeds | damp + mud; crops excluded | — |
| Bridges | Authored band | Frequent small footbridges | — |

### GDScript — meander mask + zone width

```gdscript
func meander_polyline(origin: Vector2, bearing: float, length: float, omega: float, ds: float = 0.5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var p := origin
	var s := 0.0
	while s < length:
		var theta := bearing + omega * sin(s)  # PlayTechs meander curve
		p += Vector2(cos(theta), sin(theta)) * ds
		pts.append(p)
		s += ds
	return pts


func rasterize_river(mask: PackedByteArray, w: int, h: int, centerline: PackedVector2Array, half_width: float) -> void:
	# For each cell center, min distance to segments; water if dist < half_width.
	for y in h:
		for x in w:
			var c := Vector2(x + 0.5, y + 0.5)
			var d := _dist_to_polyline(c, centerline)
			if d < half_width:
				mask[y * w + x] = 1


func bank_from_water(water: PackedByteArray, w: int, h: int) -> PackedByteArray:
	var bank := PackedByteArray()
	bank.resize(w * h)
	var dirs := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for y in h:
		for x in w:
			var i := y * w + x
			if water[i] != 0:
				continue
			for d in dirs:
				var n := Vector2i(x, y) + d
				if n.x < 0 or n.y < 0 or n.x >= w or n.y >= h:
					continue
				if water[n.y * w + n.x] != 0:
					bank[i] = 1
					break
	return bank
```

Noise-offset alternative (when polyline is authored):  
`across' = across - meander_amp * (noise1D(along) - 0.5)` — see companion Formulas.

---

## 5. Poisson disk props (and blue-noise fallback)

### Claims

| Claim | Source |
| --- | --- |
| Bridson: O(N) Poisson-disk via active list + annulus samples in `[r, 2r]` with background grid cell ≤ `r/√n`; typical `k ≈ 30`. | [Bridson SIGGRAPH 2007 PDF](https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf) |
| Variable radius extends packing for mixed prop sizes. | [Variable Poisson sampler writeup](https://www.vertexfragment.com/ramblings/variable-density-poisson-sampler) |
| AutoBiomes: Poisson-/dart-style placement with per-asset repel distance, size tiers (large first). | [AutoBiomes (CGI 2020)](https://cgvr.cs.uni-bremen.de/papers/cgi20/AutoBiomes.pdf) |
| Production foliage graphs exclude roads via spline/path distance, then densify roadside strips. | UE PCG practice summaries (e.g. spline distance → filter); same **math** as Dream `d_path` |
| Cheap alternative: high-freq noise local maxima in radius `R`. | [Red Blob tree placement](https://www.redblobgames.com/maps/terrain-from-noise/) |

### Zone `r_min` / density

| Zone | Props | `r_min` (tiles) | Extra filters |
| --- | --- | --- | --- |
| Plaza | benches, fountain satellites | 2.5–4 | `d_path == 0` stone only; civic whitelist |
| Residential | barrels, flowers, laundry | 1.5–2.5 | plantable grass; not under AABB |
| Farm | scarecrows, tools, sparse weeds | 3–5 outside plots; **0 inside grid** (snap) | exclude crop cells |
| Market | crates, barrels, lamps | 1.2–2 along street edge | alcoves denser (`r`↓) |

### GDScript — Bridson 2D (tile/world units)

```gdscript
func poisson_disk(rect: Rect2, r: float, k: int = 30, rng: RandomNumberGenerator = null) -> PackedVector2Array:
	if rng == null:
		rng = RandomNumberGenerator.new()
	var cell := r / sqrt(2.0)
	var gw := int(ceil(rect.size.x / cell))
	var gh := int(ceil(rect.size.y / cell))
	var grid: Array = []  # Vector2 or null
	grid.resize(gw * gh)
	for i in grid.size():
		grid[i] = null
	var samples := PackedVector2Array()
	var active: Array[Vector2] = []
	var x0 := Vector2(rng.randf_range(rect.position.x, rect.end.x), rng.randf_range(rect.position.y, rect.end.y))
	samples.append(x0)
	active.append(x0)
	grid[_cell_index(x0, rect, cell, gw)] = x0
	while not active.is_empty():
		var ai := rng.randi_range(0, active.size() - 1)
		var xi: Vector2 = active[ai]
		var found := false
		for _attempt in k:
			var ang := rng.randf() * TAU
			var rad := rng.randf_range(r, 2.0 * r)
			var cand: Vector2 = xi + Vector2(cos(ang), sin(ang)) * rad
			if not rect.has_point(cand):
				continue
			if _far_enough(cand, grid, rect, cell, gw, gh, r):
				samples.append(cand)
				active.append(cand)
				grid[_cell_index(cand, rect, cell, gw)] = cand
				found = true
				break
		if not found:
			active.remove_at(ai)
	return samples


func _cell_index(p: Vector2, rect: Rect2, cell: float, gw: int) -> int:
	var lx := int((p.x - rect.position.x) / cell)
	var ly := int((p.y - rect.position.y) / cell)
	return ly * gw + lx


func _far_enough(p: Vector2, grid: Array, rect: Rect2, cell: float, gw: int, gh: int, r: float) -> bool:
	var cx := int((p.x - rect.position.x) / cell)
	var cy := int((p.y - rect.position.y) / cell)
	for oy in range(-2, 3):
		for ox in range(-2, 3):
			var nx := cx + ox
			var ny := cy + oy
			if nx < 0 or ny < 0 or nx >= gw or ny >= gh:
				continue
			var other = grid[ny * gw + nx]
			if other != null and p.distance_to(other) < r:
				return false
	return true
```

Post-filter: drop points where `d_path < clear_band`, `water`, or building AABB fails (Dream `_footprint_ok`).

**Blue-noise peaks fallback** (tiny maps / one-shot deco):

```gdscript
func blue_noise_peaks(noise: FastNoiseLite, w: int, h: int, R: int, threshold: float = 0.55) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in h:
		for x in w:
			var v := 0.5 * (noise.get_noise_2d(x, y) + 1.0)
			if v < threshold:
				continue
			var ok := true
			for dy in range(-R, R + 1):
				for dx in range(-R, R + 1):
					if dx == 0 and dy == 0:
						continue
					var nx := x + dx
					var ny := y + dy
					if nx < 0 or ny < 0 or nx >= w or ny >= h:
						continue
					var nv := 0.5 * (noise.get_noise_2d(nx, ny) + 1.0)
					if nv >= v:
						ok = false
						break
				if not ok:
					break
			if ok:
				out.append(Vector2i(x, y))
	return out
```

---

## 6. Ecological zones by distance-to-path

### Claims

| Claim | Source |
| --- | --- |
| Distance-to-path / wall fields are the same multi-source BFS primitive. | [Red Blob distance-to-any](https://www.redblobgames.com/pathfinding/distance-to-any/) |
| Foot-traffic ecology (mowed near roads, tall at edges, damp at banks) is Dream’s documented craft. | [`SEAMLESS.md`](../../SEAMLESS.md), assembler thresholds |
| Road-adjacent clear + roadside densification is standard in large-world foliage graphs. | Production PCG spline-distance filters (pattern match to `d_path`) |

### Dream baseline (plaza) → generalize

Existing plaza logic (paraphrased):

```text
if water/bank → damp
elif d_path ≤ 2 → mowed
elif d_edge ≤ 2 or d_path ≥ 8 → tall
elif rng < 0.05 → weed
else → meadow
(+ micro noise to pick atlas variant)
```

### Per-zone threshold table (suggested starting points)

| Kind | Plaza | Residential | Farm (outside plots) | Market |
| --- | --- | --- | --- | --- |
| mowed if `d_path ≤` | 2 | 3 | 1 (lane only) | 2 |
| tall if `d_path ≥` or edge | 8 / edge≤2 | 10 / edge≤1 | outside fence | 6 behind stalls |
| weed probability | 0.05 | 0.08 | 0.12 fallow | 0.03 |
| damp | bank | bank | bank + ditch | rare |

### GDScript — `ZoneEcoParams` classifier

```gdscript
class_name ZoneEcoParams
extends Resource

@export var mowed_max_path: int = 2
@export var tall_min_path: int = 8
@export var tall_edge_max: int = 2
@export var weed_p: float = 0.05
@export var prefer_meadow: bool = true


func classify(d_path: int, d_edge: int, is_bank: bool, rng: RandomNumberGenerator, micro: float) -> StringName:
	if is_bank:
		return &"damp"
	if d_path <= mowed_max_path:
		return &"mowed"
	if d_edge <= tall_edge_max or d_path >= tall_min_path:
		return &"tall"
	if rng.randf() < weed_p * lerpf(0.5, 1.5, micro):
		return &"weed"
	return &"meadow" if prefer_meadow else &"mowed"
```

Wire: one Resource per area scene (`plaza_eco.tres`, `farm_eco.tres`, …).

---

## 7. Crop plot grids vs organic yards

### Claims

| Claim | Source |
| --- | --- |
| Terracing / quantization `round(e * n) / n` creates readable steps from continuous fields. | [Red Blob: Terraces](https://www.redblobgames.com/maps/terrain-from-noise/) |
| Cellular noise + low jitter → patch/plot-like regions; `cellular_jitter = 0` → even lattice. | [Godot FastNoiseLite cellular](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) |
| Farm gameplay readability wants **explicit rectangles** (≥6 plots in Dream Phase 3), not noise blobs. | [`PHASE3.md`](../../PHASE3.md) A03 |
| Organic yards: distance + domain-warped noise; crops: integer grid stamp + optional micro noise **inside** cells only for soil tint. | Craft consensus (Batch A synthesis) |

### Dual strategy

| | Crop plots | Organic yards |
| --- | --- | --- |
| Structure | `Rect2i` / fence-inset grid, shared lane gutters | Freeform masks, soft edges |
| Grass | Usually dirt / tilled atlas, not meadow Wang | Meadow/weed via eco classifier |
| Props | Snap to plot corners / row midpoints | Poisson with `r_min` |
| Noise | Fertility tint only; **no** domain warp on layout | Macro + light warp OK |
| Water | Straight-ish ditches OK **inside** farm grammar; still avoid map-scale `Rect2i` scenic rivers | Meander scenic river |

### GDScript — plot grid vs yard mask

```gdscript
## Farm: axis-aligned plots with lane thickness.
func build_crop_plots(farm: Rect2i, cols: int, rows: int, lane: int = 1) -> Array[Rect2i]:
	var plots: Array[Rect2i] = []
	var cw := (farm.size.x - lane * (cols + 1)) / cols
	var rh := (farm.size.y - lane * (rows + 1)) / rows
	for j in rows:
		for i in cols:
			var x := farm.position.x + lane + i * (cw + lane)
			var y := farm.position.y + lane + j * (rh + lane)
			plots.append(Rect2i(x, y, cw, rh))
	return plots


func paint_tilled(ground: TileMapLayer, plot: Rect2i, coords: Array[Vector2i], rng: RandomNumberGenerator) -> void:
	for y in range(plot.position.y, plot.end.y):
		for x in range(plot.position.x, plot.end.x):
			ground.set_cell(Vector2i(x, y), 0, coords[rng.randi_range(0, coords.size() - 1)])


## Residential: organic plantable = grass cells passing eco + not path/building.
func organic_yard_cells(eco_kind: PackedStringArray, w: int, h: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in h:
		for x in w:
			var k: StringName = eco_kind[y * w + x]
			if k == &"meadow" or k == &"weed" or k == &"mowed":
				cells.append(Vector2i(x, y))
	return cells
```

Optional “soft terrace” for decorative garden beds (not gameplay crops):

```gdscript
func terrace01(v: float, levels: int) -> float:
	return roundf(v * float(levels)) / float(levels)
```

---

## 8. End-to-end pass order (zone-aware)

Align with [`LAYOUT.md`](../../LAYOUT.md), parameterized:

```text
1. zone mask / fence / play AABB
2. water meander (zone ω, width) → bank
3. paths / plaza / dirt lanes (Path vs Connect)
4. distance fields: path, water, edge, buildings
5. ecological grass via ZoneEcoParams + ZoneNoiseStack
6. farm: stamp crop grids OR residential: organic yards
7. buildings (full sprite AABB ⊆ build zone)
8. Poisson / blue-noise props with zone r_min + exclusions
9. trees (land only, footprint OK)
10. actors / overlays (water shimmer on water cells)
```

---

## Anti-patterns (zone richness)

| Anti-pattern | Why it fails | Prefer |
| --- | --- | --- |
| One global `d_path ≤ 2 → mowed` for farm + plaza | Farms look suburban-mowed | Per-zone `ZoneEcoParams` |
| Domain-warped noise on crop layout | Plots unreadable | Grid stamp; noise only as tint |
| Poisson crates on plaza center | Blocks NPC graph / fountain | Civic slots + edge strip sample |
| Wang-blending plaza stone into river | Illegal transitions / tile explosion | Separate terrain sets + layers |
| Continent drainage for a 32×32 farm ditch | Cost + loss of designer control | Low-ω meander or authored ditch |
| Uniform `r_min` for trees and flowers | Clumping or barren | Size-tiered / variable-radius Poisson |
| Random `randf` prop positions | Overlap, clusters | Bridson or blue-noise peaks |
| Duplicating BFS in every assembler | Drift between areas | Shared `DistanceField` util + Resources |

---

## Tooling

| Tool | Role |
| --- | --- |
| Godot `FastNoiseLite` / `NoiseTexture2D` | Octave stacks, cellular plots, domain warp |
| Shared GDScript util (`DistanceField`, `PoissonDisk2D`, `Meander`) | One implementation, many zones |
| `ZoneEcoParams` / `ZoneNoiseStack` Resources | Plaza vs farm knobs without code forks |
| Python (`make_seamless_terrain.py`) | Bake ecological atlas variants offline |
| Red Blob demos / mapgen4 | Validate distance + river intuition |
| Bridson PDF | Canonical Poisson reference |

---

## Sources

### Official / primary

- [Godot FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) — noise types, fractal, domain warp, cellular jitter.
- [Godot NoiseTexture2D](https://docs.godotengine.org/en/stable/classes/class_noisetexture2d.html) — baked noise textures / seamless note.
- [Godot Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) — terrains / peering (zone-scoped use).
- [Godot Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) — multi-layer stack, Connect/Path.
- [Tiled Using Terrains](https://doc.mapeditor.org/en/stable/manual/terrain/) — Corner/Edge/Mixed.
- [Bridson — Fast Poisson Disk Sampling (SIGGRAPH 2007)](https://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf)

### Red Blob / Amitp

- [Terrain from noise](https://www.redblobgames.com/maps/terrain-from-noise/) — octaves, biomes, islands, terraces, tree peaks.
- [Noise introduction](https://www.redblobgames.com/articles/noise/introduction.html) — frequency / amplitude vocabulary.
- [BFS multiple starts / distance fields](https://www.redblobgames.com/pathfinding/distance-to-any/)
- [Elevation control with distance fields](https://www.redblobgames.com/x/1728-elevation-control/)
- [Procedural river drainage basins](https://www.redblobgames.com/x/1723-procedural-river-growing/)
- [mapgen4](https://www.redblobgames.com/maps/mapgen4/)
- [Autotiling interactive guide](https://www.redblobgames.com/articles/autotile/claude/) — bitmask / Wang / dual-grid.

### Other engineer writing

- [PlayTechs — sine meander rivers](http://playtechs.blogspot.com/2008/07/river-runs-through-it.html)
- [Catlike Coding — Perlin / gradient noise](https://catlikecoding.com/unity/tutorials/pseudorandom-noise/perlin-noise/)
- [Vertex Fragment — variable-density Poisson](https://www.vertexfragment.com/ramblings/variable-density-poisson-sampler)
- [AutoBiomes paper](https://cgvr.cs.uni-bremen.de/papers/cgi20/AutoBiomes.pdf) — multi-biome asset rules + Poisson-like darting.
- Companion: [`engineers-tilemap-terrain.md`](engineers-tilemap-terrain.md)

### Talks / large-world placement (pattern transfer)

- GDC Vault constraint / WFC tile talks (plaza prop grammar) — see companion Sources; overkill for grass, useful for stall layouts.
- UE PCG spline-distance foliage recipes — same distance-to-path exclusion/enrichment idea as Dream ecology.

---

## 10 transferable rules for Dream zones

1. **Parameterize, don’t fork** — `ZoneEcoParams` + `ZoneNoiseStack` per area; shared BFS/Poisson/meander utils.
2. **Multi-source distance fields** for path, water, edge, buildings — then classify ecology.
3. **Noise chooses variants**, never warps atlas UVs; disable domain warp on crop layouts.
4. **Meander ω/width by zone** — scenic village river ≠ farm irrigation ditch.
5. **Wang/Terrains sets are zone-scoped** — Path for streets, Connect for yards; never blend plaza stone into water.
6. **Poisson (or blue-noise peaks) for organic props**; **grid snap for crops and stalls**.
7. **Size-tier placement** — large props first, smaller respect larger `r`.
8. **Crop = Rect2i grammar**; **yard = distance + meadow/weed**.
9. **Exclude before densify** — clear `d_path` band, then optional roadside flower strip.
10. **Keep companion seam/terrain hygiene** — padding, Nearest, wrap tiles — richness dies if seams shout louder than ecology.

---

*Compiled for Dream village-ring zone differentiation. Prefer primary URLs above when APIs drift. Cross-check autotile/seam details in `engineers-tilemap-terrain.md`.*
