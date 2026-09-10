# Research: Octopath Traveler (HD-2D) — town / scene craft

**Scope:** Layered ground, water, building depth & facing, NPC loops, Square Enix’s stated HD-2D construction, and pixel+3D hybrid implications for draw order.  
**Goal for Dream:** Steal *readable* town craft for a **2D Godot village** without building full HD-2D / Unreal.  
**Related Dream docs:** `docs/SEAMLESS.md`, `docs/LAYOUT.md`, `docs/SCALE.md`.

---

## Techniques

### What Square Enix / Acquire say HD-2D *is*

- **Definition (branded):** Pixel / billboard **2D characters** inside **fully 3D environments**, plus modern post (dynamic lights, DOF, tilt-shift, bloom, volumetric fog/particles, parallax) so the scene reads as a **diorama / miniature**, not a flat SNES map. Square Enix coined and trademarked “HD-2D” around *Octopath Traveler* ([Wikipedia: HD-2D](https://en.wikipedia.org/wiki/HD-2D); [GamesIndustry.biz on trademark](https://www.gamesindustry.biz/square-enix-trademarks-terms-for-octopath-travelers-visual-style)).
- **Intent:** Not “thicker pixels.” Producer framing: pure pixel nostalgia looks *worse* than modern progress; fuse **kept pixel aesthetic** with a **3D environment** so it feels priced and contemporary ([Nintendo Everything translation of Nintendo Dream / Asano–Morimoto](https://nintendoeverything.com/octopath-traveler-devs-on-character-origins-visual-style-initial-hd-rumble-plans-much-more/); [Unreal Engine spotlight](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)).
- **Reference lineage:** PS1-era **2D characters on 3D / pre-rendered backgrounds**; modernize that hybrid in UE4 ([UE spotlight — Iizuka](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)).
- **“Accurate” HD-2D (Asano, *Triangle Strategy*):** Build **deformed / pixel intent first**, *then* stack realistic lighting and effects. Do **not** take a photoreal image and crush it down — that reads as “cheap lowered quality,” not crafted pixel diorama ([Nintendo Everything / 4Gamer translation](https://nintendoeverything.com/triangle-strategy-devs-on-how-the-game-uses-accurate-hd-2d/)).

### Layered ground / world planes

- Field travel uses a **fixed camera**; composition keeps destinations readable “on a single screen” (*OT II* Acquire: keep places the player wants to visit readable without free-look while walking) ([UE *OT II* interview](https://www.unrealengine.com/en-US/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style)).
- Depth is exaggerated with **shallow DOF / bokeh** and a **tilt-shift** feel: midground sharp, fore/back soft — miniature scale illusion ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console); [Wikipedia characteristics](https://en.wikipedia.org/wiki/HD-2D)).
- Early prototypes were flat pixel maps with **insufficient depth** → boring; overdoing resolution/saturation **killed** pixel charm. Depth amount was so contentious they shipped **DOF as a player option** ([Famitsu via Nintendo Everything](https://nintendoeverything.com/project-octopath-traveler-devs-on-the-games-origins-demo-feedback-and-improvements-more/); [Siliconera Famitsu summary](https://www.siliconera.com/project-octopath-traveler-developers-answer-project-started-troubles-developing-hd-2d/)).
- **Ground richness:** Sprites looked lonely on large screens → raise **tile / color density** (e.g. more roof color variation) so the field is “rich” without abandoning pixel language ([Siliconera](https://www.siliconera.com/project-octopath-traveler-developers-answer-project-started-troubles-developing-hd-2d/); [Nintendo Everything](https://nintendoeverything.com/project-octopath-traveler-devs-on-the-games-origins-demo-feedback-and-improvements-more/)).
- **Practical structure (observed / technical):** Towns are **polygonal** stacks (floors, steps, walls, roofs) with **low-res pixel textures** that behave like **tiled material swatches**, not unique photoreal maps ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)). Community teardown notes **mesh edges aligned to texture pixel edges** so texels don’t smear ([r/VoxelGameDev discussion](https://www.reddit.com/r/VoxelGameDev/comments/jvxcil/octopath_traveler_design_question/)).

### Water shaders / planes

- Team explicitly debated **pixel water vs photoreal water** while balancing HD-2D ([Famitsu via NE / Siliconera](https://nintendoeverything.com/project-octopath-traveler-devs-on-the-games-origins-demo-feedback-and-improvements-more/)).
- Early builds had **ocean/water as pure pixel art**; leadership rejected that as “not modernized” — push toward modern surface treatment while keeping the overall pixel diorama ([Apartment 507 / JP interview summary](https://www.apartment507.com/blogs/japan-gaming/untold-stories-of-octopath-traveler-development-surpassing-the-deified-pixel-art)).
- Shipped look: **animated water shader** with **reflections of nearby light**, not a static tile strip ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)). Atmosphere also uses mist, shafts, **cloud shadow blankets** rolling over terrain ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
- **Stealable hybrid formula (not proprietary SE code):** world-space water plane + normal ripples + specular + optional reflection buffer + **depth/shore mask** for foam (common 2D/2.5D water craft; see e.g. [Andy Korth — 2D water reflections](https://kortham.net/posts/2d-water-reflections/)). In Dream terms: keep the **meandering mask + bank damp tiles** (`LAYOUT.md` / `SEAMLESS.md`) and layer a **shader plane** for motion/highlight, not a second tiled “canal.”

### Building depth & facing in towns

- Buildings are **3D volumes** with **pixelated wrapping textures** so they cast/receive light correctly under UE lighting ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
- **Camera contract:** *Octopath* field = **fixed camera** → art is authored for **one privileged viewing angle** (high three-quarter). *Triangle Strategy* needed **360° map rotation**, which forced far more facade work on every side ([Asano / Arai](https://nintendoeverything.com/triangle-strategy-devs-on-how-the-game-uses-accurate-hd-2d/)). Implication: for a fixed-camera village, **invest facing toward the play camera / plaza**, not isotropic buildings.
- Specular / material “richness” is concentrated on surfaces that flatter sprites (stone, ice, wet ground) without replacing sprites with 3D characters ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
- Flags use **cloth sim** under **low-res pixel textures** — modern motion, retro material language ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
- *OT II:* map resolution / organic pixel feel increased; day/night lighting applied carefully so 2D characters still sit in the 3D set; camera can swing hard in **battle/events**, but **travel stays fixed** ([UE *OT II*](https://www.unrealengine.com/en-US/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style)).

### Characters as “physical” objects (shadows / grounding)

- Sprites are flat; early VFX alone felt weak. Solution: add **point lights with VFX** so light **casts character shadows onto the environment** ([UE spotlight — Iizuka / Watanabe](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)).
- DF notes sprites are given a **physical presence** in 3D space for **perspective-correct shadows**, not only a blob underfoot ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)). Indie HD-2D recreations often use **invisible shadow proxies** (boxes/capsules) behind billboards ([DEV Community HD-2D DX12 notes](https://dev.to/gaurav_de/creating-an-hd-2d-rendering-pipeline-on-dx12-205k)).

### NPC patrol / town life loops

- *OT II:* **day/night** changes **NPC movement patterns** in towns and which Path Actions work; designers explicitly wanted the same town to feel different by time of day ([UE *OT II*](https://www.unrealengine.com/en-US/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style); [Vooks interview — Miyauchi](https://www.vooks.net/rapid-fire-interview-chatting-with-the-developers-of-octopath-traveler-2/)).
- Public SE sources emphasize **schedule-driven town behavior**, not open-world sim AI. Stealable pattern: **waypoint loops + dwell times + day/night schedule tables** (readable rhythms), analogous to classic patrol design ([common patrol pattern overview](https://www.abratabia.com/game-ai-npc/enemy-ai-patterns.php)) and stereotyped daily scripts at scale ([Game AI Pro 3 — “1000 NPCs at 60 FPS”](http://www.gameaipro.com/GameAIPro3/GameAIPro3_Chapter34_1000_NPCs_at_60_FPS.pdf)).

### Draw order / pixel+3D hybrid implications

| Layer | Octopath-like role | Why it matters |
|---|---|---|
| Opaque 3D ground / buildings | Writes depth; receives shadows/lights | Establishes “stage” |
| Translucent water / glass | Separate transparency pass / sorting | Classic deferred pain; often forward or special buffer ([DX12 HD-2D writeup](https://dev.to/gaurav_de/creating-an-hd-2d-rendering-pipeline-on-dx12-205k)) |
| Billboard sprites | Alpha-tested or soft alpha; billboarded to camera | Must **depth-test** against ground/walls so feet tuck into steps |
| Particles / bloom / DOF | Post | Softens seams; can hide sorting errors; can also **hurt readability** (hence OT options) |

**Core implication:** In true HD-2D, “draw order” is mostly **world-space depth** (GPU Z), not SNES painter order. Hybrid failure modes:

1. Sprite floats → missing contact shadow / wrong billboard pivot / no depth write.
2. Sprite clips through roof → wrong Y or sorting layer when faking 3D in 2D.
3. Pixel textures blur → sampler not nearest / geometry not texel-snapped.
4. Water overwrites banks → transparency sorted wrong relative to shore sprites.

For **pure 2D Godot**, approximate the *same mental model*: **Y-sort / z-index from world depth**, separate **ground → water → props → actors → canopy**, and never rely on a single flat TileMap z for everything.

---

## Math / procedural

### Camera & miniature (conceptual)

- Fixed high-angle camera + **narrow focus band** (DOF) → tilt-shift miniature. Readability lever: reduce DOF strength (as OT did via options) when navigation suffers ([Famitsu / NE](https://nintendoeverything.com/project-octopath-traveler-devs-on-the-games-origins-demo-feedback-and-improvements-more/)).
- *OT II* battle/event cameras may rotate ~90–180°, but **exploration stays fixed** — author art for the travel camera first ([UE *OT II*](https://www.unrealengine.com/en-US/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style)).

### Depth sort for billboards (2D approximation)

Given actor foot position \((x, y)\) in top-down / high-angle 2D:

\[
z_{\text{sort}} = y_{\text{foot}} + \text{layerBias}
\]

Use **foot / contact point**, not sprite center. Multi-tile buildings: sort key = **south edge** of footprint (matches Dream’s south-facing cottage rule in `LAYOUT.md`).

### Water shore foam (procedural mask)

If \(d\) is distance-to-bank or water-depth field:

\[
\text{foam} = \mathrm{smoothstep}(t_0, t_1, d) \cdot \mathrm{wave}(uv, t)
\]

Animate \(\mathrm{wave}\) slowly; keep foam **narrow** so banks stay readable (Dream: damp bank tiles already carry ecological signal).

### Patrol loop

Waypoints \(p_0 \ldots p_{n-1}\), dwell \(w_i\), optional day-part filter \(D \in \{\text{day},\text{night}\}\):

1. Move toward \(p_i\) (grid or nav).
2. Wait \(w_i\) (idle / face dir).
3. \(i \leftarrow (i+1) \bmod n\), or swap schedule when clock crosses day↔night.

Keep loops **readable** (player can learn rhythms); randomize dwell ±20% only if needed.

### Ground variation (density without seams)

OT’s “raise density of tiles/colors” ≈ Dream’s ecological fill: distance-to-path / edge / water → `mowed|meadow|tall|weed|damp` (`SEAMLESS.md`). Procedural rule: **variation frequency ↑ near plazas and roofs’ visual mass**, not uniform noise.

---

## Asset pipeline

1. **Pixel-first authoring:** Characters and key props as crisp pixel; environments as **low-res texel language** on geometry (or on layered 2D “fake extrusions”). “Accurate HD-2D” = deform/pixel *before* polish ([Asano](https://nintendoeverything.com/triangle-strategy-devs-on-how-the-game-uses-accurate-hd-2d/)).
2. **Texel snapping:** Align UVs / mesh edges (or 2D wall strips) to **integer texels**; sample **Nearest** (Dream `SCALE.md` / `TileSetFactory` already push Nearest + integer zoom).
3. **Tiled material illusion:** Reuse small pixel tiles across large surfaces so the town feels “16-bit budget” even when geometry is free ([Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
4. **Roof / facade color density:** Extra hues on roofs and trims so sprites don’t look lonely on empty green ([Siliconera](https://www.siliconera.com/project-octopath-traveler-developers-answer-project-started-troubles-developing-hd-2d/)).
5. **Water as hybrid asset:** Mask + bank tiles (pixel) + **shader surface** (modern). Avoid all-pixel water if you want “modernized” read ([Apartment 507](https://www.apartment507.com/blogs/japan-gaming/untold-stories-of-octopath-traveler-development-surpassing-the-deified-pixel-art)).
6. **Lighting as content:** Point lights, window shafts, torch bounce — treated as gameplay/atmosphere, not afterthought ([UE spotlight](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true); [Digital Foundry](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)).
7. **Engine leverage:** Acquire leaned on UE4 tools with a **small programmer count** (~6 at peak) so artists could iterate lighting/VFX ([UE spotlight](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)). Godot analogue: CanvasItem materials, Light2D, few shared shaders, assembler scripts for town fill.
8. **Cost warning:** Asano later noted HD-2D is **more expensive than people think** to copy fully ([Wccftech / Asano on cost](https://www.wccftech.com/hd-2d-is-more-expensive-than-people-think-triangle-strategy-producer-says/)). Steal selective layers.

**Pipeline diagram (mental):**

```text
Pixel sprites (billboards)
        +
3D (or extruded 2D) sets with pixel textures  →  lights/shadows  →  DOF/fog/particles
        +
Water plane shader + shore mask
```

---

## Agent rules

Rules for future agents working on Dream’s village (steal OT craft **without** claiming full HD-2D):

1. **Do not** chase full UE diorama (volumetric fog, cinematic DOF, cloth flags, PBR everywhere) as a prerequisite for a good village.
2. **Do** author for a **fixed privileged camera** — facades and doors face plaza / play view (`LAYOUT.md` south-facing rule is the 2D equivalent of OT’s fixed travel camera).
3. **Do** increase **ground + roof color density**; **do not** leave one monotone grass pad (OT loneliness problem; Dream `SEAMLESS.md`).
4. **Do** treat water as **mask + bank ecology + optional shader plane**; **do not** straight-rect canals or all-static pixel sheets if motion/highlight is needed.
5. **Do** sort actors by **foot Y / south footprint**; **do not** sort by sprite center or a single global z.
6. **Do** ground characters with **contact shadow or Light2D**; floating sprites break the hybrid read.
7. **Do** NPC **waypoint loops + day/night schedule**; **do not** fake “alive town” with only idle standees.
8. **Do** keep Nearest filtering and integer-ish presentation; **do not** upscale-blur pixel textures into soft mush.
9. **Do** add modern effects only after the **pixel/deformed base** reads correctly (“accurate HD-2D”).
10. **Do not** rotate random building art without matching door facing; OT teaches that camera-facing contract is expensive to break (*Triangle Strategy* 360° cost).
11. **Forbidden lazy shortcuts:** one TileMap layer for ground+water+props; photoreal water texture dumped on a quad; DOF so strong paths are unreadable; NPCs without loops; buildings south of plaza with backs to the square.

---

## Sources

### Primary / first-party & close translations

1. [Unreal Engine — Octopath Traveler HD-2D spotlight (Acquire / SE quotes)](https://www.unrealengine.com/en-US/spotlights/octopath-traveler-s-hd-2d-art-style-and-story-make-for-a-jrpg-dream-come-true)  
2. [Unreal Engine — *Octopath Traveler II* developer interview](https://www.unrealengine.com/en-US/developer-interviews/octopath-traveler-ii-builds-a-bigger-bolder-world-in-its-stunning-hd-2d-style)  
3. [Unreal Fest Europe 2019 — “Fusion of Nostalgia and Novelty…” (slides event page)](https://www.unrealengine.com/events/unreal-fest-europe-2019/the-fusion-of-nostalgia-and-novelty-in-the-development-of-octopath-traveler)  
4. [Nintendo Everything — Famitsu *Project Octopath Traveler* interview translation](https://nintendoeverything.com/project-octopath-traveler-devs-on-the-games-origins-demo-feedback-and-improvements-more/)  
5. [Nintendo Everything — Nintendo Dream / Asano–Morimoto visual-style translation](https://nintendoeverything.com/octopath-traveler-devs-on-character-origins-visual-style-initial-hd-rumble-plans-much-more/)  
6. [Nintendo Everything — *Triangle Strategy* “accurate HD-2D” (4Gamer) translation](https://nintendoeverything.com/triangle-strategy-devs-on-how-the-game-uses-accurate-hd-2d/)  
7. [Vooks — *OT II* Miyauchi / Takahashi rapid-fire (day/night NPC patterns)](https://www.vooks.net/rapid-fire-interview-chatting-with-the-developers-of-octopath-traveler-2/)  

### High-trust technical / secondary

8. [Digital Foundry — hybrid UE4 analysis (towns, water, shadows, DOF)](https://www.digitalfoundry.net/articles/digitalfoundry-2018-octopath-traveler-a-hybrid-game-for-a-hybrid-console)  
9. [Siliconera — Famitsu HD-2D balance / water pixel-vs-photoreal summary](https://www.siliconera.com/project-octopath-traveler-developers-answer-project-started-troubles-developing-hd-2d/)  
10. [Wikipedia — HD-2D (definition, characteristics, citations)](https://en.wikipedia.org/wiki/HD-2D)  
11. [Apartment 507 — JP interview summary (early pixel water rejected)](https://www.apartment507.com/blogs/japan-gaming/untold-stories-of-octopath-traveler-development-surpassing-the-deified-pixel-art)  
12. [Wccftech — Asano on HD-2D cost](https://www.wccftech.com/hd-2d-is-more-expensive-than-people-think-triangle-strategy-producer-says/)  

### Implementation analogues (not SE source of truth)

13. [Andy Korth — 2D water reflections / depth foam](https://kortham.net/posts/2d-water-reflections/)  
14. [DEV Community — recreating HD-2D pipeline (shadow proxies, translucency)](https://dev.to/gaurav_de/creating-an-hd-2d-rendering-pipeline-on-dx12-205k)  
15. [Game AI Pro 3 Ch.34 — stereotyped NPC daily scripts](http://www.gameaipro.com/GameAIPro3/GameAIPro3_Chapter34_1000_NPCs_at_60_FPS.pdf)  

---

## Eight takeaways for a 2D Godot village (steal without full HD-2D)

1. **Fixed-camera contract** — Author buildings/doors for one view (plaza-facing); don’t pay for 360° facades.  
2. **Density over resolution** — More grass/roof/trim variants beat one hi-res plate (OT’s “sprites look lonely” fix).  
3. **Pixel base → then polish** — Nearest pixels + ecology first; lights/shaders second (“accurate HD-2D”).  
4. **Hybrid water** — Meandering mask + damp banks + subtle shader ripples/specular; skip photoreal oceans.  
5. **Depth-as-sort** — Y-sort from feet / building south edge; layered ground → water → props → NPCs → canopy.  
6. **Ground the sprites** — Contact shadow or Light2D so actors don’t float on rich ground.  
7. **Schedule loops** — Waypoint patrols with day/night variants; idle standees don’t sell a living town.  
8. **Readable atmosphere** — Soft vignette / light shafts / mild blur OK; keep path readability (OT shipped DOF options for a reason).
