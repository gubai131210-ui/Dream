---
name: realistic-scene-craft
description: >-
  Crafts and reviews Godot 2D village/tile scenes with real-world-consistent
  placement and distinct district skeletons (plaza, residential, farm, market) —
  meandering water, ecological ground, door-facing buildings with full-sprite
  AABB inside play/farm build zones, NPC walk graphs, seamless tiles, and asset
  draw order. Use when assembling or fixing village squares, rivers, grass/sand/path
  layers, building orientation, farm fences, tree/prop footprints, tile atlases,
  AREA_FRAMEWORK, or when the user mentions A09 layout, LAYOUT.md,
  BUILDING_PLACEMENT.md, SEAMLESS.md, 蜿蜒, 河岸, 朝向, 围栏, 农舍, 广场, 住宅区,
  农田, 市集, or scene realism.
---

# Realistic scene craft (Dream)

Operate on **craft**, not genre labels. Primary locks: `docs/SCALE.md`, `docs/AREA_FRAMEWORK.md`, `docs/LAYOUT.md`, `docs/BUILDING_PLACEMENT.md`, `docs/SEAMLESS.md`. Research backing: `docs/research/SYNTHESIS.md`. New art pixels: `.cursor/skills/painting-asset-craft/`.

## Leading words

- **district** — plaza / residential / farm_home / farmland / market (`AREA_FRAMEWORK.md`); each has different openness, path width, density, water role
- **mask** — boolean/occupancy truth (water, path, plantable), not “looks blue”
- **bank** — land cells touching water; paint damp/reed, never plant trees in water
- **facing** — door/camera axis of art; layout must obey art (south-door → north-of-plaza)
- **pass** — ordered generation: masks → ground → water → path → buildings → props → actors → FX
- **footprint** — multi-tile ground AABB clear of forbidden masks (necessary but not sufficient for buildings)
- **sprite AABB / build zone** — full building texture rect in world space must sit inside play rect or fenced inset (`FARM_BUILD_ZONE`), never foot-only

## When this skill runs

Copy and track:

```
Scene craft checklist:
- [ ] 1. Re-read SCALE / AREA_FRAMEWORK / LAYOUT / BUILDING_PLACEMENT / SEAMLESS
- [ ] 2. Name district id and confirm silhouette test vs other districts
- [ ] 3. Rebuild masks (water role, path grammar, bank, plantable) for THIS district
- [ ] 4. Paint ground ecology with district-weighted dpath mapping
- [ ] 5. Place paths/bridges with span rules + correct material (stone vs dirt)
- [ ] 6. Place buildings by facing slots + footprint + full sprite AABB in build zone
- [ ] 7. Door dirt south of feet (or allow_path for buildings); no apron/footprint fight
- [ ] 8. Place trees/props with footprint (yard props ⊆ build zone when fenced)
- [ ] 9. Actors on walk graph only (district anchors)
- [ ] 10. Asset/draw pass via painting-asset-craft if new art
- [ ] 11. MCP or user visual QA: roofs fully inside zone/fence; silhouette OK
- [ ] 12. Update AREA_FRAMEWORK / LAYOUT / BUILDING_PLACEMENT if rules changed
```

**Done when:** every checklist item is checked, and a review can name the district, mask functions / slot positions / build zones used.

## Hard rules (Dream)

1. Water = **meander mask** (sine/noise/cove) with a **district water role**. Never a straight `Rect2i` canal; never copy plaza west-river into every scene.
2. **Bank** cells = damp grass (mud/reed). Shoreline follows the mask.
3. Trees/yard props: **footprint** on plantable land only — never water, never plaza stone.
4. Civic props (well, bench, lamp) may sit on plaza; still never in water.
5. Building art is **south-facing** unless new sheets exist → lots **north of** civic/path; doors toward public space.
6. **Buildings: full sprite AABB ⊆ play/build zone** via `AreaCraft.find_building_inside` — see `docs/BUILDING_PLACEMENT.md`. Foot-only / small tile footprint is forbidden. Fenced farms use inset `FARM_BUILD_ZONE`, not fence-line `FARM_ZONE`.
7. Roads stop before river except a **bridge span** with parallel bank anchors.
8. NPCs: sparse anchors on preferred surfaces (stone > dirt > grass); no random full-map roam.
9. Runtime paint prefers `set_cell` / precomputed coords; do not spam `set_cells_terrain_connect` every frame.
10. Fill tiles wrap-match (`L==R`, `T==B`); Nearest + `use_texture_padding`; integer zoom.
11. Chinese paths: prefer writing tools under `dream/tools/`; ask user to run Godot tests locally when risky.
12. **District differentiation** — follow `docs/AREA_FRAMEWORK.md` parameter table. Assemblers must call `craft.setup(w, h, district_id)` (or `AreaCraft.eco_kind(..., district)`). Silhouette test must distinguish plaza ≠ residential ≠ farm_home ≠ farmland ≠ market.

## Pass order (assembler)

1. `_rebuild_masks` — water, path, bank  
2. Ecological grass (distance-to-path + edge + damp)  
3. Water layer (skip bridge deck cells)  
4. Path/plaza stone  
5. Buildings (named slots + `find_building_inside` / full AABB)  
6. Props  
7. Trees  
8. Actors  
9. Water FX only on true water cells  

Formulas: [reference-formulas.md](reference-formulas.md).

## Asset draw order (new art)

Delegate to **painting-asset-craft**. Short reminder:

1. Lock tile size (`BASE_TILE=32`) + palette + light direction + door **facing**  
2. Silhouette → value → color → detail  
3. **Filler** wrap tile first (ConcernedApe started with dirt)  
4. Edges → outer corners → inner corners  
5. Biome transitions (grass↔dirt, dry↔damp)  
6. Water fill → foam/bank  
7. Building modules (wall / door / roof) — one facing  
8. Props (pivot at feet)  
9. Slice, pad, import Nearest  
10. Polish last  

Detail: [reference-pipeline.md](reference-pipeline.md) · full painting skill: `../painting-asset-craft/SKILL.md`.

## Agent art tools

Prefer CLI/Python the agent can run. User prep list: [reference-tooling.md](reference-tooling.md).

| Need | Default tool |
| --- | --- |
| Seamless terrain | `python dream/tools/make_seamless_terrain.py` |
| 抠图 | `rembg` + `birefnet-general` |
| Upscale sheets | Real-ESRGAN ncnn-vulkan (anime model when fitting) |
| Inpaint missing element | IOPaint / LaMa / Comfy inpaint (optional; see painting-asset-craft) |
| Batch crop/montage | ImageMagick / Pillow |
| In-engine QA | Godot MCP `run_scene` + `take_screenshot` |

## Anti-lazy (forbid)

Phrase positively as targets:

- Meander centerline + variable width + bank ring **with district water role**  
- Named slots per district (not one plaza template)  
- `_footprint_ok` before every plantable spawn  
- `find_building_inside` + inset build zone for every building (no roof-over-fence)  
- Ecological grass variants with **district-weighted** dpath  
- Document rule changes in `AREA_FRAMEWORK.md` / `LAYOUT.md` / `BUILDING_PLACEMENT.md`  
- Silhouette test: five districts must remain visually distinct at 1/8 scale  

## After changes

1. User tests in Godot (Chinese paths).  
2. Commit locally; push only if `git remote` exists — otherwise tell user to add GitHub remote.  
3. Spin a review subagent against AREA_FRAMEWORK + assembler when layout rules change.  
4. Deep cites: [research-index.md](research-index.md).
