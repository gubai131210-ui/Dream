---
name: painting-asset-craft
description: >-
  Authors and reviews 2D game art for Dream: canvas sizes, tile atlases,
  sprite sheet frame counts, front-only vs multi-view, camera-angle locks,
  inpainting missing elements from a full sheet, cutout/upscale/seamless
  pipelines, and post-tile visual QA. Use when drawing or slicing tiles,
  characters, buildings, props, water overlays, sequence frames, 三视图,
  补图, 抠图, Aseprite sheets, or when the user mentions painting-asset-craft,
  SCALE.md asset authoring, or AI sheet cleanup.
---

# Painting asset craft (Dream)

Operate on **how to draw and ship pixels**, not scene layout.  
Layout/districts → `realistic-scene-craft` + `docs/AREA_FRAMEWORK.md`.  
Scale lock → `docs/SCALE.md`. Research → `docs/research/practitioners/sprite-painting-specs.md`.

## Leading words

- **cell** — one gameplay tile = 32×32 (`BASE_TILE`)
- **sheet** — multi-frame or multi-prop PNG before slice
- **facing lock** — one camera tilt + one door axis for a set
- **wrap filler** — tile whose L==R and T==B
- **inpaint hole** — masked region to regenerate inside an otherwise good sheet
- **pivot** — foot contact for Y-sort (not visual center)

## When this skill runs

```
Painting checklist:
- [ ] 1. Re-read SCALE.md (BASE_TILE, char/building bands)
- [ ] 2. Lock camera tilt + light quadrant + door facing
- [ ] 3. Choose deliverable type (filler tile / autotile set / prop / building / char anim)
- [ ] 4. Pick canvas & frame grid (tables below)
- [ ] 5. Paint order: silhouette → value → color → detail
- [ ] 6. For tiles: filler wrap → edges → outer corners → inner corners → blends → foam
- [ ] 7. For chars: keys first (contact/pass), then in-betweens; tag animations
- [ ] 8. Cutout / inpaint / upscale with approved tools
- [ ] 9. Normalize to display px; Nearest + padding
- [ ] 10. In-engine QA at integer zoom on real ground tiles
- [ ] 11. Update MANIFEST / SEAMLESS if new terrain types
```

**Done when:** checklist complete and a reviewer can name frame size, frame count, facing, and tool used for cutout.

---

## 1. Size matrix (locked to Dream)

| Asset | Author canvas (typical) | Ship size | Notes |
| --- | --- | --- | --- |
| Terrain filler / edge | 32×32 or 64×64 then down | **32×32** cell | Wrap-match mandatory for fillers |
| Autotile blob set | atlas of 16 / 47 cells | 32×32 each | Inner corners required |
| Water overlay frame | 32×32 × N | 32×32 | Shared phase anim (Stardew-like) |
| Character | 32×48–64 canvas | **48–64 px** tall | Width ≤ ~40 px |
| Cottage | modular or full | **3–5 tiles** tall | Door ≥ char height |
| Landmark | full | **5–8 tiles** tall | Still walkable scale |
| Prop small | 16–48 px | 0.5–1.5 tiles | Pivot at feet |
| Prop large / stall | 48–96 px | 1.5–3 tiles | |

**AI source sheets** (1448×1086 etc.) are **not** tile sizes — slice islands first, then normalize (`SCALE.md` §2).

---

## 2. Animation frame counts

| Clip | Min (retro OK) | Target | FPS feel |
| --- | --- | --- | --- |
| Idle breathe | 2–4 | **4–6** | slow |
| Walk | 4 | **6–8** (SLYNYRD: 8 sweet spot) | ~8–12 fps |
| Run | 6 | **6–8** | faster than walk |
| Water shimmer | 4 | **8–10** | shared global index |
| Crop sway / flag | 2–4 | 4 | very slow |
| Door open | 3–4 | 4 | oneshot |

Scale frames with sprite size: ~16px → 4 walk; ~32-class → 4–6; larger → 6–8 ([sprite-painting-specs](../../../docs/research/practitioners/sprite-painting-specs.md)).  
**Walk keys:** contact → down → passing → up → (mirror). Draw keys before in-betweens.  
Master at **1×**; display at integer 2×/3× — never polish at 2× then downscale.

### Sheet layout

- Prefer **uniform grid** for characters (fixed cell).  
- Tag clips in Aseprite (`idle`, `walk_s`, …).  
- Padding **1–2 px** between cells to stop bleed.  
- Pivot: bottom-center or documented foot point — **same for all frames**.

```powershell
# Example Aseprite CLI (if installed)
aseprite -b char.ase --sheet char.png --data char.json --format json-array --list-tags --sheet-type horizontal --shape-padding 2
```

