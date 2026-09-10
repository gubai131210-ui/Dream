# Agent art tooling — cutout, upscale, slice, seamless tiles (Windows)

**Status:** Research note (practitioner)  
**Date:** 2026-09-10  
**Scope:** Tools that coding agents can drive (CLI / Python / HTTP API) to improve game-asset drawing, 抠图 (matting/cutout), slicing, upscaling, and seamless tile generation for the Dream Godot project.  
**Related in-repo:** [`docs/SEAMLESS.md`](../../SEAMLESS.md), [`docs/SCALE.md`](../../SCALE.md), `dream/tools/make_seamless_terrain.py`, `slice_normalize.py`, `normalize_assets.py`.

---

## 1. Tool matrix

| Capability | Tool | Agent fit | Notes | Primary source |
|---|---|---|---|---|
| Auto 抠图 (general) | **rembg** CLI/lib | ★★★★★ | `rembg i -m …`; batch-friendly; ONNX models | [danielgatis/rembg](https://github.com/danielgatis/rembg) |
| High-quality 抠图 | **BiRefNet** via rembg (`birefnet-general`, `-lite`, `-massive`, …) | ★★★★★ | Prefer over default for props/characters; heavier | [ZhengPeng7/BiRefNet](https://github.com/ZhengPeng7/BiRefNet) · rembg model list |
| Prompted 抠图 | rembg **`sam`** model + JSON prompts | ★★★★☆ | Point/box prompts via `-x`; still one CLI | rembg README `sam` example |
| Open-world segment | **SAM** (Meta) | ★★★☆☆ | Needs prompts; heavier install than rembg ONNX | [facebookresearch/segment-anything](https://github.com/facebookresearch/segment-anything) |
| Text → box → mask | **Grounded-SAM** / **Grounded-SAM-2** | ★★☆☆☆ | Strong quality; poor agent DX (CUDA env, multi-repo) | [IDEA-Research/Grounded-Segment-Anything](https://github.com/IDEA-Research/Grounded-Segment-Anything) · [Grounded-SAM-2](https://github.com/IDEA-Research/Grounded-SAM-2) |
| Soft alpha matting | **Matting Anything (MAM)** | ★★☆☆☆ | Mask→matte; pairs with Grounded-SAM text boxes | [SHI-Labs/Matting-Anything](https://github.com/shi-labs/matting-anything) |
| Upscale (portable) | **Real-ESRGAN ncnn-vulkan** | ★★★★★ | No Python CUDA; Windows zip CLI | [xinntao/Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) |
| Upscale (anime/pixel-ish) | Real-ESRGAN `-n realesrgan-x4plus-anime` | ★★★★★ | Better than generic for 2D sheets | [anime_model.md](https://github.com/xinntao/Real-ESRGAN/blob/master/docs/anime_model.md) |
| Upscale (classic anime) | **waifu2x-ncnn-vulkan** | ★★★☆☆ | Still useful; Real-ESRGAN anime often preferred | [nihui/waifu2x-ncnn-vulkan](https://github.com/nihui/waifu2x-ncnn-vulkan) |
| Slice / export | **Aseprite CLI** | ★★★★☆ | `--batch --split-slices --split-grid --sheet` | [aseprite.org/docs/cli](https://www.aseprite.org/docs/cli/) |
| Raster ops / batch | **ImageMagick** `magick` | ★★★★★ | Crop, montage, FFT (HDRI), edge tests | [ImageMagick](https://imagemagick.org/) · [Fourier examples](https://usage.imagemagick.org/fourier/) |
| Programmatic pipeline | **Pillow** (+ NumPy) | ★★★★★ | Already used in Dream tools; wrap/offset/crop | [Pillow docs](https://pillow.readthedocs.io/) |
| Wrap-paint (human) | **Aseprite Tiled Mode** / **GIMP Symmetry→Tiling** | ★☆☆☆☆ | Great for artists; weak for unattended agents | [Aseprite tiled mode](https://www.aseprite.org/docs/tiled-mode/) · [GIMP Symmetry Painting](https://docs.gimp.org/3.2/en/gimp-symmetry-dialog.html) |
| Make Seamless (post) | GIMP **Filters → Map → Tile Seamless** | ★★☆☆☆ | Script-Fu/Python-Fu possible; fuzzy results | [GIMP Tile Seamless](https://docs.gimp.org/3.2/en/gimp-filter-tile-seamless.html) |
| Procedural seamless | Dream `make_seamless_terrain.py` (periodic noise + `enforce_wrap`) | ★★★★★ | Deterministic; matches `BASE_TILE=32` | In-repo + [`SEAMLESS.md`](../../SEAMLESS.md) |
| Gen seamless (latent) | ComfyUI **circular / seamless latent tiling** nodes | ★★★☆☆ | Best *generation-time* seamlessness | e.g. [ComfyUI-seamless_latent_tiling](https://github.com/mikemojen/ComfyUI-seamless_latent_tiling) |
| Gen seamless (post) | ComfyUI **MakeSeamlessTexture** (offset + radial blend) | ★★★☆☆ | Fixes AI vignette / leftover seams | [SparknightLLC/ComfyUI-MakeSeamlessTexture](https://github.com/SparknightLLC/ComfyUI-MakeSeamlessTexture) |
| Controlled structure | **ControlNet Depth / Tile** in ComfyUI | ★★★☆☆ | Depth = layout; Tile = detail/upscale; can fight circular padding | [ComfyUI](https://github.com/comfyanonymous/ComfyUI) · ControlNet usage guides |
| Engine import QA | Godot **Nearest** + **`use_texture_padding`** | ★★★★★ | Fixes *engine* bleed, not art vignettes | [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html) · [TileSetAtlasSource](https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html) |
| Runtime visual QA | Godot MCP **`take_screenshot`** (+ `run_scene`) | ★★★★★ | Agent can see seams in-game | MCP `user-godot-tomyud1` / `take_screenshot` |

**License caution:** rembg itself is MIT; **model weights have their own licenses** (e.g. BRIA RMBG-2.0 may require a commercial agreement). Always check the linked model source before shipping assets commercially — [rembg README](https://github.com/danielgatis/rembg).

---

## 2. Recommended install list (Windows / PowerShell)

### Must (agent can run Dream art loops today)

| Package | Install hint | Verify |
|---|---|---|
| **Python 3.10–3.13** | [python.org](https://www.python.org/downloads/) or `winget install Python.Python.3.12` | `python --version` |
| **Pillow + NumPy** | `pip install pillow numpy` | `python -c "from PIL import Image; import numpy"` |
| **Godot 4.x** (project editor) | Steam / official build | Open `dream/` project |
| **Godot MCP** (Cursor) | Project addon + MCP server wired | Agent can `run_scene` / `take_screenshot` |

### Should (high ROI for AI sheets → game tiles)

| Package | Install hint | Verify |
|---|---|---|
| **rembg** (CPU or GPU) | `pip install "rembg[cpu,cli]"` or `"rembg[gpu,cli]"` | `rembg --help` |
| **BiRefNet weights** (via rembg) | First run of `-m birefnet-general` auto-downloads to `~/.u2net` / rembg model cache | `rembg i -m birefnet-general in.png out.png` |
| **Real-ESRGAN ncnn-vulkan** (Windows zip) | [Release zip](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip) → put on `PATH` or fixed tools dir | `realesrgan-ncnn-vulkan.exe -h` |
| **ImageMagick 7** | `winget install -e --id ImageMagick.ImageMagick` | `magick -version` |

### Optional (power / generation / pixel authorship)

| Package | When to install | Notes |
|---|---|---|
| **Aseprite** (+ CLI on PATH) | Human pixel polish + scripted `--split-slices` / `--split-grid` | [CLI docs](https://www.aseprite.org/docs/cli/) |
| **waifu2x-ncnn-vulkan** | Compare vs Real-ESRGAN anime on specific sheets | [nihui/waifu2x-ncnn-vulkan](https://github.com/nihui/waifu2x-ncnn-vulkan) |
| **ComfyUI** + API workflows | Controlled tile *generation* (Depth/Tile + seamless nodes) | Export **API Format** JSON; POST `http://127.0.0.1:8188/prompt` — [ComfyUI](https://github.com/comfyanonymous/ComfyUI) |
| **ControlNet** models (Depth, Tile) | Structure-preserving regen / detail upscale | Pair carefully with circular seamless nodes (ControlNet can reintroduce edge seams) |
| **CUDA / PyTorch** stack | Only if running Grounded-SAM / MAM / full Real-ESRGAN Python | Prefer ncnn + rembg ONNX for agents |
| **GIMP** (+ optional Python-Fu) | Occasional `Tile Seamless` / Symmetry Tiling | Prefer Pillow wrap for automation |

**PATH tip (PowerShell profile or session):**

```powershell
# Example: keep portable binaries out of Chinese-path friction if possible
$env:Path += ";D:\Tools\realesrgan-ncnn-vulkan;C:\Program Files\Aseprite"
```

---

## 3. Agent workflows

### 3.1 AI sheet → cutout prop / character (抠图)

1. Source PNG (black or busy bg) from `素材/` or generation output.  
2. **rembg** with BiRefNet for quality:

```powershell
rembg i -m birefnet-general .\in.png .\out_rgba.png
# Optional: -a / -dc per rembg docs for alpha refinement / decontaminate
```

3. If auto-cut fails (touching props, multi-object sheet): rembg **`sam`** with a point/box JSON (`-x`), or escalate to Grounded-SAM text prompts offline.  
4. Crop to non-transparent bbox with Pillow / ImageMagick; scale to [`SCALE.md`](../../SCALE.md) (`CHARACTER_HEIGHT_PX`, prop heights).  
5. Import in Godot; verify silhouette via MCP screenshot.

**Agent rule:** Prefer rembg ONNX over standing up full SAM/CUDA unless BiRefNet repeatedly fails.

### 3.2 Upscale before / after slice

- **Before slice:** upscale whole sheet if cells are soft / tiny.  
- **After cutout:** upscale single sprite, then nearest-neighbor snap to target px (avoid blurry mid sizes).

```powershell
realesrgan-ncnn-vulkan.exe -i sheet.png -o sheet_x4.png -n realesrgan-x4plus-anime -s 4
# Photo-like tilesets: -n realesrgan-x4plus
```

Then Pillow resize with `Image.Resampling.NEAREST` down to `BASE_TILE` multiples (see in-repo `slice_normalize.py` / `normalize_assets.py`).

### 3.3 Slice / atlas pipelines

| Stage | Tool | Example |
|---|---|---|
| Grid split | Pillow / ImageMagick | Crop `WxH` cells; Dream already normalizes to **32×32** |
| Named slices | Aseprite | `aseprite -b atlas.aseprite --split-slices --save-as out/{slice}.png` |
| Grid tiles | Aseprite | `--split-grid` or `--export-tileset` + `--sheet` / `--data` JSON |
| Montage QA | ImageMagick | `magick montage cell-*.png -tile 8x -geometry +0+0 preview.png` |

Official Aseprite CLI: [https://www.aseprite.org/docs/cli/](https://www.aseprite.org/docs/cli/).

### 3.4 Seamless terrain / repeating textures

**A. Deterministic (preferred for Dream grass today)**  
Run existing tool (periodic noise + hard wrap):

```powershell
python dream/tools/make_seamless_terrain.py
```

See [`SEAMLESS.md`](../../SEAMLESS.md): art vignettes ≠ engine bleed; fix edges in pixels, then Nearest + `use_texture_padding`.

**B. Classic offset-and-blend (agent-scriptable)**

1. `numpy.roll` / Pillow crop-paste offset by `W/2`, `H/2`.  
2. Blend or clone over the center cross (the old seam).  
3. Roll back; enforce `tile[:,0]==tile[:,-1]` and `tile[0]==tile[-1]` (as `enforce_wrap` does).  
4. Preview: tile 2×2 or 4×4 montage; look for vertical/horizontal lines.

**C. Fourier / frequency approaches**  
ImageMagick FFT/IFT ([examples](https://usage.imagemagick.org/fourier/)) and G'MIC “resynthesize texture [FFT]” help *noise-like* materials; poor for large unique motifs (houses, trees). Treat as optional experiment, not default.

**D. GIMP Make Seamless / wrap-paint**  
- Post: [Filters → Map → Tile Seamless](https://docs.gimp.org/3.2/en/gimp-filter-tile-seamless.html) (often needs hand correction).  
- Paint-time: [Symmetry Painting → Tiling](https://docs.gimp.org/3.2/en/gimp-symmetry-dialog.html) or Aseprite Tiled Mode — human-centric.

**E. ComfyUI / SD (generation, not post-only)**

Practical agent pattern:

1. Build a **fixed** workflow once in the UI; **Save (API Format)** JSON.  
2. For *true* tileability at sample time: insert **seamless / circular latent** node between model and sampler ([example](https://github.com/mikemojen/ComfyUI-seamless_latent_tiling)).  
3. Optional: **ControlNet Depth** (layout from a simple height map / sketch) or **ControlNet Tile** (detail-preserving refine / upscale).  
4. Warning from seamless-latent authors: **ControlNet spatial features are not circular-padded** — edges can regain seams; prefer low strength, or post-process with MakeSeamless / Pillow blend.  
5. Agent queues via HTTP:

```powershell
# Pseudocode — POST API-format workflow
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8188/prompt -ContentType 'application/json' -Body $apiJson
```

6. Always QA with a 3×3 tile preview **and** Godot TileMap screenshot (MCP).

### 3.5 Godot-specific: import + MCP screenshot QA

| Concern | Setting / action | Source |
|---|---|---|
| Soft pixels / atlas bleed | Project default canvas texture filter → **Nearest**; avoid Linear on pixel TileMapLayers | [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html) (filter is CanvasItem / project default since Godot 4, not classic import filter) |
| Hairline between tiles | `TileSetAtlasSource.use_texture_padding = true` (default) | [class docs](https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html) |
| Art vignette borders | **Cannot** be fixed by padding — remake seamless pixels (Dream terrain tool) | [`SEAMLESS.md`](../../SEAMLESS.md) |
| Scale lock | Slice/scale to `BASE_TILE = 32` before TileSet | [`SCALE.md`](../../SCALE.md) |
| Agent visual QA | `run_scene` (wait for runtime) → `take_screenshot` → read PNG (or `return_base64`) | Godot MCP `take_screenshot` |

**Import presets:** For 2D pixel packs, keep a project convention (document in SCALE): lossless PNG, no unintended mipmaps for atlases that must stay crisp, Nearest sampling. Re-import after mass overwrites so `.import` sidecars match.

**MCP QA loop (agent):**

1. Write / regenerate PNG under `dream/assets/…`.  
2. Ensure TileSet / scene references update.  
3. `run_scene` with runtime connected.  
4. `take_screenshot` → inspect for grid seams, dark borders, blur.  
5. Iterate Pillow/rembg/seamless script — not only engine toggles.

---

## 4. Gaps (what agents still struggle with)

| Gap | Why it hurts | Mitigation |
|---|---|---|
| **Semantic multi-object sheets** | rembg grabs “everything”; SAM needs clicks; Grounded-SAM is heavy | Pre-slice grid first; text-prompt Grounded-SAM offline; human Aseprite slices |
| **Soft matte (hair, foliage)** | Binary masks look cut-out | rembg alpha flags; MAM if quality critical |
| **Seamless ≠ aesthetic** | Offset-blend / Tile Seamless removes seams but can ghost motifs or flatten lighting | Prefer generate-with-circular-latent, or procedural tiles like Dream grass |
| **ControlNet vs circular seamless** | Spatial CN features break wrap continuity | Low CN weight; post MakeSeamless; or CN without claiming perfect tiles |
| **ComfyUI agent DX** | Must use **API Format** JSON; GPU VRAM; non-deterministic seeds | Pin seeds; version workflow files in repo; treat as optional stage |
| **Pixel-art identity** | ESRGAN invents detail / breaks grid | Upscale modestly → NEAREST snap to 32-grid; or draw in Aseprite |
| **Chinese paths / shells** | Some CLIs mishandle non-ASCII cwd | Prefer ASCII tool roots (`D:\Tools\…`); user-run tests when unsure |
| **License of weights** | Commercial ship risk | Audit rembg model licenses; prefer BiRefNet MIT weights when applicable |
| **No shared “art MCP”** | Agents glue CLIs ad hoc | Thin PowerShell/Python wrappers under `dream/tools/` with stable exit codes |

---

## 5. Sources (primary)

- rembg: https://github.com/danielgatis/rembg  
- BiRefNet: https://github.com/ZhengPeng7/BiRefNet  
- Segment Anything: https://github.com/facebookresearch/segment-anything  
- Grounded-SAM: https://github.com/IDEA-Research/Grounded-Segment-Anything  
- Grounded-SAM-2: https://github.com/IDEA-Research/Grounded-SAM-2  
- Matting Anything: https://github.com/shi-labs/matting-anything  
- Real-ESRGAN: https://github.com/xinntao/Real-ESRGAN  
- Real-ESRGAN anime notes: https://github.com/xinntao/Real-ESRGAN/blob/master/docs/anime_model.md  
- waifu2x-ncnn-vulkan: https://github.com/nihui/waifu2x-ncnn-vulkan  
- Aseprite CLI: https://www.aseprite.org/docs/cli/  
- ImageMagick Fourier: https://usage.imagemagick.org/fourier/  
- GIMP Tile Seamless: https://docs.gimp.org/3.2/en/gimp-filter-tile-seamless.html  
- GIMP Symmetry Painting: https://docs.gimp.org/3.2/en/gimp-symmetry-dialog.html  
- ComfyUI: https://github.com/comfyanonymous/ComfyUI  
- Seamless latent tiling (example): https://github.com/mikemojen/ComfyUI-seamless_latent_tiling  
- MakeSeamlessTexture nodes: https://github.com/SparknightLLC/ComfyUI-MakeSeamlessTexture  
- Godot importing images: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html  
- Godot TileSetAtlasSource: https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html  
- Godot using tilesets: https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html  

---

## 6. Prioritized「请用户准备」

### Must

1. **Python 3.10+** on PATH + `pip install pillow numpy`  
2. **Godot 4** project opens; **MCP** can run a scene and **`take_screenshot`**  
3. Confirm agent may write under `dream/assets/` and `dream/tools/`

### Should

4. `pip install "rembg[cpu,cli]"` (or GPU extra) and one successful `birefnet-general` run (downloads weights)  
5. **Real-ESRGAN ncnn-vulkan** Windows portable on PATH  
6. **ImageMagick** via `winget install -e --id ImageMagick.ImageMagick`

### Optional

7. **Aseprite** with CLI on PATH (slice / tiled paint)  
8. **ComfyUI** local server + one saved **API Format** seamless/Depth/Tile workflow  
9. CUDA PyTorch only if you want Grounded-SAM / MAM quality beyond rembg  
10. **GIMP** for rare manual Make Seamless / symmetry tiling  

---

*End of research note.*
