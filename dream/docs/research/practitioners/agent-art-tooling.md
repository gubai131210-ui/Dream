# Agent art tooling — cutout, inpaint, upscale, slice, seamless (2025–2026)

**Status:** Research note (practitioner), Batch B refresh  
**Date:** 2026-09-10  
**Scope:** CLI / Python / HTTP-first tools that coding agents can drive for Dream (Godot 4) asset loops: 抠图、补缺失、换背景、放大、切序列帧、无缝贴图。  
**Related in-repo:** [`docs/SEAMLESS.md`](../../SEAMLESS.md), [`docs/SCALE.md`](../../SCALE.md), `dream/tools/make_seamless_terrain.py`, `slice_normalize.py`, `normalize_assets.py`, `art_pipeline_continue.py`.  
**Skill digest:** [`.cursor/skills/realistic-scene-craft/reference-tooling.md`](../../../.cursor/skills/realistic-scene-craft/reference-tooling.md).

### What’s new vs prior note

| Delta | Why it matters for Dream agents |
|---|---|
| **rembg default is now `bria-rmbg`** | Default weights are **non-commercial without BRIA agreement**. Agents must pass `-m birefnet-general` (or another MIT-safe model) for shippable packs. |
| **Inpaint / erase stack** | IOPaint + LaMa (and SD inpaint) fill the “补缺失 / 去脏物 / 换背景空洞” gap rembg cannot invent. |
| **Florence-2 + SAM 2** | Text→box→mask without Grounding-DINO-only paths; better multi-object sheet parsing when rembg grabs everything. |
| **Upscayl vs Real-ESRGAN** | GUI vs portable CLI; Upscayl-ncnn is AGPL — prefer upstream Real-ESRGAN ncnn zip for agent PATH. |
| **Compress note** | Official `@squoosh/cli` is retired; use ImageMagick / oxipng / community `@frostoven/squoosh-cli` carefully. |
| **MCP reality** | No first-party “art MCP” in Dream; Godot MCP for QA; optional ComfyUI MCP; preferred pattern = thin `dream/tools/` wrappers. |

---

## 1. Must / Should / Optional — Windows + PowerShell

### Must (agent can close Dream art loops today)

