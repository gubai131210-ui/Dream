# Practitioners: tiled scene asset pipeline

Techniques distilled from pixel / environment educators and engine docs for **top-down & platformer tiled scenes**. Focus is method, not personalities.

**Scope:** draw order, repeating tiles, building sheets, water + foam, sheet cutting / padding / pivots.

---

## Pipeline steps

### 1. Readability stack (per sprite / tile region)

Industry-common paint order for game sprites (Saultoons → GameMaker writeup; Pixel Logic Ch.4):

| Pass | Goal | Technique |
|------|------|-----------|
| **Silhouette** | Readable shape at thumbnail size | Flat mass first; head/limbs/function must read in pure black/white |
| **Value** | Volume & separation | Light vs dark before hue; dark fills mass, light picks form |
| **Color** | Hue / material identity | Limited palette; main + secondary colors for recognition |
| **Detail** | Texture, AA, dither, accents | Last; never sacrifice silhouette for micro-detail |

Sources: [GameMaker — How To Make Pixel Art For 2D Games](https://gamemaker.io/en/blog/make-pixel-art-2d-games) (silhouette → cleanup → color → outline); [Pixel Logic — readability / silhouettes](https://pixellogicbook.com) (Ch.4: rough silhouette then fill; contrast when features overlap); [Lospec — Pixel Art Outlines](https://lospec.com/articles/pixel-art-outlines/) (outline after shape; omit outline at ground contact so feet don’t float).

### 2. Scene assembly order: tiles first vs props first

**Production order (recommended for tiled maps):**

1. **Lock tile size + perspective** (e.g. 16×16 top-down, light from one quadrant).
2. **Base filler tiles** that wrap on all four edges (`L==R`, `T==B`).
3. **Edges → outer corners → inner corners** (autotile / terrain set).
4. **Transition tiles** between biomes (grass↔dirt, dirt↔water).
5. **Props / buildings** as modular sheets on top of ground (Y-sort or dedicated object layer).
6. **FX overlays** (shadows, foam, sparkle) as thin layers.

**Why tiles before props:** ground must tile and contrast first; props inherit the same light, scale, and contact shadows. Drawing hero props on a blank canvas often produces wrong scale and floating feet.

**Why props can lead in concept art:** mood boards / hero buildings may be sketched first for style, then *decomposed* into tiles — but shipping assets still go filler → edges → corners → props.

Sources: [SLYNYRD Pixelblog 43 — Top Down Tiles Part 2](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2) (base loop → side/corner by shaving; layer textures); [Sandro Maglione — Pixel Art Tileset Guide](https://www.sandromaglione.com/articles/how-to-create-a-pixel-art-tileset-complete-guide) (center tile → borders → corners → inner corners); project note [SEAMLESS.md](../../SEAMLESS.md) (fill types before deco).

### 3. Export / engine handoff

1. Author in tile-aware editor (Aseprite tile mode / Pyxel Edit) with live wrap preview.
2. Export atlas with **extrude / padding** if needed; keep alpha real (no painted checker).
3. Engine: Nearest filter, integer zoom, texture padding on atlases.
4. Tall props: texture origin / Y-sort at **feet** (ground contact), not visual center.

Sources: [Aseprite CLI — padding / extrude](https://www.aseprite.org/docs/cli/); [Godot TileSetAtlasSource.use_texture_padding](https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html); [Godot Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) (texture origin, Y sort origin).

---

## Tile design rules

### Designing knowing it will repeat

1. **Center / filler first** — must connect to itself in 8 directions; hide the grid by even visual balance and consistent cluster size ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2); [Maglione](https://www.sandromaglione.com/articles/how-to-create-a-pixel-art-tileset-complete-guide)).
2. **No unique landmark on one edge** — a bright rock only on the left edge becomes a stamp every N tiles. Prefer mid-tone noise; put landmarks on **prop** layers.
3. **Wrap-match edges** — left column == right column, top row == bottom row (same idea as Dream’s seamless terrain tool).
4. **Derive edges from filler** — shave / mask the base texture for N/E/S/W edges rather than redrawing from scratch ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)).
5. **Outer vs inner corners** — outer corners close islands; **inner (concave) corners** are the #1 missing piece that makes terrain look broken ([Maglione](https://www.sandromaglione.com/articles/how-to-create-a-pixel-art-tileset-complete-guide); Godot terrain docs / bitmask practice).
6. **Variants for filler only** — 2–5 filler variants beat unique art for every bitmask cell; rare configs can reuse sub-tiles ([Maglione](https://www.sandromaglione.com/articles/how-to-create-a-pixel-art-tileset-complete-guide)).
7. **Minimal template → full blob** — draw interior + inner-corner cross + island corners, compose 15/16/47 layouts (AutoBlob / Wang / Godot Match Corners and Sides). See [AutoBlob](https://violetpixel13.itch.io/autoblob), [SpriteCook 15-piece explainer](https://www.spritecook.ai/blog/autotile-tilesets-explained).
8. **Layer instead of bake** — transparent grass clumps / rocks as overlay tiles multiply combos without N×N baked variants ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)).
9. **Live connection check** — always author with tile preview; corners must connect to sides *and* to other corners.

### Autotile vocabulary (quick)

| Set | Neighbor model | Use |
|-----|----------------|-----|
| **15/16** | 4 corners (Wang / dual) | Compact top-down ground |
| **47 blob** | 8-neighbor reduced | Full inner/outer corners (Godot Match Corners and Sides) |
| **Edge-only 16** | 4 cardinals | Simple platforms / cliffs |

---

## Props / buildings

### Consistent door facing & perspective

1. **Pick one camera tilt and stick to it** — pure bird’s-eye vs “Undertale-like” tilted (characters side-on, one wall visible) ([GameMaker perspectives](https://gamemaker.io/en/blog/make-pixel-art-2d-games)). Mixing both in one sheet breaks doors and windows.
2. **Wall top brighter than wall face**; side-face bricks shorter than top-face bricks (broad side vs narrow side) ([SLYNYRD Pixelblog 45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).
3. **Universal corner columns** often beat unique 4-corner brick pieces — fewer assets, reusable as freestanding props ([SLYNYRD 45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).
4. **Doors as readability cues, not tiny knobs:**
   - Break / thin the wall where the door sits.
   - Floor mat / path leading in.
   - Optional light spill under door.
   - Side doors in top-down are hard; rugs + cutouts outperform painted side door panels.
5. **One light direction** for all sheets — short drop shadows, ≤1 tile long, same quadrant everywhere to avoid Y-sort / overlap fights ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2), [45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).
6. **Building sheets modularize:** wall mid, wall top, roof cap, door module, window module — same door module facing south (or the camera) reused; don’t redraw a unique perspective door per façade unless the game needs it.
7. **Omit outline at ground contact** on buildings/characters so they sit on the tile ([Lospec outlines](https://lospec.com/articles/pixel-art-outlines/)).

Educator video entry points (techniques only): Adam C Younis *Pixel Art Class — Top Down Tilesets*; MortMort *How to make SIMPLE TILESET* / *My Tileset Workflow* (indexed on [Lospec](https://lospec.com/pixel-art-tutorials/how-to-make-a-simple-tileset-by-mortmort)); Saultoons top-down tileset tips (linked from [GameMaker article](https://gamemaker.io/en/blog/make-pixel-art-2d-games)).

---

## Water

### Static water tile

1. **Interior pattern that wraps** — wavy interconnected 1px blob networks; break lines so motion doesn’t lock into a grid ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)).
2. **Bank / shore is a separate autotile set** — sand/mud filler + edge tiles meeting water; don’t expect one “water pixel” to solve land contact.
3. **Foam / shore edge as overlay or edge animation**, not painted into every filler cell.

### Foam & edge animation (Wolthera taxonomy)

Documented edge strategies ([Animating Water Tiles part 1: Edges](https://wolthera.info/2019/06/animating-water-tiles-part-1-edges/)):

| Technique | Idea | Notes |
|-----------|------|-------|
| **Expand / contract** | Rest → −1px → rest → +1px | Cheap; area grows/shrinks |
| **Undulate** | Cycle N/E/S/W 1px offsets | Keeps area; good brook feel |
| **Side waves** | Local expand/contract traveling along edge | Mirror adjacent frames for corners |
| **Ocean wave** | Main swell expand + under-wave fade/contract | Needs ~8 fps; slower contract |
| **Inner outline only** | Animate foam ring, keep outer shore fixed | Smoother, less noisy |
| **Brightness pulse** | Cyan ↔ white on rim | Common commercial look |
| **Center fade** | Lower opacity mid-tile, stronger rim | LPC / Wang friendly |

**Blending:** separate water from rocks; multiply + overlay duplicates can sell wet contrast ([Wolthera](https://wolthera.info/2019/06/animating-water-tiles-part-1-edges/)).

**Minimal animation (SLYNYRD):** two wrap-matched water patterns; hard A↔B cut for retro, or 50% blend frame between them; timing critical (too fast = noise, too slow = choppy) ([SLYNYRD 43](https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2)).

**Isometric note:** stagger wave height; for non-directional water, overlay transparent wave then remap to indexed palette ([Sprite Knights water tutorial](https://spriteknights.com/water-tile-tutorial/)).

**Engine:** Godot animated tiles = frames in columns on the atlas ([Godot shader / tilemap water notes](https://godotshaders.com/shader/pixel-art-water/)); foam can also be shader-driven from a mask channel if art stays static.

---

## Cutting sprites from sheets (matting, padding, pivot)

### Matting / cleanup

- Export with **real alpha**, not a magenta/checker matte left in RGB.
- Clean silhouette after crop; keep consistent outline policy with the rest of the game ([Lospec outlines](https://lospec.com/articles/pixel-art-outlines/)).

### Padding & bleed

| Mechanism | Purpose |
|-----------|---------|
| **Shape / border padding** (Aseprite `--shape-padding`, `--border-padding`) | Gap between packed cells |
| **Inner padding** | Shrink content inside cell |
| **Extrude** (`--extrude`) | Duplicate edge pixels outward to hide filter bleed |
| **Godot `use_texture_padding`** | Engine inserts 1px pad around each atlas tile |

Sources: [Aseprite CLI](https://www.aseprite.org/docs/cli/); [Godot TileSetAtlasSource](https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html).

Also: project-wide **Nearest** filter + integer camera; accidental 1px gutters in the art break seams (Dream `SEAMLESS.md`).

### Fixed-cell contract & pivot at feet

For characters/props that animate or Y-sort:

1. **Identical cell size** per action strip.
2. **Shared baseline** — all grounded frames share the same foot line.
3. **Semantic pivot** = ground contact (bottom-center / feet), not image center.
4. If trimmed packing: store **source size + trim offsets + pivot in source space** so feet don’t jitter.
5. Overlay all frames at one world position to verify before shipping.

Sources: [Fixed-cell sprite sheet contract](https://dev.to/framesprite/a-fixed-cell-contract-for-sprite-sheets-that-do-not-jitter-3167); [Godot Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) (texture origin / Y sort origin for tall tiles).

---

## Checklist — 先画什么再画什么

Use this as a production order (Chinese labels = decision points):

- [ ] **0. 定规格** — tile size, palette, light direction, top-down vs side vs iso
- [ ] **1. 剪影 / 色块** — silhouette & value for any hero prop (optional mood)
- [ ] **2. 先画填充砖 (filler)** — wrap-matched center tile; hide the grid
- [ ] **3. 再画边 (edges)** — N/E/S/W derived from filler
- [ ] **4. 再画外角 (outer corners)**
- [ ] **5. 再画内角 (inner corners)** — do not skip
- [ ] **6. 再画过渡 (biome transitions)** — e.g. grass↔dirt, bank↔water
- [ ] **7. 水面填充** — wrap water interior (+ optional 2-frame loop)
- [ ] **8. 水岸泡沫** — foam/edge overlay or edge animation last among ground
- [ ] **9. 建筑模块** — wall face / wall top / roof / **统一朝向的门** / windows
- [ ] **10. 道具与树** — feet on grid; short shared shadows; Y-sort origin at feet
- [ ] **11. 裁切导出** — alpha matte, padding/extrude, Nearest + engine texture pad
- [ ] **12. 细节与特效** — AA, dither, sparkle, VFX — only after readable masses

**Rule of thumb:** *terrain mass → terrain edges → water → architecture modules → props → polish.*  
Never polish detail on a tile that doesn’t wrap.

---

## Sources

| Topic | URL |
|-------|-----|
| Silhouette → color pipeline | https://gamemaker.io/en/blog/make-pixel-art-2d-games |
| Pixel Logic (book; Ch.4 readability, Ch.6 perspectives) | https://pixellogicbook.com / https://payhip.com/b/oURjI |
| Outlines / ground contact | https://lospec.com/articles/pixel-art-outlines/ |
| Base → edge → corner tileset build | https://www.sandromaglione.com/articles/how-to-create-a-pixel-art-tileset-complete-guide |
| Top-down layered tiles, water 2-frame | https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2 |
| Walls, doors, shadows, brick perspective | https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more |
| MortMort simple tileset (Lospec index) | https://lospec.com/pixel-art-tutorials/how-to-make-a-simple-tileset-by-mortmort |
| Water edge / foam animation taxonomy | https://wolthera.info/2019/06/animating-water-tiles-part-1-edges/ |
| Iso water stagger / non-directional | https://spriteknights.com/water-tile-tutorial/ |
| 15-piece autotile explained | https://www.spritecook.ai/blog/autotile-tilesets-explained |
| Compose 47 from 6 templates | https://violetpixel13.itch.io/autoblob |
| Aseprite export padding / extrude | https://www.aseprite.org/docs/cli/ |
| Godot atlas padding | https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html |
| Godot TileSet origins / Y-sort | https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html |
| Fixed cell + feet pivot | https://dev.to/framesprite/a-fixed-cell-contract-for-sprite-sheets-that-do-not-jitter-3167 |
| Dream seamless terrain practice | ../../SEAMLESS.md |

**Educator pointers (watch for technique, not persona):** Adam C Younis top-down tilesets class; MortMort tileset workflow; Saultoons top-down tileset; Pixel Logic chapters above; Lospec tutorial index https://lospec.com/pixel-art-tutorials/

---

*Research note for Dream village / seamless terrain work. Prefer primary tutorials and engine docs over secondary listicles.*