---

## 3. Views: 正面 vs 三视图 vs 斜 3/4

| Need | Draw | Do not |
| --- | --- | --- |
| Dream default buildings | **One 3/4 or front-south** set, doors +Y | Mix top-down roofs with side-on walls in one set |
| Plaza/residential props | Front or 3/4 matching buildings | Free yaw without art |
| Characters | 4-dir **or** 1-dir + flip_h if art allows | 8-dir unless schedule needs it |
| True top-down furniture | Orthographic top | Reuse 3/4 sheets as top |
| Marketing key art | Any | Import key art as TileSet |

**Facing lock (Dream):** south-facing doors → layout places buildings **north** of plaza/path (`AREA_FRAMEWORK.md`).

### When camera angle changes

Rebuild, do not squash:

1. Wall visible faces (which sides show)  
2. Roof parallelogram / diamond  
3. Door/window foreshortening  
4. Contact shadow shape  
5. Character proportions vs ground diamond  

Keep: palette, silhouette language, light quadrant if possible.

---

## 4. Paint order

### Terrain

1. Lock palette + light  
2. **Filler wrap** (ConcernedApe started with dirt)  
3. Edges → outer corners → **inner corners**  
4. Biome blends (grass↔dirt, dry↔damp)  
5. Water fill → foam  
6. Variant fillers (2–5) for anti-repeat  
7. Live tile preview / `make_seamless_terrain.py`

### Buildings

1. Footprint box + door on south face  
2. Wall mass (collision height)  
3. Roof  
4. Trim / windows  
5. Separate shadow decal optional  

### Characters / props

1. Silhouette thumbnail-readable  
2. Value  
3. Color  
4. Detail last  
5. Feet on baseline; omit outline at ground contact if it floats  

### Full scene sheet → extract one missing element

1. Isolate target with mask (矩形 / SAM / 手工)  
2. **Inpaint** only the hole (LaMa / IOPaint / Comfy inpaint) — preserve neighbors  
3. Or: rembg cut a donor prop from another sheet, paste, heal seams  
4. Re- Quarantine: new element must match light + outline weight  
5. Scale to SCALE bands; QA on real tiles  

---

## 5. After tiling — predict failures

| Symptom | Cause | Fix |
| --- | --- | --- |
| Grid visible | vignette on filler / Linear filter | wrap rewrite; Nearest; padding |
| Water looks like blue carpet | no bank / no overlay anim | damp ring + shimmer frames |
| Building floats | pivot center | pivot feet; contact shadow |
| Door into nowhere | art facing ≠ lot | move lot or redraw door |
| Tiling stamp pattern | unique rock on one edge | mid-tone noise; landmarks as props |
| Soft mush | upscale then Linear | ESRGAN → nearest snap to px |

---

## 6. Agent tools (defaults)

Full matrix: `docs/research/practitioners/agent-art-tooling.md` · short: `realistic-scene-craft/reference-tooling.md`.

| Task | Tool |
| --- | --- |
| Seamless grass/dirt | `python dream/tools/make_seamless_terrain.py` |
| 抠图 | `rembg i -m birefnet-general` |
| Upscale | Real-ESRGAN ncnn-vulkan (`-n realesrgan-x4plus-anime` when fitting) |
| Batch crop | ImageMagick / Pillow |
| Inpaint hole | IOPaint / LaMa / Comfy inpaint (user optional) |
| Slice grid | Aseprite CLI or Pillow |
| QA | Godot MCP screenshot @ integer zoom |

### Ask user to prepare (if missing)

1. Python 3.10+ · pillow · numpy  
2. `pip install "rembg[cpu,cli]"`  
3. Real-ESRGAN ncnn-vulkan on PATH  
4. ImageMagick (`winget install -e --id ImageMagick.ImageMagick`)  
5. Optional: Aseprite CLI, ComfyUI API, IOPaint/LaMa  

**New tools worth adding:** IOPaint (LaMa inpaint CLI), `transparent-background` (alt matting), Florence-2 caption→mask helpers, SAM2 only if rembg fails on crowded sheets.

---

## 7. Anti-lazy

- Ship filler wrap **before** deco props  
- Never import raw 1448 AI sheet as 32 atlas  
- Never skip inner corners on terrain sets  
- Never invent a second door facing in one building pack  
- Never finalize walk cycles without in-engine test on actual grass/path  
- Chinese paths: prefer `dream/tools/` scripts; user runs Godot visual QA  

## After changes

1. User tests in Godot.  
2. Commit; push if `git remote` exists.  
3. Review subagent vs SCALE + this checklist.