| Package | Install | Verify |
|---|---|---|
| **Python 3.11–3.13** | `winget install -e --id Python.Python.3.12` or [python.org](https://www.python.org/downloads/) | `python --version` |
| **Pillow + NumPy** | `pip install pillow numpy` | `python -c "from PIL import Image; import numpy"` |
| **Godot 4.x** | Official / Steam build opening `dream/` | Project loads |
| **Godot MCP** (`user-godot-tomyud1`) | Addon + Cursor MCP wired | `run_scene` + `take_screenshot` |

### Should (high ROI for AI sheets → game tiles)

| Package | Install | Verify |
|---|---|---|
| **rembg** (CLI) | `pip install "rembg[cpu,cli]"` or `"rembg[gpu,cli]"` | `rembg --help` |
| **BiRefNet via rembg** (explicit model) | First run downloads into `~/.rembg/models/` | `rembg i -m birefnet-general in.png out.png` |
| **Real-ESRGAN ncnn-vulkan** | [Windows zip](https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip) → `D:\Tools\…` on PATH | `realesrgan-ncnn-vulkan.exe -h` |
| **ImageMagick 7** (`magick`) | `winget install -e --id ImageMagick.ImageMagick` | `magick -version` |

**Commercial-safe rembg rule:** never rely on bare `rembg i in.png out.png` — current default is **`bria-rmbg`**. Always:

```powershell
rembg i -m birefnet-general .\in.png .\out_rgba.png
# Optional edge polish for newer models:
# rembg i -m birefnet-general -dc .\in.png .\out_rgba.png
```

### Optional (generation / inpaint / pixel authorship / MCP)

| Package | When | Install hint |
|---|---|---|
| **IOPaint** + **LaMa** | Erase watermarks, fill holes, seam clone, simple bg fill | `pip install iopaint` → `iopaint run --model=lama --device=cpu --image=… --mask=… --output=…` |
| **Aseprite** (+ CLI on PATH) | Named slices, `--split-grid`, human tiled paint | [CLI docs](https://www.aseprite.org/docs/cli/) |
| **ComfyUI** + API Format workflows | Seamless gen, ControlNet Depth/Tile, IP-Adapter, SD inpaint | Local server `http://127.0.0.1:8188` |
| **ControlNet** Depth + Tile models | Layout lock / detail refine | Via ComfyUI Manager |
| **IP-Adapter** (ComfyUI_IPAdapter_plus) | Style / identity from a reference sheet | Keep weights pinned; daisy-chain Unified Loader |
| **Florence-2** (+ optional SAM 2) | Caption / phrase grounding → boxes for masks | HF `microsoft/Florence-2-base` (+ [Grounded-SAM-2 Florence demos](https://github.com/IDEA-Research/Grounded-SAM-2)) |
| **transparent-background** | Alternate matting (InSPyReNet); heavier PyTorch | `pip install transparent-background` |
| **Upscayl** (GUI) / **upscayl-ncnn** | Human batch upscale; CLI exists but **AGPL** | Prefer Real-ESRGAN zip for agents |
| **waifu2x-ncnn-vulkan** | Compare vs Real-ESRGAN anime on specific sheets | [nihui releases](https://github.com/nihui/waifu2x-ncnn-vulkan) |
| **oxipng** / ImageMagick | Lossless PNG crush before Godot import | `winget` / cargo / scoop |
| **@frostoven/squoosh-cli** | Experimental WASM codecs; Google `@squoosh/cli` retired | `npx @frostoven/squoosh-cli --help` — not Must |
| **ComfyUI MCP** | Optional Cursor bridge to local Comfy | e.g. [joenorton/comfyui-mcp-server](https://github.com/joenorton/comfyui-mcp-server), [artokun/comfyui-mcp](https://github.com/artokun/comfyui-mcp) |
| **CUDA / PyTorch** | Only for Florence/SAM2/Grounded stacks or full SD | Prefer ONNX rembg + ncnn upscale first |
| **GIMP** | Rare manual Tile Seamless / symmetry | Prefer Pillow wrap for automation |

**PATH tip (ASCII tool root — Chinese-path friction):**

```powershell
$env:Path += ";D:\Tools\realesrgan-ncnn-vulkan;C:\Program Files\Aseprite"
# Optional: pin rembg model cache
$env:REMBG_HOME = "D:\Tools\rembg-home"
```

---

## 2. Task → tool对照表

| Task | First choice (agent) | Escalate / alternate | Avoid / caveats |
|---|---|---|---|
| **Seamless grass/water tiles** | In-repo `python dream/tools/make_seamless_terrain.py` + Nearest + `use_texture_padding` | ComfyUI circular latent → MakeSeamlessTexture post; Pillow offset-blend + `enforce_wrap` | GIMP “Tile Seamless” alone; ControlNet Tile at high strength with circular latent (re-seams) |
| **抠图 (prop / NPC)** | `rembg i -m birefnet-general` (+ `-dc`) | `birefnet-portrait` for characters; rembg `sam` + JSON points; Florence-2 boxes → SAM 2; `transparent-background` | Default `bria-rmbg` for commercial ship; rembg on multi-object sheets without pre-slice |
| **语义多物体切分** | Pre-grid slice (Pillow/Aseprite) then rembg per cell | Florence-2 `<CAPTION_TO_PHRASE_GROUNDING>` / phrase grounding → SAM 2; Grounded-SAM-2 | Hoping rembg picks one object from a busy sheet |
| **补缺失元素 / 去脏物** | **IOPaint LaMa** `iopaint run --model=lama` with mask | ComfyUI SD/SDXL inpaint; PowerPaint / BrushNet via IOPaint | rembg (only removes bg); naive clone-stamp without mask QA |
| **换背景** | rembg cutout → Pillow composite onto new plate | IOPaint erase old bg leftovers; ComfyUI img2img + IP-Adapter for style match | Shipping with BRIA/RMBG weights without license |
| **放大 (AI sheet / soft pixels)** | `realesrgan-ncnn-vulkan.exe -n realesrgan-x4plus-anime -s 4` then **NEAREST** snap to `BASE_TILE` | Photo tiles: `-n realesrgan-x4plus`; Upscayl GUI for humans | Upscayl-ncnn as redistributed agent binary (AGPL); over-upscale then Linear filter in Godot |
| **切序列帧 / atlas** | Pillow grid / in-repo `slice_normalize.py`; Aseprite `--split-slices` / `--split-grid` / `--sheet` | ImageMagick `magick` crop + `montage` QA | Manual one-by-one export as default agent path |
| **压缩 / 格式** | `magick` or oxipng on final PNG | Community squoosh-cli for experiments | Official Squoosh CLI (unmaintained) as production dependency |
| **In-engine visual QA** | Godot MCP `run_scene` → `take_screenshot` | 2×2 / 3×3 tile montage via `magick montage` | Trusting only file-side seam checks |

---

## 3. Expanded tool matrix (agent fit)

| Capability | Tool | Agent fit | License (weights / code — verify before ship) | Source |
|---|---|---|---|---|
| Auto 抠图 CLI | **rembg** | ★★★★★ | Code MIT; **each `-m` has own weight license** | [danielgatis/rembg](https://github.com/danielgatis/rembg) |
| Default rembg model | **`bria-rmbg` (RMBG-2.0)** | ★★★★☆ quality / ★☆ commercial | **CC BY-NC / BRIA commercial agreement** | [briaai/RMBG-2.0](https://huggingface.co/briaai/RMBG-2.0) |
| HQ 抠图 (ship-safe default) | **BiRefNet** via `-m birefnet-*` | ★★★★★ | BiRefNet **MIT** (code + typical open weights) | [ZhengPeng7/BiRefNet](https://github.com/ZhengPeng7/BiRefNet) |
| Prompted mask | rembg **`sam`** + `-x` JSON | ★★★★☆ | SAM lineage — check Meta terms for weights used | rembg README |
| Video/image segment SOTA | **SAM 2** | ★★★☆☆ | Code/weights **Apache-2.0** | [facebookresearch/sam2](https://github.com/facebookresearch/sam2) |
| Text → box → mask | **Grounded-SAM-2** (+ Florence-2 demos) | ★★☆☆☆ DX / ★★★★☆ quality | Mix of Apache/MIT + Grounding-DINO terms | [IDEA-Research/Grounded-SAM-2](https://github.com/IDEA-Research/Grounded-SAM-2) |
| VL grounding / caption | **Florence-2** | ★★★☆☆ | **MIT** | [microsoft/Florence-2-base](https://huggingface.co/microsoft/Florence-2-base) |
| Soft matte alt | **transparent-background** (InSPyReNet) | ★★★☆☆ | Check package + checkpoint licenses | [PyPI transparent-background](https://pypi.org/project/transparent-background/) |
| Soft matte research | **Matting Anything (MAM)** | ★★☆☆☆ | Research stack; heavy | [shi-labs/matting-anything](https://github.com/shi-labs/matting-anything) |
| Erase / hole fill | **LaMa** via **IOPaint** | ★★★★★ | LaMa **Apache-2.0**; IOPaint Apache-2.0 | [advimman/lama](https://github.com/advimman/lama) · [Sanster/IOPaint](https://github.com/Sanster/IOPaint) |
| Gen inpaint / outpaint | ComfyUI SD/SDXL inpaint | ★★★☆☆ | Checkpoint-dependent (often non-commercial Civitai) | [ComfyUI](https://github.com/comfyanonymous/ComfyUI) |
| Style lock | **IP-Adapter** | ★★★☆☆ | Adapter + base model licenses | [cubiq/ComfyUI_IPAdapter_plus](https://github.com/cubiq/ComfyUI_IPAdapter_plus) |
| Structure / detail | **ControlNet Depth / Tile** | ★★★☆☆ | ControlNet Apache-2.0; base model varies | ComfyUI + CN models |
| Upscale portable | **Real-ESRGAN ncnn-vulkan** | ★★★★★ | Real-ESRGAN **BSD-3-Clause** | [xinntao/Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) |
| Upscale GUI | **Upscayl** | ★☆☆☆☆ agent / ★★★★ human | App + **upscayl-ncnn AGPL-3.0** | [upscayl/upscayl](https://github.com/upscayl/upscayl) · [upscayl-ncnn](https://github.com/upscayl/upscayl-ncnn) |
| Slice / sheet | **Aseprite CLI** | ★★★★☆ | Proprietary app (paid); CLI automation OK if licensed | [aseprite.org/docs/cli](https://www.aseprite.org/docs/cli/) |
| Raster batch | **ImageMagick `magick`** | ★★★★★ | Apache-2.0 | [imagemagick.org](https://imagemagick.org/) |
| Programmatic | **Pillow** (+ NumPy) | ★★★★★ | HPND / PIL license | [Pillow docs](https://pillow.readthedocs.io/) |
| Compress experiment | **@frostoven/squoosh-cli** | ★★☆☆☆ | Check package; Google CLI retired | [npm @frostoven/squoosh-cli](https://www.npmjs.com/package/@frostoven/squoosh-cli) |
| Seamless gen-time | ComfyUI circular latent | ★★★☆☆ | Node license varies | e.g. [seamless_latent_tiling](https://github.com/mikemojen/ComfyUI-seamless_latent_tiling) |
| Seamless post | MakeSeamlessTexture / Pillow roll-blend | ★★★☆☆ | — | [SparknightLLC/ComfyUI-MakeSeamlessTexture](https://github.com/SparknightLLC/ComfyUI-MakeSeamlessTexture) |
| Procedural seamless | Dream terrain tool | ★★★★★ | In-repo | [`SEAMLESS.md`](../../SEAMLESS.md) |
| Engine QA | Godot Nearest + `use_texture_padding` | ★★★★★ | Godot license | [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html) |
| Runtime QA | MCP `take_screenshot` | ★★★★★ | — | Godot MCP |

---

## 4. Agent invocation patterns

### 4.1 Preferred architecture for Cursor agents

```
[Human prep: tools on PATH / weights cached]
        │
        ▼
 dream/tools/*.py  (stable CLI: exit codes, ASCII paths, BASE_TILE=32)
        │
        ├─ rembg / realesrgan / magick / iopaint   ← subprocess
        ├─ ComfyUI HTTP API                        ← optional gen stage
        └─ Godot MCP run_scene + take_screenshot   ← visual QA
```

**Do not** invent a new MCP for every binary. Wrap CLIs in PowerShell/Python under `dream/tools/` with:

- Fixed model flags (`-m birefnet-general`)
- Inputs/outputs under `dream/assets/…`
- Non-zero exit on missing binary
- Optional `--dry-run`

**MCP options today**

| Layer | Role | Notes |
|---|---|---|
| **Godot MCP** | Scene run + screenshot QA | Already in Dream toolchain |
| **ComfyUI MCP** (optional) | Queue workflows from chat | Needs local Comfy + pinned API JSON; heavier than raw HTTP |
| **rembg HTTP** `rembg s` | Long-running cutout service | Useful if many sequential calls; still pin model |
| **IOPaint** `iopaint start` | HTTP inpaint at `:8080` | Batch prefer `iopaint run` |

### 4.2 抠图

```powershell
# Ship-safe default for Dream
rembg i -m birefnet-general -dc .\raw\prop.png .\sprites\prop_rgba.png

# Batch folder
rembg p -m birefnet-general .\raw\props\ .\sprites\props_rgba\

# Multi-object failure → SAM points (example)
rembg i -m sam -x '{ "sam_prompt": [{"type": "point", "data": [120, 80], "label": 1}] }' `
  .\sheet.png .\one_object.png
```

Then bbox crop + scale with Pillow / in-repo normalizers to [`SCALE.md`](../../SCALE.md).

### 4.3 补缺失 / erase / 简单换背景空洞

```powershell
# Mask: white = region to fill/erase, black = keep
iopaint run --model=lama --device=cpu `
  --image=D:\art\in `
  --mask=D:\art\masks `
  --output=D:\art\out
```

HTTP (agent loop): `iopaint start --model=lama --device=cpu --port=8080` then POST multipart to `/inpaint` (see IOPaint `/docs`).

**Dream mapping:** use LaMa to remove AI watermark blobs / broken tile corners *before* seamless enforce; use SD inpaint only when you need *new* semantic content (door facing, missing prop) — and still human-check orientation rules (LAYOUT / A09).

### 4.4 换背景

1. Cutout with BiRefNet.  
2. Optional LaMa on residual fringe.  
3. Pillow alpha-composite onto target plate (solid, gradient, or village plate).  
4. NEAREST snap; MCP screenshot.

### 4.5 Upscale → snap

```powershell
realesrgan-ncnn-vulkan.exe -i sheet.png -o sheet_x4.png -n realesrgan-x4plus-anime -s 4
# Then Pillow Image.Resampling.NEAREST down to BASE_TILE multiples
```

Upscayl GUI is fine for humans; agents should call **Real-ESRGAN ncnn** to avoid AGPL redistribution ambiguity.

### 4.6 Slice / sequence frames

| Stage | Tool | Example |
|---|---|---|
| Grid split | Pillow / `slice_normalize.py` | Cells → 32×32 |
| Named slices | Aseprite | `aseprite -b atlas.aseprite --split-slices --save-as out/{slice}.png` |
| Sheet + JSON | Aseprite | `--sheet` / `--data` |
| QA montage | ImageMagick | `magick montage cell-*.png -tile 8x -geometry +0+0 preview.png` |

### 4.7 Seamless

**A. Deterministic (Dream grass today)**

```powershell
python dream/tools/make_seamless_terrain.py
```

**B. Offset-blend (scriptable)** — `numpy.roll` → blend cross → enforce `L==R`, `T==B` → 3×3 montage.

**C. ComfyUI generation**

1. Build once in UI → **Save (API Format)**.  
2. Circular / seamless latent between model and sampler.  
3. Optional ControlNet **Depth** (layout) or **Tile** (detail) at **low** weight — CN spatial maps are often *not* circular-padded.  
4. Optional **IP-Adapter** for style match to an existing village palette.  
5. Queue:

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:8188/prompt `
  -ContentType 'application/json' -Body $apiJson
# Poll GET /history/{prompt_id} or WebSocket /ws?clientId=...
```

6. QA: `magick` 3×3 tile **and** Godot MCP screenshot.

Official route list: [ComfyUI server routes](https://docs.comfy.org/development/comfyui-server/comms_routes).

### 4.8 Florence-2 + SAM 2 (when rembg fails semantically)

Offline pattern (from Grounded-SAM-2 Florence demos):

1. Florence-2 caption or `<CAPTION_TO_PHRASE_GROUNDING>` / referring expression → bboxes.  
2. SAM 2 `predict(box=…)` → masks.  
3. Export RGBA; feed Dream normalizers.

Agent DX is weaker than rembg (CUDA/transformers), so treat as **Optional escalate**, not default.

---

## 5. License cheat-sheet (commercial publish)

| Use in shipped game assets | Prefer | Do not use without extra agreement |
|---|---|---|
| Background removal | **BiRefNet** (`birefnet-general` / lite / portrait) | **`bria-rmbg` / RMBG-2.0** (CC BY-NC + BRIA commercial) |
| Segmentation assist | SAM 2 (Apache-2.0), Florence-2 (MIT) | Unclear Civitai merges; read each card |
| Erase / fill | LaMa (Apache-2.0) via IOPaint | SD checkpoints with “non-commercial” tags |
| Upscale | Real-ESRGAN ncnn (BSD-3) | Redistributing **Upscayl-ncnn** binaries (AGPL) inside your tooling without compliance |
| Gen art | Pin checkpoint licenses in a project allowlist | Random community checkpoints |

**Rule:** rembg MIT ≠ free to use default weights. Log `-m` model id used per asset batch.

---

## 6. Gaps (agents still struggle)

| Gap | Mitigation |
|---|---|
| rembg cannot invent correct **door facing** / ecology | LAYOUT rules + human or SD inpaint with reference; never auto-trust gen |
| Soft hair / foliage mattes | `-dc` / `-a` on BiRefNet; MAM or transparent-background only if needed |
| Seamless post ≠ aesthetics | Prefer procedural Dream tool or circular-latent gen |
| ControlNet vs wrap continuity | Low CN strength; Pillow/MakeSeamless post |
| No shared art MCP | Thin `dream/tools/` wrappers + Godot screenshot QA |
| Chinese paths | ASCII `D:\Tools\…`; user runs final Godot tests when shell encoding fails |
| Squoosh CLI ecosystem | Prefer `magick` / oxipng for production crush |

---

## 7. 请用户准备（人类清单）

### Must

1. **Python 3.11+** on PATH；`pip install pillow numpy`  
2. **Godot 4** 能打开 `dream/`；Cursor **Godot MCP** 可 `run_scene` + `take_screenshot`  
3. 允许 agent 写入 `dream/assets/` 与 `dream/tools/`  
4. （商业目标）确认抠图使用 **`-m birefnet-general`**，不要用默认 `bria-rmbg` 除非已签 BRIA

### Should

5. `pip install "rembg[cpu,cli]"`，并成功跑通一次 BiRefNet（缓存权重到 `REMBG_HOME` 或 `~/.rembg`）  
6. **Real-ESRGAN ncnn-vulkan** 解压到 `D:\Tools\…` 并加入 PATH  
7. `winget install -e --id ImageMagick.ImageMagick` → `magick -version`

### Optional

8. `pip install iopaint`，准备好 mask 目录约定（白=修补）  
9. **Aseprite** 已授权且 CLI 在 PATH  
10. 本机 **ComfyUI** + 一份导出的 **API Format** 工作流（seamless / Depth / Tile / IP-Adapter / inpaint）  
11. 可选 ComfyUI MCP；或仅用 HTTP `/prompt`  
12. Florence-2 / SAM 2 仅在需要文本点选多物体时再装 CUDA 栈  
13. Upscayl GUI（人用）；agent 仍走 Real-ESRGAN zip

---

## 8. Sources / URLs

### Cutout / segment

- rembg: https://github.com/danielgatis/rembg  
- BiRefNet: https://github.com/ZhengPeng7/BiRefNet  
- BRIA RMBG-2.0 (non-commercial default weights): https://huggingface.co/briaai/RMBG-2.0 · https://github.com/bria-ai/rmbg-2.0  
- SAM: https://github.com/facebookresearch/segment-anything  
- SAM 2: https://github.com/facebookresearch/sam2  
- Grounded-SAM: https://github.com/IDEA-Research/Grounded-Segment-Anything  
- Grounded-SAM-2 (+ Florence demos): https://github.com/IDEA-Research/Grounded-SAM-2  
- Florence-2: https://huggingface.co/microsoft/Florence-2-base  
- Matting Anything: https://github.com/shi-labs/matting-anything  
- transparent-background: https://pypi.org/project/transparent-background/ · https://github.com/plemeri/transparent-background  

### Inpaint / erase

- LaMa: https://github.com/advimman/lama  
- IOPaint: https://github.com/Sanster/IOPaint · https://www.iopaint.com/  

### Upscale / compress

- Real-ESRGAN: https://github.com/xinntao/Real-ESRGAN  
- Real-ESRGAN anime notes: https://github.com/xinntao/Real-ESRGAN/blob/master/docs/anime_model.md  
- Real-ESRGAN ncnn Windows zip: https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-windows.zip  
- waifu2x-ncnn-vulkan: https://github.com/nihui/waifu2x-ncnn-vulkan  
- Upscayl: https://github.com/upscayl/upscayl  
- upscayl-ncnn (AGPL): https://github.com/upscayl/upscayl-ncnn  
- Community squoosh-cli: https://www.npmjs.com/package/@frostoven/squoosh-cli  

### Slice / raster / seamless UI

- Aseprite CLI: https://www.aseprite.org/docs/cli/  
- ImageMagick: https://imagemagick.org/ · Fourier: https://usage.imagemagick.org/fourier/  
- Pillow: https://pillow.readthedocs.io/  
- GIMP Tile Seamless: https://docs.gimp.org/3.2/en/gimp-filter-tile-seamless.html  
- GIMP Symmetry Painting: https://docs.gimp.org/3.2/en/gimp-symmetry-dialog.html  
- Aseprite tiled mode: https://www.aseprite.org/docs/tiled-mode/  

### Generation / API / MCP

- ComfyUI: https://github.com/comfyanonymous/ComfyUI  
- ComfyUI server routes: https://docs.comfy.org/development/comfyui-server/comms_routes  
- Seamless latent example: https://github.com/mikemojen/ComfyUI-seamless_latent_tiling  
- MakeSeamlessTexture: https://github.com/SparknightLLC/ComfyUI-MakeSeamlessTexture  
- IP-Adapter plus: https://github.com/cubiq/ComfyUI_IPAdapter_plus  
- ComfyUI MCP (examples): https://github.com/joenorton/comfyui-mcp-server · https://github.com/artokun/comfyui-mcp  

### Godot

- Importing images: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html  
- TileSetAtlasSource: https://docs.godotengine.org/en/stable/classes/class_tilesetatlassource.html  
- Using tilesets: https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html  

---

*End of Batch B research note.*
