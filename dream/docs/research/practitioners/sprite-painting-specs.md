# Practitioners: 2D sprite painting specs

Techniques distilled from pixel educators, engine docs, and production-validated agent skills for **authoring** game sprites (size, frames, viewpoint, repair). Focus is craft method, not personalities.

**Scope:** canvas / tile matrices, sequence-frame budgets, orthographic vs isometric sheets, camera-angle redraw rules, inpaint / cutout / upscale preview.

**Dream lock (do not override without ADR):** [`SCALE.md`](../../SCALE.md) — `BASE_TILE = 32`, character height **48–64 px** (target **56**). Related: [`artists-tile-pipeline.md`](artists-tile-pipeline.md), [`agent-art-tooling.md`](agent-art-tooling.md).

---

## 1. Size matrix

### 1.1 Tile edge → workload

Each time you double tile edge length, pixel count (and paint cost) **quadruples** ([GameMaker — How To Make Pixel Art For 2D Games](https://gamemaker.io/en/blog/make-pixel-art-2d-games)).

| Tile (px) | Pixels / cell | Typical use | Character height (guideline) | Dream note |
|-----------|---------------|-------------|------------------------------|------------|
| **16** | 256 | Retro / dense maps; tiny UI icons | **16–32** (1–2 tiles); often **~24–28** | Too small for current AI-sheet normalize path |
| **32** | 1 024 | Indie RPG / village default | **48–64** (**1.5–2.0** tiles); midpoint **56** | **LOCKED** — `BASE_TILE` |
| **48** | 2 304 | Hi-bit mid; less common pure grid | **72–96** (1.5–2 tiles) | Use only if ADR changes grid |
| **64** | 4 096 | Large heroes, iso diamonds often 64×32 module | **96–128** (1.5–2 tiles) | Native AI blobs often *start* near this; must downscale to 32-grid |

**Industry heuristics (not Dream locks):**

- Author tiles at **8–32** for speed; beyond 32 “takes a very long time” per sprite ([GameMaker](https://gamemaker.io/en/blog/make-pixel-art-2d-games)).
- Characters that read well vs tiles: roughly **1 tile wide × 1.5 tiles tall** (community / FF6-style rule of thumb; aligns with Dream 32×48–64).
- Draw objects at **intended display size** — do not stretch a 16×16 tree to “giant”; redraw larger ([GameMaker community consensus](https://www.reddit.com/r/gamemaker/comments/1ewrbu3/pixel_art_proportions_having_16x16_sprites_for/); same rule for bosses).
- SLYNYRD: **16×16** is still the most common top-down tile module for teaching; >32 can feel “overkill” for pure pixel texture work ([Pixelblog 20](https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles)).

### 1.2 Character / prop height in tiles (Dream-aligned)

| Asset class | Height in tiles @32 | Height px | Source |
|-------------|---------------------|-----------|--------|
| Player / NPC | **1.5–2.0** | 48–64 (target 56) | [`SCALE.md`](../../SCALE.md) |
| Small prop | **0.5–1.5** | 16–48 | same |
| Large prop | **1.5–3** | 48–96 | same |
| Cottage | **3–5** | 96–160 | same |
| Town hall | **5–8** | 160–256 | same |
| Tree | **3–6** | 96–192 | same |

### 1.3 Canvas / camera resolution (authoring context)

Pick **internal** resolution first (what the camera sees), then size sprites relative to it — not 1080p output ([GameMaker](https://gamemaker.io/en/blog/make-pixel-art-2d-games); common bases **320×180** / **640×360** for 16:9 integer scale).

Classic nostalgia canvases (reference only): GB 160×144, GBA 240×160, NES 256×240, SNES 256×224, Genesis 320×224 ([GameMaker](https://gamemaker.io/en/blog/make-pixel-art-2d-games)).

**Punch Club / Lazy Bear rule:** master art at **1×** (1 logical pixel = 1 source pixel); engine displays at **2× / 3× integer**. Never polish at 2× then downscale ([pixel-art-studio skill summary](https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/references/04-animation.md) citing DTF Punch Club guide).

---

## 2. Animation frame suggestion table

### 2.1 How many frames are “enough”?

| Claim | Source |
|-------|--------|
| **2 frames** = absolute minimum; motion often *flickers* without arcs | [Pixel Logic Ch.9](https://pixellogicbook.com) (limited frames) |
| **3 frames** = minimum for a *convincing* loop (even runs / overlapping actions) | Pixel Logic Ch.9 |
| **4 frames** can reuse a breakdown to loop; Celeste-class walk minimum | Pixel Logic; [pixel-art-studio 04-animation](https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/references/04-animation.md) |
| **6 frames** = solid economy + fluid middle ground | [SLYNYRD Pixelblog 50](https://www.slynyrd.com/blog/2024/5/24/pixelblog-50-human-walk-cycle) |
| **8 frames** = sweet spot economy vs fluidity for game walks; beyond 8 often aesthetic, not required | SLYNYRD 50 |
| Scale frames with **sprite size**, not ambition: 16×16 → 4 walk; 32×32 → 4–6; 48+ → 6–8; 12-frame only for 64px+ heroes | [pixel-art-studio 04-animation](https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/references/04-animation.md) |

### 2.2 Production table (cycles)

| Animation | Min | Standard (Western indie) | Premium | Suggested FPS | Notes |
|-----------|-----|--------------------------|---------|---------------|-------|
| **Idle** | 2 (breath) | 4–6 | 8 | ~6 | Prefer sub-pixel AA toggle over silhouette jump |
| **Walk** | **4** | **6** | **8** (12 cinematic) | 8 (125 ms); CN mobile often **5** (200 ms) | See §2.3 poses |
| **Run** | 6 | 8 | 10 | ~10 | More air time / stretch |
| **Attack** | 3 (antic / strike / recover) | 5 | 6–12 | 10–12 | Timing > frame count (saint11 via skill) |
| **Hit** | 1–2 | 2–3 | — | 15–20 flash | |
| **Death** | 4 | 6–8 | 10+ | 8 | |
| **Water / tile FX** | 2 wrap patterns | 2–4 | 8 (ocean) | 4–8 | See [`artists-tile-pipeline.md`](artists-tile-pipeline.md) |

Godot tutorial example: **8** run frames imported as individuals, preview ~**10 FPS** ([Godot — 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html)). GameMaker tile *animation* historically prefers power-of-2 frame counts (2/4/8/…) for tile assets ([GameMaker Tile Sets](https://manual.gamemaker.io/beta/en/Quick_Start_Guide/Creating_Tile_Sets.htm)) — characters are freer.

### 2.3 Walk poses (4 / 6 / 8)

Classical key poses (side view) — names vary slightly; SLYNYRD’s 8-frame half-cycle:

| # | Pose | What to draw |
|---|------|--------------|
| 1 | **Contact** | Heel down; limbs at swing extremes; body **lowest** |
| 2 | **Down** | Foot flat; weight absorbs; trailing foot lifts |
| 3 | **Pass / passing** | Legs cross; body **tallest** |
| 4 | **Swing / up** | Leading swing peak; opposite contact next |
| 5–8 | Mirror of 1–4 | Minor perspective fix if camera not pure side |

Sources: [SLYNYRD 50](https://www.slynyrd.com/blog/2024/5/24/pixelblog-50-human-walk-cycle); [beatcop — How to Animate Pixel Art](https://beatcopgame.com/how-to-animate-pixel-art/); [Lospec — Walk Cycle 6 & 8 frames](https://lospec.com/pixel-art-tutorials/how-to-pixel-art-tutorials-17-walk-cycle-6-8-frames-by-dual-core-studio); Pedro Medeiros walk / top-down walk ([Miniboss tutorial index](https://blog.studiominiboss.com/pixelart)).

**Top-down / ¾ village (Dream-relevant):** legs often compress to bob + stride silhouette; still keep contact/pass rhythm. Prefer **4 directions** (N/E/S/W) for orthographic ¾; add diagonals only if movement needs them.

### 2.4 Aseprite craft checklist

1. Draw keys → inbetweens (pose-to-pose).
2. **Onion skin** on for cycles; off for face polish ([Aseprite Animation](https://www.aseprite.org/docs/animation/); [Onion Skin](https://www.aseprite.org/docs/onion-skinning/)).
3. **Tags** per action (`walk`, `idle`); export sheet + JSON via CLI ([Aseprite CLI](https://www.aseprite.org/docs/cli/)).
4. Fixed **cell size** + shared **foot baseline** + pivot at feet ([artists-tile-pipeline](artists-tile-pipeline.md) § Cutting sprites).
5. Head bob: slight **triangle** wave feels more organic than perfect sine ([SLYNYRD 50](https://www.slynyrd.com/blog/2024/5/24/pixelblog-50-human-walk-cycle)).

---

## 3. Viewpoint lock — front / three-view / camera change

### 3.1 Lock one projection per project (or per map family)

| Projection | What you draw | Sheet implication |
|------------|---------------|-------------------|
| **Side-on** | Profile / ¾ profile; platformer | Often **1 facing** + `flip_h`; jump/attack arcs matter |
| **True top-down (bird)** | Heads / roofs dominant; Hotline-style | Characters mostly from above; doors as floor cuts |
| **¾ top-down (Undertale / Stardew-like)** | Characters **near side-on**; buildings show **one façade + roof** | **4-dir** character sheets common; doors face camera/south |
| **Isometric / 2:1 dimetric** | Cube: three faces; grid **2px:1px** lines (~26.565°) | Diamond tiles (e.g. **64×32**); characters often **8-dir** |

Sources: [GameMaker perspectives](https://gamemaker.io/en/blog/make-pixel-art-2d-games); [Pixel Logic Ch.6 Game perspectives](https://pixellogicbook.com); [SLYNYRD Pixelblog 4](https://www.slynyrd.com/blog/2018/4/12/pixelblog-4-graphical-projection-part-2); [SLYNYRD 41 / 54 iso](https://www.slynyrd.com/blog/2022/11/28/pixelblog-41-isometric-pixel-art); [isometric-ops skill](https://github.com/0xdarkmatter/claude-mods/blob/main/skills/isometric-ops/SKILL.md).

**Dream village ring:** treat as **locked ¾ top-down** — do not mix bird’s-eye ground with side-view façades on the same sheet ([artists-tile-pipeline](artists-tile-pipeline.md)).

### 3.2 Front-only vs “three views”

| Approach | When enough | When not |
|----------|-------------|----------|
| **Front / south-facing only** | Static props, signage, buildings that never rotate | Player / NPCs that walk N/E/S/W |
| **Side + flip** | Platformers; left/right only | Top-down RPGs |
| **4-dir sheet** | Orthographic ¾ village / RPG | Iso with free 8-way move |
| **8-dir sheet** | Iso / twin-stick / diagonals matter | Overkill for cardinally locked Dream hubs |
| **True 3-view (front/side/back model sheet)** | Concept / turnaround for *consistent* redesign | Not a runtime sheet — still bake into game dirs |

### 3.3 Orthographic square tiles vs isometric diamond sheets

| | Orthographic / ¾ top-down | Iso (game “isometric” = usually **2:1 dimetric**) |
|--|---------------------------|---------------------------------------------------|
| Ground cell | Square **N×N** (Dream **32×32**) | Diamond bounding box **2:1** (e.g. 32×16, 64×32) |
| Building art | One wall + roof; modular wall/door | Two walls + roof; follow 2:1 edges |
| Character dirs | 4 enough | 8 typical |
| Mixing | **Forbidden** without remapping | Round trees can *look* similar across projections; structural walls cannot ([SLYNYRD 54](https://www.slynyrd.com/blog/2025/1/23/pixelblog-54-isometric-pixel-art)) |

### 3.4 “We changed the camera angle — what must be redrawn?”

| Change | Must redraw / rebuild | Can often keep |
|--------|----------------------|----------------|
| Bird ↔ ¾ tilt | **All** façades, doors, character bodies, wall heights | Palette, some prop silhouettes after edit |
| ¾ ↔ isometric | **All** tiles (square→diamond), buildings, character direction set | Narrative concept sketches only |
| Rotate light quadrant | Shadows, bevels, roof shade; optional re-AA | Flat filler hue if values reworked |
| Zoom / tile size (16→32) | New masters at target size (no naive upscale as final) | Silhouette *ideas* |
| Add diagonal move on 4-dir set | New NE/NW/SE/SW rows (or accept slide + nearest cardinal) | Existing 4-dir art |
| Flip-only facing change | Nothing if symmetric; fix asymmetric clothing/hair | Symmetric bodies |

**Rule:** projection and light are **global contracts**. Changing them mid-production invalidates modular tiles more than unique hero sprites.

---

## 4. Missing elements / cutout / upscale / inpaint

### 4.1 Recommended repair order (game assets)

```
1. Isolate subject (抠图 / matte)
2. Decide: inpaint missing PART vs regenerate WHOLE
3. Inpaint / outpaint only the mask (low denoise when possible)
4. Pixel-lock / nearest downscale to Dream display size
5. Manual Aseprite cleanup (silhouette, outline policy, feet baseline)
6. Preview on real tile + lighting (engine screenshot), not only in SD UI
```

Aligns with Dream tooling note: rembg / BiRefNet → Real-ESRGAN anime → Pillow normalize → Godot Nearest ([agent-art-tooling](agent-art-tooling.md); [reference-tooling](../../.cursor/skills/realistic-scene-craft/reference-tooling.md)).

### 4.2 Cutout (抠图)

| Tool | Role |
|------|------|
| **rembg** + `birefnet-general` | Default agent 抠图 for props/NPCs |
| **SAM / Grounded-SAM** | Prompted regions when auto-matte fails |
| Manual Aseprite / GIMP | Hair wisps, held items, soft shadows |

Always export **real alpha**; strip sheet black matte ([SCALE.md](../../SCALE.md) failure criteria).

### 4.3 Inpainting — when it helps game art

| Use | Method notes | Source |
|-----|--------------|--------|
| Add missing hand / tool / door | Mask only the hole; grow mask slightly for blend | [ComfyUI Inpaint tutorial](https://docs.comfy.org/tutorials/basic/inpaint) (`grow_mask_by`) |
| Fix AI glitch on one limb | Prefer **inpaint model** + dedicated encode path; don’t max denoise on whole canvas | [SD Art — ComfyUI inpaint](https://stable-diffusion-art.com/inpaint-comfyui/) |
| Cosmetic layers over motion | Two-pass inpaint preserving non-masked pixels bit-exact | [comfyui-2d-character-pipeline W4](https://github.com/mor-o/comfyui-2d-character-pipeline) |
| Wrong *perspective* door | **Do not** trust inpaint — redraw under locked camera ([reference-tooling](../../.cursor/skills/realistic-scene-craft/reference-tooling.md): rembg cannot invent door facing) |

**Craft tips:**

- Mask **tight + slight grow**; avoid regenerating already-good silhouette.
- Keep **same seed family / reference** (IP-Adapter / character sheet) so palette doesn’t drift.
- After inpaint: **quantize / nearest** to project pixel size — SD soft edges ≠ final sprite.
- For animation: inpaint **per frame** with shared mask strategy, or fix one hero frame and propagate carefully — uncorrelated frame inpaints break mass conservation.

### 4.4 Upscale then downscale (预判贴图效果)

| Step | Why |
|------|-----|
| Upscale with **realesrgan-x4plus-anime** (or similar) | Cleaner edges before crop |
| Downscale with **Nearest** to 48–64 / 32 grid | Match Dream lock |
| Reject if silhouette mush / double outlines | Treat as failed pass |

**Never** ship bilinear-filtered upscale as gameplay art ([SCALE.md](../../SCALE.md) §4).

### 4.5 Preview “after tiling / in-engine” (效果预判)

Before calling a sheet done:

1. Place sprite on **actual filler tile** at integer zoom (1×/2×/3×).
2. Check **feet** on ground line; omit outline at contact ([Lospec outlines](https://lospec.com/articles/pixel-art-outlines/)).
3. Check **door vs character height** (≥ char height per SCALE).
4. Godot: Filter **Nearest**, lossless, optional atlas padding; MCP **`take_screenshot`** vs reference ([Godot importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)).
5. For seamless ground: wrap-preview / `make_seamless_terrain.py` — not only single-tile beauty ([SEAMLESS.md](../../SEAMLESS.md)).

---

## 5. Public skills / checklists to borrow

| Resource | Borrow these points |
|----------|---------------------|
| [pixel-art-studio SKILL](https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/SKILL.md) + [04-animation.md](https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/references/04-animation.md) | Frame/FPS tables; walk 4/6/8 rules; tag export; mass/palette consistency checks; Generator–Evaluator reviewer pattern |
| [isometric-ops SKILL](https://github.com/0xdarkmatter/claude-mods/blob/main/skills/isometric-ops/SKILL.md) | Write projection + 2:1 tile W×H + foot anchor **before** drawing; Godot iso TileMap checklist |
| In-repo [`artists-tile-pipeline.md`](artists-tile-pipeline.md) | Filler→edge→corner order; door/light lock; sheet padding |
| In-repo [`agent-art-tooling.md`](agent-art-tooling.md) | rembg / ESRGAN / Comfy seamless matrix |
| In-repo `realistic-scene-craft` | Placement / facing / footprint (scene assemble, not paint) |
| [Pixel Logic](https://pixellogicbook.com) | Ch.6 perspectives, Ch.9 limited animation minima |
| [SLYNYRD Pixelblog](https://www.slynyrd.com/) | Tiles 20/43; projection 4; walk 50; iso 41/54 |
| [Pedro / Miniboss tutorials](https://blog.studiominiboss.com/pixelart) | Walk + top-down walk / attack timing |
| [Lospec tutorial index](https://lospec.com/pixel-art-tutorials) | Walk 6&8, tilesets, outlines |
| [Aseprite docs](https://www.aseprite.org/docs/) | Animation, onion skin, CLI sheet export |
| [Godot 2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) | SpriteFrames vs AnimationPlayer + Hframes |
| [GameMaker pixel art guide](https://gamemaker.io/en/blog/make-pixel-art-2d-games) | Perspective trio; tile size cost table; silhouette→color |

### Compact paint checklist (sprites)

- [ ] Projection + light quadrant locked
- [ ] Tile size locked (Dream: **32**)
- [ ] Character height in **48–64** band
- [ ] Silhouette readable at 1× thumbnail
- [ ] Idle / walk frame budget chosen (recommend walk **4–6** @32–56 px)
- [ ] Shared cell + foot pivot for all frames of an action
- [ ] Direction count matches camera (4-dir ¾ vs 8-dir iso)
- [ ] Export PNG RGBA / indexed; Nearest in engine
- [ ] In-engine screenshot on real tiles — not only generator preview

---

## 6. URL index (primary)

| Topic | URL |
|-------|-----|
| Aseprite animation | https://www.aseprite.org/docs/animation/ |
| Aseprite onion skin | https://www.aseprite.org/docs/onion-skinning/ |
| Aseprite CLI | https://www.aseprite.org/docs/cli/ |
| Pixel Logic (book) | https://pixellogicbook.com |
| SLYNYRD walk cycle | https://www.slynyrd.com/blog/2024/5/24/pixelblog-50-human-walk-cycle |
| SLYNYRD projection | https://www.slynyrd.com/blog/2018/4/12/pixelblog-4-graphical-projection-part-2 |
| SLYNYRD top-down tiles | https://www.slynyrd.com/blog/2019/8/27/pixelblog-20-top-down-tiles |
| SLYNYRD tiles part 2 | https://www.slynyrd.com/blog/2023/3/26/pixelblog-43-top-down-tiles-part-2 |
| SLYNYRD isometric | https://www.slynyrd.com/blog/2022/11/28/pixelblog-41-isometric-pixel-art |
| GameMaker pixel art | https://gamemaker.io/en/blog/make-pixel-art-2d-games |
| Godot sprite animation | https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html |
| Godot import images | https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html |
| Lospec walk 6/8 | https://lospec.com/pixel-art-tutorials/how-to-pixel-art-tutorials-17-walk-cycle-6-8-frames-by-dual-core-studio |
| Pedro tutorial index | https://blog.studiominiboss.com/pixelart |
| Beatcop animate pixel | https://beatcopgame.com/how-to-animate-pixel-art/ |
| ComfyUI inpaint | https://docs.comfy.org/tutorials/basic/inpaint |
| SD Art Comfy inpaint | https://stable-diffusion-art.com/inpaint-comfyui/ |
| 2D character Comfy pipeline | https://github.com/mor-o/comfyui-2d-character-pipeline |
| pixel-art-studio skill | https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/SKILL.md |
| pixel-art-studio animation ref | https://github.com/AnastasiyaW/claude-code-config/blob/main/skills/creative/pixel-art-studio/references/04-animation.md |
| isometric-ops skill | https://github.com/0xdarkmatter/claude-mods/blob/main/skills/isometric-ops/SKILL.md |
| Lospec outlines | https://lospec.com/articles/pixel-art-outlines/ |

---

## 7. Dream-facing defaults (summary)

| Spec | Default |
|------|---------|
| Tile | **32×32** |
| Character | **56 px** tall (~1.75 tiles), 4-dir if mobile |
| Walk | **4–6** frames @ ~8 FPS (or 5 FPS if deliberately “CN RPG” pacing) |
| Buildings | South/camera-facing door modules; one light quadrant |
| Projection | **¾ top-down** — not iso diamonds |
| Repair | 抠图 → masked inpaint → nearest to SCALE → Aseprite cleanup → Godot screenshot QA |

*Craft/method research note — Batch B. Not a substitute for `SCALE.md` locks.*
