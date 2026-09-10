# Agent art tooling — user prep

## Must

1. Python 3.10+ with `pillow` `numpy`  
2. Godot 4 + MCP (`run_scene` / `take_screenshot`)  
3. Agent may write `dream/assets/` and `dream/tools/`

## Should

4. `pip install "rembg[cpu,cli]"` — verify with **explicit** BiRefNet (do **not** use bare `rembg i`; default is now `bria-rmbg` / non-commercial):  
   `rembg i -m birefnet-general in.png out.png`  
5. Real-ESRGAN ncnn-vulkan on PATH (prefer over Upscayl-ncnn for agents; AGPL)  
6. ImageMagick: `winget install -e --id ImageMagick.ImageMagick`

## Optional

7. Aseprite CLI  
8. ComfyUI + exported API workflow (seamless / Depth / Tile / IP-Adapter / inpaint)  
9. IOPaint + LaMa (`iopaint run --model=lama`) for erase / hole fill  
10. Florence-2 / SAM 2 / Grounded-SAM-2 only when rembg fails multi-object sheets  
11. CUDA stack only for Florence/SAM2/Grounded stacks  
12. GIMP for rare manual Tile Seamless  

## Agent defaults

| Task | Command / tool |
| --- | --- |
| Seamless grass/water | `python dream/tools/make_seamless_terrain.py` |
| 抠图 prop/NPC | `rembg i -m birefnet-general ...` (never default `bria-rmbg` for ship) |
| 补缺失 / 去脏 | `iopaint run --model=lama ...` (+ mask) |
| Upscale AI sheet | `realesrgan-ncnn-vulkan.exe -n realesrgan-x4plus-anime ...` then NEAREST snap |
| QA | MCP screenshot vs A09 / LAYOUT / **AREA_FRAMEWORK** silhouette |

## Gaps

- rembg cannot invent correct door facing  
- Seamless post-process ≠ good aesthetics — prefer generate wrap tiles  
- Inpaint can drift palette — always QA on real tiles  
- Check model licenses before shipping commercial packs (`bria-rmbg` needs BRIA agreement)  

Full matrix: `docs/research/practitioners/agent-art-tooling.md`  
Painting skill: `.cursor/skills/painting-asset-craft/`
