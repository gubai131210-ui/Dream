# Research synthesis — scene craft for Dream

**Date:** 2026-09-10  
**Inputs:** 6 game studies + 3 practitioner studies under `docs/research/`  
**Output:** project skill `.cursor/skills/realistic-scene-craft/`

---

## Batch A — games (craft only)

| Game | Research note | Strongest transferable craft |
| --- | --- | --- |
| Stardew Valley | `games/stardew-valley.md` | Water = **mask + shared overlay anim**; layers split permanent ground / spawnables / collision; NPC = schedule anchors + path preference stone→wood→dirt→grass; **draw dirt tile first** |
| Animal Crossing NH | `games/animal-crossing-nh.md` | Lock **plaza + arrival + drainage mouth** first; buildings **cannot yaw**; rivers as corridors (width ≥3, bridge 3–5); round banks after blocking; NPC graph must reach plaza |
| Link's Awakening 2019 | `games/links-awakening-2019.md` | Bank = water → damp → dry; Mabe-like **plaza-facing lots**; toy depth via controlled layers; south-facing door art → north-of-plaza placement |
| Terraria | `games/terraria.md` | Water volume ≠ waterfall VFX; grass as **state on soil** + ecological types; **house validity** machine; worldgen as **ordered passes** |
| Spiritfarer | `games/spiritfarer.md` | Topology first: **pier → walk line → door plane**; irregular water edges; buildings face walkways |
| Octopath Traveler | `games/octopath-traveler.md` | Raise **tile/color density** near civic mass; water motion as plane/shader on shore mask; sort by **foot / south edge**; steal readability not full HD-2D |

### Cross-game consensus (high confidence)

1. **Water is never a naked straight canal** — meander or designer corridor + bank ring + optional foam/overlay.
2. **Ground is layered ecology** — path-adjacent short grass, yards meadow, edges tall, banks damp; multiple variants kill tiling.
3. **Facing is constrained by camera art** — if doors face +Y/south, civic lots sit north of plaza (ACNH: no free rotation).
4. **Nothing “lives” in invalid cells** — trees/props need plantable footprints; bridges need parallel bank anchors.
5. **NPCs follow a graph** — sparse destinations + stick to roads; idle wander only at anchors.
6. **Paint / generate in passes** — elevation/mask → water → banks → paths → buildings → props → FX.
7. **Math is for richness at village scale** — sine/noise meander + distance fields; full drainage (mapgen4) only if map is continent-sized.

---

## Batch B — practitioners

| Topic | Research note | Strongest transferable craft |
| --- | --- | --- |
| Engineers | `practitioners/engineers-tilemap-terrain.md` | Bitmask/Wang for edges; wrap `L==R,T==B`; meander formulas; **runtime `set_cell` not terrain-connect every frame**; ecological noise chooses variants |
| Artists | `practitioners/artists-tile-pipeline.md` | Silhouette→value→color→detail; **filler wrap first**, then edges/corners, then water foam, then buildings with unified door facing, props last; pivot at feet |
| Agent tooling | `practitioners/agent-art-tooling.md` | rembg/BiRefNet 抠图; Real-ESRGAN; ImageMagick; Pillow seamless; ComfyUI optional; MCP screenshot QA |

### Engineer ∩ artist consensus

- Seamless fill ≠ transition tiles — author both.
- Nearest + padding fixes **engine** bleed; vignette needs **pixel rewrite**.
- Door facing is an art lock before layout code.

---

## Implications for Dream (already partially implemented)

| Dream doc / code | Aligns with |
| --- | --- |
| `SCALE.md` BASE_TILE=32 | Stardew grid discipline; OT texel snap |
| `SEAMLESS.md` ecological grass | Stardew tufts; Terraria grass-state; OT density |
| `LAYOUT.md` meander + north lots | ACNH/LA/Spiritfarer facing + bank rules |
| `village_square_assembler.gd` masks | Engineer bank ring + sine meander |
| `make_seamless_terrain.py` | Artist wrap + engineer padding |

### Next craft upgrades (priority)

1. Water **overlay animation** (Stardew-style shared strip) on meander mask.  
2. Bridge as **prop + valid span rules** (ACNH 3–5 width), not only paved cells.  
3. NPC schedule anchors on stone preference graph.  
4. Dirt path spurs from plaza to each door (ACNH path grammar).  
5. rembg + Real-ESRGAN in agent asset loop (user install).

---

## Sources index

See files under `docs/research/games/` and `docs/research/practitioners/` (each cites primary URLs).
