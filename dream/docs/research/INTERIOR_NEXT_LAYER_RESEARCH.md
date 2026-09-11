# Research: Next polish layer after interior furniture clustering

**Date:** 2026-09-11  
**Scope:** Top-down / 3⁄4 pixel RPG village interiors (Godot 4), **after** Wave A functional clustering (`INTERIOR_COMPOSITION.md`).  
**Question:** What is the next practical polish pass — wall trim, depth sorting, interaction prompts, lighting, door frames, silhouette readability — plus asset-name pitfalls and a pre–Wave B QA checklist.  
**Method:** Primary / high-trust sources (engine docs, official RPG Maker blog, Stardew official modding wiki, established pixel educators, GDC Vault abstracts). Secondary blogs used only when they restate those principles with concrete examples.

---

## Executive takeaway

After furniture is clustered by function, professionals do **not** jump to new systems. They lock **shell readability** (consistent wall height / trim / door frame layers), **depth contract** (Y-sort origin at feet + Front/AlwaysFront equivalents), **diegetic light** (few warm point lights vs flat CanvasModulate), **affordance cues** (proximity prompts + exit silhouette), and **asset identity QA** (filename ↔ pixels). That stack is the practical Wave B gate.

---

## 1. Next layer after placement

### 1.1 Wall trim / baseboard / wall-top contrast

