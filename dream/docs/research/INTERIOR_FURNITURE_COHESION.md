# Research: Interior furniture cohesion (matching family)

**Date:** 2026-09-11  
**Scope:** Professional pixel / 3⁄4 top-down RPG interiors — how tables, stools, chairs, and bars read as **one furniture family** (wood tone, outline weight, projection, scale, shadow).  
**Question:** What concrete matching rules do primary educators / official mapping guides lock, why mismatched-but-individually-good assets feel “wrong,” and how Dream should author dining / tea / bar sets.  
**Method:** Primary sources first (SLYNYRD Pixelblog, RPG Maker official blog, Sundrop Stardew-style guide, GameMaker / Godot art practice). Dream application grounded in current `interior/props` PNGs + normalize pipeline.  
**Related ops note:** [`../INTERIOR_FURNITURE_COHESION.md`](../INTERIOR_FURNITURE_COHESION.md) (active rebuild lock).

---

## Executive takeaway

Professionals do **not** ship one-off chairs/tables and hope they match. They author **furniture as a set on one tile-aligned sheet**, under **one projection + one light corner + one limited wood ramp**, then place by function. Uniformity of projection beats realism ([SLYNYRD PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)); man-made geometry makes projection mismatches *especially* obvious ([SLYNYRD PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects)); dining pieces are taught as a **first set** (table + stool + countertop together) ([SLYNYRD PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors)). Dream’s current stool / dining / round / bar mismatch is less “bad solo art” and more **different construction languages + AA density + height-normalize flattening**, which no palette swap alone can fix.

---

## 1. Concrete matching rules

### 1.1 Projection (3⁄4 lock)

