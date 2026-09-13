# Wind + waterfall presentation research (2026-09-13)

## Wind sway (trees / flowers / crops)

Primary references used in `shaders/wind_sway_2d.gdshader` + `scripts/env/wind_sway.gd`:

1. [2D wind sway (Maujoe / HungryProton)](https://godotshaders.com/shader/2d-wind-sway/) — `VERTEX.x += sin/cos * strength * max(0, 1-uv.y - heightOffset)`
2. [2D Pixel perfect wind & sway](https://godotshaders.com/shader/2d-pixel-perfect-wind-sway-effect/) — snap displacement to texel grid to avoid blurry sub-pixel wobble on nearest sprites
3. GDQuest grass wind demos — UV.y falloff keeps feet planted

**Why previous skew tweens looked bad:** whole-sprite `Node2D.skew` rotates the silhouette like a card; trunks and pots slid. Vertex UV falloff only moves the crown.

**Policy:** one `ShaderMaterial` per instance (unique `phase_offset`); no per-sprite Tweens for wind.

## Waterfall abruptness

Grammar (SLYNYRD / Animal Crossing cliff-mouth): **rock amphitheater → ledge lip → narrow cascade → splash → mist veil → pool**.

Previous assembly spawned only a tall water billboard on grass (cliff helpers existed but were unused / QA-blocked).

Current assembly (`waterfall_assembler.gd`):

1. `_spawn_cliff_frame` — cliff + rim rocks + `CascadeLedge` lip
2. `_spawn_waterfall` — narrower `WaterfallAnim` (0.42×0.5) + splash, soft alpha reveal ~0.85s
3. `_spawn_cascade_veil` — mist framing with delayed fade-in (not a second water clock)

Water tile shimmer left unchanged (user OK).
