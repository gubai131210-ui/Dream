# Terraria — scene / terrain CRAFT research

**Scope:** 2D side-scrolling tile world (hybrid “side view that reads as a map”). Transferable craft for Godot tile villages — water edges, continuous ground, house validity, NPC presence, worldgen math, tile atlas framing.  
**Not in scope:** combat balance, boss design, multiplayer netcode.

---

## Techniques

### 1. Water physics, shoreline, waterfall

- **Partial fill + settle:** Liquids occupy part or all of a tile and flow between tiles. Moving liquid is “flowing” (can visually overfill a cell); idle liquid is “settled.” On world load the game runs an explicit **Settling liquids** pass so pools reach natural destinations ([Liquids](https://terraria.wiki.gg/wiki/Liquids)).
- **Flow rules (look):** Prefer down first; if blocked below, spread sideways into partial tiles. Too-thin spread **disappears** (minimum depth). Flow speed differs by liquid type (water/Shimmer fastest, honey slowest) — viscosity is both physics and visual language ([Liquids](https://terraria.wiki.gg/wiki/Liquids)).
- **Shoreline read:** Shore is not a special mesh — it is **volume meeting solid + half-blocks**. Partial liquid tiles against solid banks create the waterline. Bucket pickup samples a **3×3** neighborhood (needs ≥ ~0.39 tile of same liquid) ([Liquids](https://terraria.wiki.gg/wiki/Liquids)).
- **Waterfalls = visual only:** When a full liquid tile sits next to a **half-block** with open space beyond, the game draws a river/liquidfall. That fall **does not drain** the source, does not drown/burn/heal, and can be disabled on Low quality. Running fall (edge of a body) vs stationary vertical fall (body only on half-blocks) ([Liquidfalls](https://terraria.wiki.gg/wiki/Liquidfalls), [Liquids](https://terraria.wiki.gg/wiki/Liquids)).
- **Biome-tinted water + glow hacks:** Waterfall color follows **biome water tint**; crossing Gemspark/Rainbow Brick can recolor/glow the fall ([Liquidfalls](https://terraria.wiki.gg/wiki/Liquidfalls)).
- **Ceiling drip:** Purely decorative droplets (Magic Droppers / natural) — another “water reads wet” cue without simulation cost ([Liquids](https://terraria.wiki.gg/wiki/Liquids)).
- **Implementation hint (community):** Liquid is byte volume on tiles + a queue/cellular update (not a separate particle fluid). Community/source discussion: Reddit [r/Terraria liquid code](https://www.reddit.com/r/Terraria/comments/11ejcek/how_do_liquids_in_terraria_work_in_the_code/); decompiled-style `Liquid.cs` references circulate among researchers (treat as unofficial).

**Godot CRAFT steal:** Keep **sim volume** and **waterfall VFX** decoupled. Author banks with half-step / slope tiles so “falls” appear at edges without draining the river mask.

### 2. Grass, dirt, biomes, paint — continuous ground

- **Grass as a state on soil, not a separate ground mesh:** Grass types cover Dirt/Mud (and variants). Continuity comes from **neighbor autotile framing** + **spread simulation**, not painted gradients ([Grasses](https://terraria.wiki.gg/wiki/Grasses)).
- **Spread rules (continuous “living” surface):**
  - Spreads only to **8-adjacent** correct soil.
  - Needs **≥1 open adjacent** cell (no fully buried grass growth).
  - Blocked by adjacent **lava**.
  - Pure / mowed / mowed Hallow: **surface-only** (depth meter ≥ ~4 ft on surface) ([Grasses](https://terraria.wiki.gg/wiki/Grasses)).
- **Biome continuity:** Corrupt/Crimson/Hallow grass can convert adjacent grass; Hardmode extends conversion to corruptible tiles within ~3 tiles. Containment needs **hard gaps** (commonly 3+ tile tunnels of non-corruptible material) ([Biome spread](https://terraria.wiki.gg/wiki/Biome_spread), [Guide: world purity](https://terraria.wiki.gg/wiki/Guide:Maintaining_world_purity)).
- **Paint as cosmetic continuity:** Painted grass **spreads paint** onto new grass; weeds/flowers/trees inherit paint. Purely visual — does not change biome rules ([Paints](https://terraria.wiki.gg/wiki/Paints), [Grasses](https://terraria.wiki.gg/wiki/Grasses)).
- **Mowed vs tall:** Lawn-like “mowed” grass is a **read of upkeep**; it spreads to dirt but new growth is **not** mowed — foot-traffic / maintenance zones vs wild edges ([Grasses](https://terraria.wiki.gg/wiki/Grasses)).
- **Worldgen layering:** Passes seed speckles of grass, then **Spreading Grass**, weeds, walls — ground richness is **multi-pass**, not one noise splat ([World generation](https://terraria.wiki.gg/wiki/World_generation)).

**Godot CRAFT steal:** Ecological types (mowed / meadow / damp bank) + neighbor merge + sparse prop plants beat one flat grass atlas. Paint/tint channels can soft-blend zones without new biome logic.

### 3. Structure / house validity (doors, walls, facing-ish)

Terraria does **not** score “facade facing plaza.” Validity is a **closed room machine** ([House](https://terraria.wiki.gg/wiki/House)):

| Check | Rule (desktop wiki) |
| --- | --- |
| **Frame** | Interior 8-connected; frame fully closed; frame = solid / platforms / doors / tall gates / trapdoors (closed footprint). |
| **Size** | ≥60 and &lt;750 tiles **including frame**. |
| **Walls** | Player-placed (or few worldgen exceptions); holes ≤4×4; unsafe natural walls fail. |
| **Furniture set** | ≥1 light + flat surface (“table”) + comfort (“chair”) + **entrance**. |
| **Entrance** | Door **or** platform / gate / trapdoor — need not be NPC-usable or lead outdoors. |
| **Home tile** | Solid floor stand point: 3-wide solid row, clear headroom; score penalizes doors/chests in 5×4 above stand tile. |
| **Evil score** | Corruption/Crimson nearby can invalidate (≥50). |

**Facing-ish craft:** “Facing” emerges from **door on the walkable street side** + **home tile** (NPC flag hangs above stand point) + shared walls between apartments. Multi-room buildings are **independent houses** sharing frames ([House](https://terraria.wiki.gg/wiki/House)).

**Godot CRAFT steal:** Define a **RoomValidity** service (closed hull, size band, required props, stand tile). Facing = door cell toward path graph, not camera-facing normals.

### 4. NPC housing & walking

- **Assign + query:** Housing menu assigns NPCs; “?” query reports missing frame/walls/furniture ([House](https://terraria.wiki.gg/wiki/House)).
- **Night / rain / events:** NPCs try to go home; if NPC + house offscreen, they **teleport** home ([House](https://terraria.wiki.gg/wiki/House)).
- **Day behavior:** Walk / open doors; leave already-open doors alone (archive NPC notes). Stuck pathing → unload distance → teleport ([NPC archive](https://terraria-archive.fandom.com/wiki/NPC)).
- **Pathing quirks (community-tested):** Prefer roughly straight homeward routes; **hammered stairs** often trap NPCs into climb loops — leave a **flat platform segment** so they can pass *and* climb ([r/Terraria pathing](https://www.reddit.com/r/Terraria/comments/3byehn/so_ive_been_studying_npc_pathing_in_13_and_have/), [floor-to-floor](https://www.reddit.com/r/Terraria/comments/1jpcfok/how_do_i_build_so_npcs_can_move_freely_from_floor/)).
- **Village feel:** Horizontal corridors with doors between rooms > clever vertical mazes. Shared walls OK; each room still needs its own validity set.

**Godot CRAFT steal:** Simple seek + door interaction + **despawn/teleport failsafe**; design village circulation for dumb agents (flat connectors, no stair traps).

### 5. Worldgen noise / math (wiki + modder docs)

- **Documented shape:** Ordered **GenPass** pipeline (`GenerateWorld`), not a single Perlin heightfield. Wiki lists named passes: `Terrain` (dirt/stone layers), tunnels, caves, biomes (Ice trapezoid, Desert, Jungle…), `Grass` speckles → `Spreading Grass`, weeds, structures, liquids merge polish in later patches ([World generation](https://terraria.wiki.gg/wiki/World_generation); footnotes cite `WorldGen.GenerateWorld` in desktop source).
- **TerrainPass API surface:** Exposes `WorldSurface` / High / Low, rock layer, water/lava lines, beach sizes — height **bands**, then later passes carve/fill ([TerrainPass](https://docs.tmodloader.net/docs/1.4-stable/class_terraria_1_1_game_content_1_1_biomes_1_1_terrain_pass.html)).
- **TileRunner math (modder-documented):** Splotch / worm placer — `strength` (blob size), `steps` (iterations), `speedX/Y` (biased random walk). Small strength + many steps ⇒ skinny veins; large strength + few steps ⇒ blobs ([tModLoader World Generation wiki](https://github.com/tModLoader/tModLoader/wiki/World-Generation)).
- **Perlin?** Official wiki/Re-Logic public docs **do not** prescribe “use Perlin for terrain.” Community clones and explainers often *approximate* surface with Perlin ([TerrariaClone World.java](https://github.com/radian-software/TerrariaClone/blob/9ea04b15add48141dbcb905af8fc906d423d854d/src/World.java)); treat Perlin as a **Godot-friendly substitute**, not a cited Re-Logic algorithm. Prefer **pass stack + runners + biome masks**.

### 6. Sprite sheet / tile framing

- **Framed vs FrameImportant:** Terrain autotiles (`TileFrameX/Y` from neighbors). Multitiles keep fixed frames ([tModLoader World Generation — Framing](https://github.com/tModLoader/tModLoader/wiki/World-Generation)).
- **Atlas math:** Typical cell **16×16** draw; sheet uses **2 px padding** right and below each frame. Example: frameX 36 ⇒ pixel origin 36 on sheet for a 16×16 quad ([Framing notes](https://github.com/tModLoader/tModLoader/wiki/World-Generation)).
- **Art conventions:** Vanilla-style **2×2 “fat pixels”**; sprite at 1× then Nearest upscale 2× to avoid mixels. Premultiply alpha for semi-transparent pixels ([tModLoader Spriting](https://github.com/tModLoader/tModLoader/wiki/Spriting)).
- **Tools:** [tSpritePadder](https://github.com/direwolf420/tSpritePadder) pads cutouts to Terraria tile conventions; community Basic Tile guide + `TileObjectData.CoordinatePadding = 2` ([TileObjectData](https://docs.tmodloader.net/docs/stable/class_tile_object_data.html)).
- **Variation:** Odd/even X flip and per-cell animation offsets break grid repetition ([ExampleAnimatedTile](https://github.com/tModLoader/tModLoader/blob/360ff7d9/ExampleMod/Content/Tiles/ExampleAnimatedTile.cs)).

**Godot CRAFT steal:** Godot `TileSet` atlas separation ≈ Terraria padding; terrain terrains = Framed; props = multitiles. After any procedural paint, **recompute peer bitmasks** (Terraria “frame nearby”).

---

## Math / procedural

| Pattern | Terraria use | Godot village analogue |
| --- | --- | --- |
| Ordered GenPass list | Terrain → carve → biome convert → grass → props → settle liquids | Assembler stages: height/mask → paths → banks → grass types → deco |
| Height bands | `worldSurface` / rock / water / lava lines | Y bands for plaza, bank, water plane |
| TileRunner | strength × steps random walk | Vein/patch placer for dirt scuffs, flower clusters |
| 8-neighbor spread | Grass / infect / paint | Ecological fill + quarantine gaps |
| Liquid CA + settle | Byte volume queue; load-time settle | Runtime trickle optional; bake settle for villages |
| Room flood / score | House frame + home-tile score | Validity + stand socket for each dwelling |
| Autotile framing | frameX/Y from neighbors | Terrain bitmask / peering |

**Noise stance for Dream:** Use FastNoise/Perlin for **meander rivers and meadow blotches** (see `SEAMLESS.md`), but structure villages like Terraria passes: **deterministic stages**, not one noise map.

---

## Asset pipeline

1. **Base soil atlas** (dirt/stone) with merge frames — Framed terrain.
2. **Grass overlays / types** (pure, mowed, damp) that reframe with neighbors.
3. **Liquid layer** — level frames + animated waterfall strip (visual-only OK).
4. **Half-block / slope set** — enables shoreline and falls without extra meshes.
5. **Wall / interior set** — player-valid walls vs “unsafe” natural (spawn control).
6. **Furniture kits** — light / table / chair / door minimum for room validity.
7. **Padding & nearest** — 16(+sep) atlas; Nearest filter; optional 2× fat-pixel workflow.
8. **Post-place framing** — any assembler edit must refresh bitmask peers (Terraria frames on load / nearby edit).

---

## Agent rules

**Do**

- Treat water **volume** and **waterfall FX** as separate systems.
- Paint ground as **typed ecological layers** + neighbor merge, not one swatch.
- Validate houses with an explicit checklist (hull, size, walls, four furniture classes, stand tile).
- Put **doors toward paths**; keep NPC routes flat and stupid-friendly.
- Worldgen/village assemble as **named passes**; re-frame tiles after edits.
- Keep atlas padding consistent; Nearest; no Linear bleed on tile edges.

**Don’t (禁止偷懒)**

- Don’t fake continuity with a single grass tile and vignette borders (see `SEAMLESS.md`).
- Don’t implement “full fluid sim” when a settled mask + edge FX reads as Terraria water.
- Don’t claim Perlin-as-official-Terraria without caveats — cite passes/TileRunner instead.
- Don’t stack all village UI/props on one screen/scene when rooms need separate validity spaces.
- Don’t use stair-only vertical circulation if NPCs must roam.
- Don’t skip home/stand-tile clearance (doors/chests jammed on the bed tile).
- Don’t ship unframed / all-frame-0 terrain after procedural edits.
- Don’t mix pixel scales (mixels) or Linear-filter tile atlases.

---

## Sources

| Topic | URL |
| --- | --- |
| Liquids / shoreline / settle | https://terraria.wiki.gg/wiki/Liquids |
| Liquidfalls | https://terraria.wiki.gg/wiki/Liquidfalls |
| Grasses / spread | https://terraria.wiki.gg/wiki/Grasses |
| Biome spread | https://terraria.wiki.gg/wiki/Biome_spread |
| Paints | https://terraria.wiki.gg/wiki/Paints |
| House validity | https://terraria.wiki.gg/wiki/House |
| World generation passes | https://terraria.wiki.gg/wiki/World_generation |
| tModLoader worldgen / framing / TileRunner | https://github.com/tModLoader/tModLoader/wiki/World-Generation |
| TerrainPass | https://docs.tmodloader.net/docs/1.4-stable/class_terraria_1_1_game_content_1_1_biomes_1_1_terrain_pass.html |
| Spriting / padding / 2×2 | https://github.com/tModLoader/tModLoader/wiki/Spriting |
| TileObjectData padding | https://docs.tmodloader.net/docs/stable/class_tile_object_data.html |
| tSpritePadder | https://github.com/direwolf420/tSpritePadder |
| NPC pathing (community) | https://www.reddit.com/r/Terraria/comments/3byehn/so_ive_been_studying_npc_pathing_in_13_and_have/ |
| Liquid code discussion | https://www.reddit.com/r/Terraria/comments/11ejcek/how_do_liquids_in_terraria_work_in_the_code/ |
| NPC housing teleport (archive) | https://terraria-archive.fandom.com/wiki/NPC |

**Related Dream docs:** `dream/docs/SEAMLESS.md`, `dream/docs/LAYOUT.md`.