| Claim | Source |
| --- | --- |
| Keep **one consistent wall height** across all rooms; mismatched 2-tile vs 3-tile walls is the most common interior mapping error. | [RPG Maker official — Tutorial: Mapping: Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) (Avery, 2020) |
| Pick **one interior wall style** (autotile look) and keep it for every room in the game. | Same |
| Wall **tops are brighter than side faces**; side bricks/shorter faces sell vertical depth; corner **columns** beat bespoke corner variants. | [SLYNYRD Pixelblog 45 — Bricks, Walls, Doors](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more) |
| Interior “wall frame” tiles are a first-class tileset deliverable before furniture variety. | [SLYNYRD Pixelblog 35 — Top Down Interiors](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) |
| Uniform lighting from one corner + small ledges that catch light create most of the perceived depth. | [SLYNYRD Pixelblog 3 — Graphical Projection](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1) |
| Outlines should be the **darkest** color in a sprite; avoid pure black/white; limited per-sprite palette (≈6–8). | [Sundrop Stardew-style Art Guide (PDF)](https://sundrop.kvdk.net/files/SundropArtGuide.pdf) |

**Practical polish order:** wall height lock → wall-top vs wall-face value split → 1px baseboard / ledge highlight → variants (cracked / discolored) → short contact shadows (≤1 tile).

### 1.2 Depth sorting (engine + map layers)

| Claim | Source |
| --- | --- |
| Enable `y_sort_enabled` on a shared parent; children with **higher Y draw in front**; nodes only sort vs peers on the **same `z_index`**. Nested Y-sort: child with Y-sort off still participates, but *its* children share that child’s Y. | [Godot 4 docs — CanvasItem.y_sort_enabled](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) |
| Align node `position` with **feet / ground contact**, not sprite center (offset sprite downward). | [KidsCanCode — Using Y-Sort (Godot 4)](https://kidscancode.org/godot_recipes/4.x/2d/using_ysort/index.html) |
| TileMapLayer: set **Y Sort Origin** per tile when Y-sort is on; quadrant batching changes under Y-sort. | [Godot docs — Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) |
| Stardew layer grammar: `Back` walkable floor → `Buildings` blocking → `Front` height-sorted vs player → `AlwaysFront` always on top (door tops / eaves). | [Stardew Valley Wiki — Modding:Maps](https://stardewvalleywiki.com/Modding:Maps) |
| Interior doors: bottom tile on `Buildings`, upper tiles on `Front`; wrong layer = broken door + wrong draw order. | [Stardew Modding Wiki — Kailey’s Interior Door Guide](https://stardewmodding.wiki.gg/wiki/Tutorial:_Kailey%27s_Interior_Door_Guide) |

**Practical polish order:** one Y-sort root for actors+props → feet origins audited → tall props / wall toppers on AlwaysFront-equivalent `z_index` or child groups → never fix depth with per-frame `z_index` hacks.

### 1.3 Door frames & exits

| Claim | Source |
| --- | --- |
| Carpet / threshold must visually **meet the wall**; ceiling/top layer may cover part of the entrance carpet. | [RPG Maker — Mapping: Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) |
| Doors need paired **visual layers + Action + map property**; animation strip size/order is strict. | [Kailey’s Interior Door Guide](https://stardewmodding.wiki.gg/wiki/Tutorial:_Kailey%27s_Interior_Door_Guide); [Modding:Maps — Doors / Action Door](https://stardewvalleywiki.com/Modding:Maps) |
| Furniture must sit **in front of** walls, not on wall tiles (wardrobe-on-wall error). | [RPG Maker — Mapping: Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) |
| Prefer negative space / clear navigable floor over thick wall-top rings that flatten depth (Chrono Trigger–style clarity). | [Dan Kittaka — RPG Maker MZ interior clarity notes](https://dankittaka.com/posts/2025-02-22-RPG-Maker-MZ-Initial-Thoughts) |

**Practical polish order:** doorstep + pillars/door_frame as a kit → clear walk band into room → portal/exit readable at room scale (silhouette + label).

### 1.4 Lighting

| Claim | Source |
| --- | --- |
| Minimal 2D lighting stack: `CanvasModulate` (darken ambient) + `PointLight2D` / `DirectionalLight2D` + `LightOccluder2D` matching sprite outlines. | [Godot docs — 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html) |
| Point lights suit torches / fire / lamps; shadows need occluder polygons; cull masks control who casts/receives. | Same |
| Stardew-like coziness: **warm amber** interior sources (fire, lamp) vs **cooler** window light; floor light-to-dark gradient sells recession. | [Pixels & Bloom — Stardew-inspired interior light notes](https://pixelsandbloom.com/stardew-valley-inspired-pixel-art-pieces-you-can-recreate/) (secondary, but matches Sundrop/SLYNYRD light-from-corner practice) |
| Night lamps / sconces are deliberate design tools, not afterthoughts. | [Pixels & Bloom — Stardew interior design (vanilla)](https://pixelsandbloom.com/stardew-valley-interior-design-ideas-without-mods/) |
| Short drop shadows (≤1 tile) avoid layering conflicts; keep shadow direction consistent. | [SLYNYRD Pixelblog 45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more) |

**Practical polish order:** room `CanvasModulate` mood → 1–3 authored point lights at real sources (hearth, lamp, forge) → optional window cool rim → occluders only if shadows earn their cost.

### 1.5 Interaction prompts & affordances

| Claim | Source |
| --- | --- |
| Environmental storytelling uses props, texturing, **lighting**, and composition so players *pull* meaning — not dump UI. | [GDC Vault — What Happened Here? Environmental Storytelling](https://www.gdcvault.com/play/1012647/what-happened-here-environmental) (Smith / Worch) |
| Indexical traces (clues left in space) drive discovery without stopping play. | [GDC Vault — Environmental Storytelling: Indices…](https://www.gdcvault.com/play/1016815/Environmental-Storytelling-Indices-and-the) (Fernández-Vara) |
| Information layering: far = room purpose banner; mid = persistent station labels; near = “Press E” + highlight. | [InstantGames — Pixel Dungeon camp UX lessons](https://instantgames.top/blog/posts/pixel-dungeon-dev-log-building-roguelite-crawler-with-ai.html) (devlog; principle aligns with GDC “readable space”) |
| Contextual prompts should be **world-anchored** near the interactable; prefer fade-after-learn over permanent clutter; glyphs must follow rebinds. | [Game-design prompt reference (Steam Input / contextual vs legend)](https://github.com/saschb2b/skills/blob/main/skills/productivity/game-design/references/input-prompts.md) |
| Proximity → nearest interactable → show prompt above target → confirm input. | Common implementation pattern (e.g. museum/portfolio E-to-inspect flows); treat as UX convention, not engine law. |

**Practical polish order:** hotspot collision matches prop footprint → nearest-only prompt → verb string from InputMap → exit portal always labeled → cluster titles already in profiles become mid-distance labels if Wave B needs them.

### 1.6 Silhouette readability

| Claim | Source |
| --- | --- |
| Paint order: **silhouette → value → color → detail**; clarity beats intricacy at game scale. | Project research citing [GameMaker — How To Make Pixel Art For 2D Games](https://gamemaker.io/en/blog/make-pixel-art-2d-games); [artists-tile-pipeline.md](practitioners/artists-tile-pipeline.md) |
| Squint / black-white-gray floor tests: if sprite vanishes, fix outline contrast before detail. | [Sorceress — Map How to Make Pixel Art](https://sorceress.games/blog/map-how-to-make-pixel-art-browser-canvas) |
| Dark outlines define objects against backdrop (Stardew rules). | [Sundrop Art Guide](https://sundrop.kvdk.net/files/SundropArtGuide.pdf) |
| ConcernedApe: limitations force simple readable solutions; practice in-game, not zoomed isolation. | [Mental Nerd — ConcernedApe pixel art interview](https://mentalnerd.com/blog/getting-started-pixel-art-interview/) |

**Practical polish order:** screenshot each room at game zoom → desaturate / squint pass → fix props that camouflage into floor/wall → keep backgrounds quieter than interactables.

---

## 2. Asset pipeline pitfalls when prop filenames ≠ visuals

| Pitfall | Why it hurts interiors | Source / mechanism |
| --- | --- | --- |
| **String-path load by filename** (`load("…/anvil_00.png")`) while pixels depict something else | Assembler / profiles place wrong object; clustering “looks” correct in data but wrong in play. | Dream pattern in `InteriorCraft` / `InteriorProfiles`; general path API: [Godot — File paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html) |
| **Duplicate base names** across folders; atlas/`GetSprite(name)` returns first match | Wrong prop silently. | [Unity SpriteAtlas.GetSprite](https://docs.unity3d.com/ScriptReference/U2D.SpriteAtlas.GetSprite.html) — first match wins (engine-agnostic naming lesson) |
| **Rename/move outside editor without `.import` / `.uid`** | New UID; scenes resolve via path fallback with warnings; two files can swap identities. | [Godot blog — UID changes in 4.4](https://godotengine.org/article/uid-changes-coming-to-godot-4-4/); [ResourceUID](https://docs.godotengine.org/en/stable/classes/class_resourceuid.html) |
| **Not committing `.uid` files** | Clone machines regenerate UIDs; path fallback masks bugs until assets swap. | Same Godot 4.4 article |
| **Filename / main-object rename mismatch** (common in Unity; analogous Godot import drift) | Editor warnings; tooling assumes name == file stem. | [Unity community — main object name vs filename](https://discussions.unity.com/t/the-main-object-name-should-match-the-asset-filename-please-fix-to-avoid-errors/896865) |
| **Relying on path string as semantic ID** after art regen | AI/pipeline overwrites `bed_00.png` with dresser pixels but keeps name. | Industry failure mode; mitigate with visual QA + manifest hash / thumbnails |
| **Tileset slot / sheet size wrong** (RPG Maker B–E = 768×768) | Editor shows wrong crops; “filename ok, visual wrong.” | [RPG Maker MZ Asset Standards](https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html) |

**Mitigations (recommended):**

1. **Visual identity gate:** every `profiles` path must pass human or scripted thumbnail compare (expected label vs pixels).  
2. Prefer **UID references** for shipped scenes; keep readable `res://` only in authored profile dictionaries that are audited.  
3. Move assets **with** `.import` / `.uid`; duplicate inside Godot FileSystem.  
4. Unique names: `interior_prop_anvil_00` not bare `anvil`.  
5. Sidecar `manifest.json` (Dream already has interior `_source_atlases/cut/manifest.json` pattern) mapping logical id → path → expected role.

---

## 3. QA checklist — interior rooms before Wave B features

Use as a **ship gate** after clustering, before dialogue trees / crafting UIs / economy hooks.

### A. Shell & architecture

- [ ] Wall height consistent room-wide and vs other village interiors ([RPG Maker Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior)).  
- [ ] Wall-top brighter than wall-face; baseboard/trim continuous on corners ([SLYNYRD 45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).  
- [ ] Door kit present: doorstep + frame/pillars; entrance carpet/threshold meets wall.  
- [ ] No furniture sitting *on* wall tiles.  
- [ ] South door → north wall **≥2-tile** clear corridor (`INTERIOR_COMPOSITION.md`).  
- [ ] Exterior footprint roughly matches interior purpose/size ([RPG Maker Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior)).

### B. Depth & collision

- [ ] Shared Y-sort parent on; actors/props same relevant `z_index` band ([CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)).  
- [ ] Sort origin at feet for characters and tall furniture ([KidsCanCode Y-Sort](https://kidscancode.org/godot_recipes/4.x/2d/using_ysort/index.html)).  
- [ ] Door/window toppers behave as Front/AlwaysFront (player walks “under” tops).  
- [ ] Blocking collision matches visual mass (Stardew `Buildings` lesson — [Modding:Maps](https://stardewvalleywiki.com/Modding:Maps)).  
- [ ] Walk behind tall shelves/beds without z-fighting.

### C. Clusters & storytelling

- [ ] Each cluster = one activity; stools face anchors ([INTERIOR_COMPOSITION](../INTERIOR_COMPOSITION.md)).  
- [ ] NPC route visits ≥2 work points.  
- [ ] Room purpose readable without UI (GDC environmental storytelling).  
- [ ] Ambient critters tied to related clusters.

### D. Lighting & mood

- [ ] `CanvasModulate` set; not default full-white flat.  
- [ ] Lights only at diegetic sources; warm interiors / cooler windows if present ([Godot 2D lights](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html)).  
- [ ] No overlapping energy blowout (keep PointLight energy modest when many lights).  
- [ ] Contact shadows short and direction-consistent ([SLYNYRD 45](https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more)).

### E. Interaction & exit

- [ ] Hotspots overlap prop footprints; nearest prompt only.  
- [ ] Prompt text matches InputMap binding.  
- [ ] Return portal labeled and unobstructed.  
- [ ] Interactables readable after squint test (silhouette).  

### F. Asset identity

- [ ] Spot-check every profile path: filename role == pixels.  
- [ ] No missing `ResourceLoader.exists` silent skips for hero props.  
- [ ] `.import` / `.uid` present for moved files; no UID-fallback warning spam ([Godot UID article](https://godotengine.org/article/uid-changes-coming-to-godot-4-4/)).  
- [ ] Game-zoom screenshot archived per room for regression.

### G. Performance / hygiene (light)

- [ ] Lights count capped per room profile.  
- [ ] FX (mist, fire) not covering exit or prompts.  
- [ ] Filter = nearest; integer-ish camera scale.

---

## 4. Apply to Dream

Dream already implements the **assembler pass order** and several Wave-A pieces in `InteriorCraft`:

`floor → walls/door/window → rug → props → FX → ambient → lights → actor → portal`  
with `InteriorWorld.y_sort_enabled = true`, `doorstep` / `pillar` / optional `door_frame`, `CanvasModulate` + `PointLight2D`, and `InteractableHotspot`s (`interior_craft.gd`).

**Next polish pass (recommended sequence, not all at once):**

1. **Shell trim pass** — Ensure every profile’s walls share height; add continuous baseboard / wall-top value split on tile art; treat `door_frame` as required, not optional.  
2. **Y-sort origin audit** — Offset furniture/NPC sprites so position = feet; keep foundation on fixed low `z_index`, sortable props on Y-sort band.  
3. **Door front-layer split** — Upper door/window tiles on higher draw group so player can walk “into” the doorway correctly (Stardew Front pattern).  
4. **Diegetic light QA** — Verify each `lights[]` entry sits on hearth/lamp/forge cluster anchors; cool rim only at windows.  
5. **Prompt layer** — World-anchored “互动” cue on nearest hotspot; keep portal label; avoid permanent clutter.  
6. **Filename ↔ pixels gate** — Especially `interior/props` and outdoor props reused indoors (`barrel_*`, `crate_*`); block Wave B until visual ID audit passes.  
7. **Per-room screenshot checklist** — Run section 3 A–F on all Wave A profiles in `INTERIOR_COMPOSITION.md` before dialogue/crafting Wave B.

Related docs: [`INTERIOR_COMPOSITION.md`](../INTERIOR_COMPOSITION.md), [`INTERIOR_FOUNDATION.md`](../INTERIOR_FOUNDATION.md), [`practitioners/artists-tile-pipeline.md`](practitioners/artists-tile-pipeline.md).

---

## 5. 禁止偷懒（执行 agent 硬约束）

执行下一轮室内抛光时，**禁止**：

1. **禁止**只改 profile 坐标数字、不跑游戏缩放截图验收。  
2. **禁止**用随便抬高 `z_index` 冒充 Y-sort（同 `z_index` 才互相比 Y）。  
3. **禁止**跳过墙高/墙顶明暗/踢脚线，直接做新玩法 UI。  
4. **禁止**把门框/`door_frame` 当成“有就更好”的可选装饰——出口必须成套。  
5. **禁止**假定文件名正确：必须打开像素确认 `anvil`/`bed`/`counter` 等。  
6. **禁止**给全屋堆满 `PointLight2D` 却不绑到真实光源道具。  
7. **禁止**把所有交互说明塞进 TopBar 一行，却不在物体旁给接近提示。  
8. **禁止**把多个功能簇的 QA 合并成“抽查一间房算过”。  
9. **禁止**移动/覆盖 PNG 却丢掉 `.import` / `.uid`。  
10. **禁止**在通廊未清空、深度未修前开启 Wave B（对话树/制作/商店逻辑）。  
11. **禁止**只在编辑器 400% 缩放下判读轮廓——必须以游戏相机缩放做剪影测试。  
12. **禁止**用长阴影贴图横跨多格制造“假深度”导致层层冲突。

---

## 6. Source index (URLs)

| Topic | URL |
| --- | --- |
| Godot Y-sort property | https://docs.godotengine.org/en/stable/classes/class_canvasitem.html |
| Godot TileMaps Y Sort Origin | https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html |
| Godot 2D lights & shadows | https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html |
| Godot paths | https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html |
| Godot ResourceUID | https://docs.godotengine.org/en/stable/classes/class_resourceuid.html |
| Godot UID 4.4 article | https://godotengine.org/article/uid-changes-coming-to-godot-4-4/ |
| KidsCanCode Y-Sort | https://kidscancode.org/godot_recipes/4.x/2d/using_ysort/index.html |
| RPG Maker Interior mapping | https://www.rpgmakerweb.com/blog/tutorial-mapping-interior |
| RPG Maker MZ asset standards | https://rpgmakerofficial.com/product/MZ_help-en/01_11_01.html |
| Stardew Modding:Maps | https://stardewvalleywiki.com/Modding:Maps |
| Kailey interior doors | https://stardewmodding.wiki.gg/wiki/Tutorial:_Kailey%27s_Interior_Door_Guide |
| SLYNYRD PB35 interiors | https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors |
| SLYNYRD PB45 walls/doors | https://www.slynyrd.com/blog/2023/7/21/pixelblog-45-bricks-walls-doors-and-more |
| SLYNYRD PB3 projection/light | https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1 |
| Sundrop Stardew art guide | https://sundrop.kvdk.net/files/SundropArtGuide.pdf |
| ConcernedApe interview | https://mentalnerd.com/blog/getting-started-pixel-art-interview/ |
| GameMaker pixel art | https://gamemaker.io/en/blog/make-pixel-art-2d-games |
| GDC environmental storytelling | https://www.gdcvault.com/play/1012647/what-happened-here-environmental |
| GDC indices / traces | https://www.gdcvault.com/play/1016815/Environmental-Storytelling-Indices-and-the |
| Interior clarity (MZ / Chrono Trigger) | https://dankittaka.com/posts/2025-02-22-RPG-Maker-MZ-Initial-Thoughts |

---

*End of research note.*
