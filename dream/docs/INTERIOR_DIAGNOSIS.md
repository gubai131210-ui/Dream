# Interior ugliness — root cause diagnosis

**Status:** DIAGNOSED 2026-09-11  
**Symptom:** “还是很丑” after Wave A specialty props + differentiated layouts  
**Feedback loop:** `python dream/tools/qa_interior_prop_quality.py` (unique colors / edge / size)

## Verdict

**Not a layout bug.** Profiles and room silhouettes are now different enough.  
**The art layer is still placeholder-grade**, so rooms read as “programmer boxes on wood grid” next to the painted outdoor world.

| Layer | Status | Why it fails the eye |
| --- | --- | --- |
| Enter/exit portals | OK | Real scenes, return paths |
| Room sizes / zones | OK-ish | Briefs followed; aisle readable |
| Floor/wall tiles | Weak | Procedural plank OK-ish; walls lack beam/window craft of reference sheet |
| Specialty props (`make_interior_specialty.py`) | **FAIL** | PIL `rectangle` / flat fills — not pixel craft |
| Outdoor B11 props indoors | **Mismatch** | Real 3/4 shaded art + **grass tufts on benches** |
| Reference plates | **Unused** | `c01_room_reference_cozy.png` never drove runtime tiles |
| Dynamic FX | Partial | Fire/forge exist but sit on ugly base props |

## Quantitative proof (agent-run)

Same harness, opaque unique colors + edge energy:

| Set | avg unique colors | avg edge | avg file bytes |
| --- | ---: | ---: | ---: |
| Interior specialty props (26) | **~4** | **~9** | **~262 B** |
| Outdoor props sample (12) | **~1029** | **~25** | **~3413 B** |
| Foundation plank floors (4) | ~123 | ~10 | ~1536 B |

Specialty props are **~250× fewer colors** than outdoor props. That is the “ugly” signal — not “wrong sofa position.”

Examples:
- `fireplace_00.png` ≈ brown bar + grey sides + black hole (2–4 flat colors)
- `shelf_00.png` ≈ brown slab + RGB jar squares
- `bed_double_00.png` ≈ brown frame + blue fill + two cream pillows
- Outdoor `crate_0.png` / `bench_0.png` = multi-tone wood, X-braces, top-left light, real silhouette

## What skills / MD already forbade (and we violated)

From `painting-asset-craft`:

1. Paint order: **silhouette → value → color → detail** — specialty props skipped value/detail  
2. Prop size band: 16–96px with readable form — we shipped flat orthographic boxes  
3. Camera lock: outdoor is **3/4 south-facing**; PIL props are **orthographic UI icons** → angle clash in one room  
4. In-engine QA at integer zoom on real ground — never gated specialty props on color/edge metrics  

From `INTERIOR_FOUNDATION` / Verdant consensus:

- Walls should be **lighter than floors** with beam language matching cottage  
- Cozy = timber craft + local light — not “more ColorRect-like furniture”  
- Reference mood plates exist but were labeled “not runtime” and then **never sliced**

From outdoor `building_00`:

- Cream vertical siding, dark beams, warm lantern, clutter planters  
- Interior specialty art does not share that language at all

## Secondary issues (amplify ugliness)

1. **Mixed art languages in one room** — B11 crate/sack next to PIL fireplace = uncanny  
2. **Outdoor bench grass** still visible indoors when `bench_0` is used as “table”  
3. **Uniform 0.55–0.75 scale** on tiny flat sprites → soft, floaty postage stamps  
4. **No contact shadow craft** matching B11 (Polygon blob only)  
5. Layout density still sparse vs reference cozy homes → empty floor dominates eye

## What will NOT fix it

- More profile swaps / more rooms  
- Stronger `CanvasModulate` / bigger PointLights  
- Another pass of PIL rectangle generators  
- Copying outdoor assembler patterns into interiors  

## What WILL fix it (ordered)

1. **Kill PIL specialty as ship art** — quarantine or delete from gameplay paths  
2. **Author a B11-matched interior furniture sheet** (AI sheet → rembg → slice → SCALE normalize) OR draw in Aseprite following outdoor light quadrant  
3. **Slice `c01_room_reference_cozy.png` into real wall/door/window tiles** (rows already labeled) instead of regenerating weak cream stripes  
4. **Per-room furniture from painted islands**, same facing lock as outdoor props  
5. Gate CI/tool: `qa_interior_prop_quality.py` must **fail** if unique colors &lt; 40 or edge &lt; 12 for any gameplay prop  
6. Only then re-place by `INTERIOR_ROOM_BRIEFS` zones  

## 禁止偷懒（本诊断）

- 禁止把「布局换了」当成「好看了」  
- 禁止继续用 PIL 矩形冒充实心像素家具  
- 禁止室内继续塞带草地的室外 bench  
- 禁止无视已有 `c01_room_reference_cozy` 参考条去另写劣质墙砖  
- 禁止无质量闸就批量生成「新素材」交差  

## Next step

Await user OK to start **art rebuild pass** (sheet → cut → profiles rewire), not another profile-only tweak.
