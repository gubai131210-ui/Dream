# Research synthesis — scene craft for Dream

**Date:** 2026-09-10  
**Inputs:** 6 game studies + 3 practitioner studies under `docs/research/`  
**Output:** project skill `.cursor/skills/realistic-scene-craft/`

---

## Batch A — games (craft only)

| Game | Agent | Strongest transferable craft |
| --- | --- | --- |
| Stardew Valley | [Stardew research](215a45a3-53c1-4e8d-ab4e-0e0588566fcd) | Water = **mask + shared overlay anim**; layers split permanent ground / spawnables / collision; NPC = schedule anchors + path preference stone→wood→dirt→grass; **draw dirt tile first** |
| Animal Crossing NH | [ACNH research](177d0165-25e1-40c7-bcf2-422a48cf0ea4) | Lock **plaza + arrival + drainage mouth** first; buildings **cannot yaw**; rivers as corridors (width ≥3, bridge 3–5); round banks after blocking; NPC graph must reach plaza |
| Link's Awakening 2019 | [LA research](aae51fc2-befb-45d9-8a03-1b7ebbf06ae0) | Bank = water → damp → dry; Mabe-like **plaza-facing lots**; toy depth via controlled layers; south-facing door art → north-of-plaza placement |
| Terraria | [Terraria research](0aa6230a-1372-4309-bab8-c94a9461895f) | Water volume ≠ waterfall VFX; grass as **state on soil** + ecological types; **house validity** machine; worldgen as **ordered passes** |
| Spiritfarer | [Spiritfarer research](79613c3f-4840-4eda-adcf-689c38154403) | Topology first: **pier → walk line → door plane**; irregular water edges; buildings face walkways |
| Octopath Traveler | [Octopath research](7be76b61-286d-4fea-ab8b-e85663399476) | Raise **tile/color density** near civic mass; water motion as plane/shader on shore mask; sort by **foot / south edge**; steal readability not full HD-2D |

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

| Topic | Agent | Strongest transferable craft |
| --- | --- | --- |
| Engineers | [Engineer research](329cd995-ef9c-4463-ab1a-f68c29a09771) | Bitmask/Wang for edges; wrap `L==R,T==B`; meander formulas; **runtime `set_cell` not terrain-connect every frame**; ecological noise chooses variants |
| Artists | [Artist research](cb09787d-48d1-4a99-94d4-05d3f577d2a2) | Silhouette→value→color→detail; **filler wrap first**, then edges/corners, then water foam, then buildings with unified door facing, props last; pivot at feet |
| Agent tooling | [Tooling research](6e0a40ce-6753-4ff1-a003-a46de043f53d) | rembg/BiRefNet 抠图; Real-ESRGAN; ImageMagick; Pillow seamless; ComfyUI optional; MCP screenshot QA |

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
