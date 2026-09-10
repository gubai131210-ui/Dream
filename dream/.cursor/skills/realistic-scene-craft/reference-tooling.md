# Agent art tooling — user prep

## Must

1. Python 3.10+ with `pillow` `numpy`  
2. Godot 4 + MCP (`run_scene` / `take_screenshot`)  
3. Agent may write `dream/assets/` and `dream/tools/`

## Should

4. `pip install "rembg[cpu,cli]"` — verify:  
   `rembg i -m birefnet-general in.png out.png`  
5. Real-ESRGAN ncnn-vulkan on PATH  
6. ImageMagick: `winget install -e --id ImageMagick.ImageMagick`

## Optional

7. Aseprite CLI  
8. ComfyUI + exported API workflow (seamless / Depth / Tile)  
9. CUDA stack only for Grounded-SAM / MAM  
10. GIMP for rare manual Tile Seamless  

## Agent defaults

| Task | Command / tool |
| --- | --- |
| Seamless grass/water | `python dream/tools/make_seamless_terrain.py` |
| 抠图 prop/NPC | `rembg i -m birefnet-general ...` |
| Upscale AI sheet | `realesrgan-ncnn-vulkan.exe -n realesrgan-x4plus-anime ...` |
| QA | MCP screenshot vs A09 / LAYOUT rules |

## Gaps

- rembg cannot invent correct door facing  
- Seamless post-process ≠ good aesthetics — prefer generate wrap tiles  
- Check model licenses before shipping commercial packs  

Full matrix: `docs/research/practitioners/agent-art-tooling.md`