| Rule | Why | Source |
| --- | --- | --- |
| Pick **one** graphical projection for the whole interior (Dream: **3⁄4 top-down**). Never mix true isometric cubes, bird’s-eye tops, and side-on walls in the same room kit. | “There are many different types of graphical projections but in most cases they should not be mixed in the same scene. So long as all elements in a scene follow the same set of rules the resulting uniformity will please the eyes.” | [SLYNYRD Pixelblog 3 — Graphical Projections](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1) |
| For 3⁄4 top-down: show ~¾ of top + front; keep roof/edge angles **clean** even if that breaks real foreshortening. | “When it comes to pixel art, **uniformity takes priority over realism**.” | Same |
| Man-made furniture must obey the same rules as tables/chests/fences. | “Due to the precise geometry of man made objects the consistency of the sense of perspective is especially apparent. Make sure all your objects adhere to the same projection rules.” | [SLYNYRD Pixelblog 21 — Top Down Objects](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects) |
| Know which top-down flavor you are in (bird’s-eye vs tilted 3⁄4). | GameMaker separates Hotline-style overhead vs Undertale-style tilt; each needs different drawing conventions. | [GameMaker — How To Make Pixel Art For 2D Games](https://gamemaker.io/en/blog/make-pixel-art-2d-games) |

**Dream lock:** oval seat / elliptical tabletops share the **same squash ratio**; rectangular tops share the **same visible apron height in px** and the same corner cut language. Pedestal “cabriole” bases vs four-post legs are **different families**, not variants.

### 1.2 Palette (wood ramp)

| Rule | Why | Source |
| --- | --- | --- |
| Cap colors per sprite (~**6–8**), reuse slots across parts. | Stardew-style sprites typically stay within six/eight colors; complex pieces still reuse shades. | [Sundrop Art Guide (PDF)](https://sundrop.kvdk.net/files/SundropArtGuide.pdf) |
| **No pure black / pure white**; outline is the **darkest** hue in the object. | Darkest outline defines silhouette; shading stays lighter than outline. | Sundrop Art Guide |
| Stay in one saturation neighborhood across the game / set. | Limited palette + consistent saturation = classic cohesion; Stardew cited as intentional limitation. | [GameMaker pixel-art guide](https://gamemaker.io/en/blog/make-pixel-art-2d-games) |
| Shared wood mid + highlight + shadow across the **family**, not merely “brown-ish.” | Recolor tutorials require same slot count and hue-shifted shadows (cool) / highlights (warm), not black/white mixes. | [Stardew Modding Wiki — Recoloring Sprites](https://stardewmodding.wiki.gg/wiki/Tutorial:_Recoloring_Sprites) |
| SLYNYRD interiors lock a series palette (Mondo) for tiles **and** furniture. | PB35 interiors continue PB20–22 with the same Mondo palette. | [SLYNYRD Pixelblog 35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) |

**Practical wood ramp (family sheet):**  
`outline (darkest hue) → deep AO → mid wood → lit wood → rim highlight` (+ optional 1 metal accent ramp for bar brass **only** on the tavern family).

### 1.3 Light direction

| Rule | Why | Source |
| --- | --- | --- |
| One light corner for the object set (SLYNYRD default: a **top corner**). | Depth comes from lighting slabs where angles meet, not from accurate perspective math. | [SLYNYRD PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1) |
| Small ledges / aprons catch light; contrast at sharp angle joins sells 3D. | “Most of the depth comes from lighting. Small ledges and outcroppings that catch different light angles can improve depth.” | Same |
| Cast shadows short, soft, consistent side; prefer separate shadow tiles when overlap conflicts. | Long directional shadows fight adjacent tiles; keep ≤ ~1 tile. | [SLYNYRD PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects); [SLYNYRD PB45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more) |

**Dream lock:** top-left light for all cozy wood furniture. Right-lit or top-center-only pieces fail the family test even if midtone RGB matches.

### 1.4 Outline weight

| Rule | Why | Source |
| --- | --- | --- |
| Outline = darkest palette color; everything else lighter. | Separates object from floor/wall and from its own parts. | [Sundrop Art Guide](https://sundrop.kvdk.net/files/SundropArtGuide.pdf) |
| Keep line thickness consistent (usually **1 px**). | Saultoon pipeline cited by GameMaker: clean silhouette, consistent line thickness. | [GameMaker guide](https://gamemaker.io/en/blog/make-pixel-art-2d-games) |
| Prefer subtle darker-than-adjacent outlines over pure black slabs (when style allows). | Building workflow: outline after shadows with slightly darker neighbor color. | [SLYNYRD Pixelblog 51 — City Builder](https://www.slynyrd.com/blog/2024/7/25/pixelblog-51-city-builder) |

**Dream lock:** either all selective dark-brown outline **or** all hard outline — never mix soft AA blobs next to hard 1px ink on the same dining cluster.

### 1.5 Leg thickness & construction language

| Rule | Concrete check | Source / rationale |
| --- | --- | --- |
| Same **leg cross-section language** inside a family | Square post ↔ square post; round turned ↔ round turned; pedestal+cabriole is its own family | Man-made geometry reveals inconsistency ([PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects)) |
| Same **leg thickness in px** at display scale | Measure front-most leg width; ±1 px tolerance at 32-grid | Uniformity > realism ([PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)) |
| Same **joint grammar** | Stretchers yes/no for whole family; carved knees yes/no | Set authorship ([PB35 dining set](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors)) |
| Tile-friendly footprint | Design inside tile map so pieces mesh and slice cleanly | PB35: furniture “designed within a 16×16px tile map” (Dream scales to 32-grid) |

### 1.6 Seat height vs table apron

| Rule | Concrete check | Source / rationale |
| --- | --- | --- |
| Seat top sits **below** dining apron / tabletop plane | Side-by-side mock: stool seat ≤ table apron top by several px | Real-world ergonomics + readable silhouette at game zoom |
| Bar stool may sit higher, but still shares wood ramp + outline | Do not use dining stool next to bar counter without height variant | Functional clustering ([RPG Maker Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) purpose of space) |
| Do **not** normalize every prop to the same absolute canvas height if that destroys relative proportions | Height lock must be **relative within family**, not “every PNG = 64px tall” | Dream pipeline pitfall (see §4) |
| Chairs/tables edited from the **same RTP / sheet** keep proportions when resized | Avery cuts tables/chairs from existing pieces rather than inventing new proportions | [RPG Maker — Tile edits](https://www.rpgmakerweb.com/blog/tile-sets-so-simple-anyone-can-do-them) |

### 1.7 Scale & sheet modularity

| Rule | Source |
| --- | --- |
| Objects sized to the tile module; common props fit one tile; rare larger props allowed if sparse. | [SLYNYRD PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects) |
| Draw at intended display size; doubling tile edge **quadruples** paint cost. | [GameMaker guide](https://gamemaker.io/en/blog/make-pixel-art-2d-games) |
| Stardew stores furniture on a shared tilesheet with typed sizes (`chair` / `table` / `long table`) — engine treats them as one furniture system. | [Stardew Wiki — Modding:Furniture](https://stardewvalleywiki.com/Modding:Furniture) |
| RPG Maker interiors: one wall style for the whole game; furniture sits **in front of** walls, not on wall tiles. | [RPG Maker — Mapping: Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) |

---

## 2. Why mismatched sets look “wrong” even if each asset is good alone

Vision and mapping practice agree: the room is judged as a **system**, not a gallery of heroes.

1. **Projection conflict** — Uniformity is the charm of graphical projection; mixing viewpoints breaks the “believable abstraction” contract ([PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)). Furniture is the worst offender because straight edges make tilt errors measurable ([PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects)).

2. **Palette / outline conflict** — Limited per-sprite palettes and darkest-outline rules train the eye to expect one ink weight and one hue family ([Sundrop](https://sundrop.kvdk.net/files/SundropArtGuide.pdf)). A soft, multi-hundred-color AI stool next to a hard 8-color table reads as two engines.

3. **Light corner conflict** — Depth is sold by consistent corner light + ledge catch ([PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1)). Opposite highlights make props look lit by different rooms.

4. **Construction-language conflict** — Four-post farm table + cabriole tea table + brass-rail bar are three workshops. Even perfect midtone RGB cannot reconcile “ornate parlor” with “rustic stool.”

5. **Proportion / ergonomics conflict** — Seat above apron, or stool and table both spanning the full sprite height, breaks the “could someone sit here?” read that cozy interiors exploit ([PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) cozy thesis).

6. **Mapping-purpose conflict** — Official RPG Maker guidance: houses have jobs; counter separates public/private; random bed-next-to-counter feels wrong even with good tiles ([Interior mapping](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior)). Style mismatch is the graphic twin of that purpose mismatch.

7. **Shadow / contact conflict** — Objects that do not share short grounded shadows fail to “touch” the same floor ([PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects); [PB45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).

**Bottom line:** solo quality is necessary but not sufficient. Cohesion is a **shared constraint set**; violating any one axis (projection, ink, light, construction, height) is enough for players to feel collage.

---

## 3. Recommended workflow: author as a set sheet, not one-offs

Professionals and official editors converge on **sheet-first**:

| Step | Practice | Source |
| --- | --- | --- |
| 1. Lock series rules | Projection, light corner, palette name, tile module | PB3 + PB20/21 chain; GameMaker perspectives |
| 2. Build shell before clutter | Wall frames / floor first, then decorate | [PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors); [RPG Maker Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) |
| 3. Paint **dining set** as one block | Table + stool + countertop (+ stove) on one sheet | PB35 explicitly groups the first furniture set this way |
| 4. Paint **living/bed set** as second block | Same palette / projection, different silhouettes | PB35 second furniture set |
| 5. Keep pieces tile-map aligned | Even if exported as loose sprites, author on grid | PB35 / PB21 |
| 6. Derive variants by **edit**, not new seeds | Avery: new 768×768 sheet; copy RTP furniture; resize table / turn chair / mirror counter from the same wood | [RPG Maker tile edits](https://www.rpgmakerweb.com/blog/tile-sets-so-simple-anyone-can-do-them) |
| 7. Engine treats furniture as typed family | Shared tilesheet + type (`chair` / `table` / …) | [Stardew Modding:Furniture](https://stardewvalleywiki.com/Modding:Furniture) |
| 8. QA at game zoom on real floor | Silhouette → value → color → detail; integer scale | Dream [`painting-asset-craft`](../../.cursor/skills/painting-asset-craft/SKILL.md); GameMaker silhouette pipeline |

**Anti-pattern:** generate `gen_stool.png`, `gen_table.png`, `gen_bar.png` in separate prompts / sessions → rembg → independently normalize to 64h → hope filenames glue them. That is how Dream got collage interiors.

**Pro pattern:** one prompt / one Aseprite file `interior_furniture_family_cozy.png` containing long table, round table, short stool, optional bar stool, optional counter segment — **shared wood ramp baked in** — then slice.

---

## 4. Apply to Dream (stool vs dining vs round vs bar)

### 4.1 Measured snapshot (2026-09-11)

All listed props currently ship at **normalized height 64 px** (`install_interior_gap_props.py` `TARGET_H = 64`). Bucketed midtone wood (~16-step) is closer than the eye expects; **construction and AA** carry the mismatch:

| Prop | Size (approx) | Mid wood (bucket avg) | Construction language | Notes |
| --- | --- | --- | --- | --- |
| `stool_00` | ~50–54×64 | ~(114, 72, 35) warm | Round seat, **4 chunky legs + stretchers** | High unique-color count (AA / soft edges) |
| `table_dining_00` | ~78–87×64 | ~(113, 70, 32) warm | Rect top, **square corner posts**, apron | Closest midtone sibling to stool |
| `table_round_00` | ~62–70×64 | ~(118, 72, 32) warm | Ellipse top, **pedestal + ornate / curved legs** | Different workshop than four-post dining |
| `bar_00` | ~141×64 | ~(117, 57, 23) hotter / darker body | Paneled front, **brass footrail**, taps | Semantic + material jump (metal accent tier) |
| `counter_00` | ~148×64 | ~(99, 59, 29) cooler / darker | Long counter, brass rail, bell | Shop cousin of bar; still denser than dining set |

### 4.2 Failure modes mapped to §1 rules

| Axis | Dream failure |
| --- | --- |
| Projection / construction | Round table pedestal language ≠ dining four-post ≠ stool stretcher frame |
| Outline / AA | Soft multi-tone AI edges vs harder farm silhouettes in one cluster |
| Light | Mostly top-left OK; bar/counter highlights + brass speculars raise “other game” feel |
| Seat vs apron | **All forced to 64h** → seat and tabletop both claim full canvas; relative ergonomics destroyed |
| Family authorship | Gap props installed one-off (`gen_table_dining_bare`, etc.); stool/round often from older atlas / remap paths |
| Purpose | Brass tavern bar next to rustic dining stool without a dedicated `stool_bar` height twin |

### 4.3 Recommended Dream families (ship)

Align with ops lock in [`../INTERIOR_FURNITURE_COHESION.md`](../INTERIOR_FURNITURE_COHESION.md):

| Family | Members | Share | Profiles |
| --- | --- | --- | --- |
| `cozy_dining` | `table_dining_00` + `stool_00` (×N) | Four-post / farm leg language, warm oak ramp, top-left light | hearth / farmer dining / smith wait |
| `cozy_tea` | `table_round_00` + same `stool_00` **only if** round table is rebuilt to four-post or stool rebuilt to match pedestal set | Prefer: redraw round table into dining language **or** ship a tiny tea-stool twin on the same sheet | elder tea / small party tables |
| `tavern_bar` | `bar_00` / `counter_00` + `stool_bar_00` | Shared brass accent ramp; taller seat; same ink weight | c04 tavern |

### 4.4 Pipeline fix (must)

1. Author **one family sheet** (not separate gens).  
2. Slice with **relative height preserved** (stool shorter than table apron in source pixels).  
3. Normalize by **family max** or by documented seat/table ratios — **do not** blindly scale every island to 64h.  
4. Index palette to ≤8 wood slots (+ brass ramp only on bar family).  
5. Visual QA: composite stool beside both tables and bar on interior floor at game zoom; fail on construction or height, not only hex.

---

## 5. 禁止偷懒

1. **禁止**分次单独生成桌 / 凳 / 吧台再“色相近就算成套”。  
2. **禁止**只做 Hue/Levels 全局调色假装同一工坊（腿型不同必须重画）。  
3. **禁止**把所有 props `normalize` 到同一绝对高度（64h）却不做座面 vs 桌沿相对比例。  
4. **禁止**圆桌保持雕花曲腿 / 中柱，却硬配农家四腿凳。  
5. **禁止**吧台黄铜高细节直接配矮木凳而不做 `stool_bar` 高度变体。  
6. **禁止**混用真等距、纯俯视、3⁄4 侧视家具进同一室内。  
7. **禁止**一件硬 1px 描边、一件软抗锯齿雾边同桌出现。  
8. **禁止**光向相反（左上 vs 右上）的成套件进同一房间。  
9. **禁止**饭桌自带椅子合成块再额外摆独立凳（双椅子）。  
10. **禁止**只改文件名 / profile 路径，不换运行时 PNG。  
11. **禁止**调研写完不更新 [`../INTERIOR_FURNITURE_COHESION.md`](../INTERIOR_FURNITURE_COHESION.md) 执行清单与 QA 截图。  
12. **禁止**只在 400% 编辑器缩放下过审——必须以游戏相机整数缩放并排验收。

---

## 6. Source index (URLs)

| Topic | URL |
| --- | --- |
| SLYNYRD PB3 — projections & light | https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1 |
| SLYNYRD PB21 — top-down objects, shadows, man-made consistency | https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects |
| SLYNYRD PB35 — top-down interiors, dining furniture **set** | https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors |
| SLYNYRD PB45 — short shadows, wall value | https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more |
| SLYNYRD PB51 — outline after shadow workflow | https://www.slynyrd.com/blog/2024/7/25/pixelblog-51-city-builder |
| RPG Maker official — Mapping: Interior | https://www.rpgmakerweb.com/blog/tutorial-mapping-interior |
| RPG Maker official — tile edits from one sheet | https://www.rpgmakerweb.com/blog/tile-sets-so-simple-anyone-can-do-them |
| Sundrop Stardew-style Art Guide (PDF) | https://sundrop.kvdk.net/files/SundropArtGuide.pdf |
| Stardew Modding:Furniture (shared tilesheet / types) | https://stardewvalleywiki.com/Modding:Furniture |
| Stardew Modding — Recoloring (ramps / hue shift) | https://stardewmodding.wiki.gg/wiki/Tutorial:_Recoloring_Sprites |
| GameMaker — pixel art for 2D games | https://gamemaker.io/en/blog/make-pixel-art-2d-games |
| Dream prior research citing same stack | [`INTERIOR_NEXT_LAYER_RESEARCH.md`](INTERIOR_NEXT_LAYER_RESEARCH.md), [`practitioners/sprite-painting-specs.md`](practitioners/sprite-painting-specs.md) |

---

*End of research note.*
