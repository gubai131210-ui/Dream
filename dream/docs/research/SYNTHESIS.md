# Research synthesis — scene craft for Dream (v2)

**Date:** 2026-09-10  
**Inputs:** 12 game studies + 5 practitioner studies under `docs/research/`  
**Outputs:** `docs/AREA_FRAMEWORK.md` · `.cursor/skills/realistic-scene-craft/` · `.cursor/skills/painting-asset-craft/`

---

## Batch A — games (craft only)

### Wave 1 (prior)

| Game | Note | Strongest transferable craft |
| --- | --- | --- |
| Stardew Valley | `games/stardew-valley.md` | Water = mask + shared overlay anim; dirt tile first; NPC path preference stone→wood→dirt→grass |
| Animal Crossing NH | `games/animal-crossing-nh.md` | Lock plaza + arrival + drainage; buildings cannot yaw; river width ≥3; bridge 3–5 |
| Link's Awakening 2019 | `games/links-awakening-2019.md` | Bank = water→damp→dry; plaza-facing lots; south-door → north lots |
| Terraria | `games/terraria.md` | Grass as state on soil; house validity; ordered worldgen passes |
| Spiritfarer | `games/spiritfarer.md` | Topology: pier → walk line → door plane |
| Octopath Traveler | `games/octopath-traveler.md` | Density near civic mass; sort by foot/south edge |

### Wave 2 (this pass — district skeletons)

| Game | Note | Strongest transferable craft |
| --- | --- | --- |
| Story of Seasons / FoMT | `games/story-of-seasons.md` | **三区开敞度不同**：农场=田野极开敞+北缘建筑带；广场=硬铺最大开敞；住宅=沿路串珠。农场北进村。水体常为功能岛（塘）而非全图渠 |
| Coral Island | `games/coral-island.md` | **西农 → 绿缓冲(Garden Lane) → 铺装镇心**；铺装强度=市民化；每区一种开放空间类型；节日旗作临时导向 |
| Dreamlight Valley | `games/dreamlight-valley.md` | Plaza hub + spoke biomes；每区 Well 锚点；path 是免费骨架；住宅外溢到邻 biome；地标优先于迷宫岔路 |
| My Time at Portia | `games/my-time-at-portia.md` | **双广场 + Main Street 脊**；工坊在城墙外；河=硬分区；门脸朝广场心；故意低流量绿 Park |
| Rune Factory 4 | `games/rune-factory-4.md` | 命名分区：广场度中心 + 东商店廊 + 西住宅服务 + 北交通脊 + 城堡后农场；台阶/窄径=心理边界 |
| Fields of Mistria | `games/fields-of-mistria.md` | 多区域房间图：北仪式轴+中喷泉 civic pair+南商业夹道；城外缓冲住宅再接南农场；桥=图边/进度门；水类型枚举（pond/river/ocean/装饰喷泉） |

### Cross-game consensus (high confidence)

1. **Districts differ by openness × paving × density × water role** — not by palette rename.  
2. **Water is never a naked straight canal** — meander / pond island / irrigation / beach band; role changes per district.  
3. **Ground is layered ecology** — path-adjacent short grass, yards meadow, edges tall, banks damp.  
4. **Facing is constrained by camera art** — south doors → north-of-public lots; buildings rarely free-yaw.  
5. **Road hierarchy** — main wide, spur narrow; stone for civic, dirt for farm.  
6. **Buffers** — farm does not glue to plaza stone (Garden Lane / wall / park).  
7. **NPCs follow a graph** — sparse destinations; plaza as fold-back hub (RF4 morning loop).  
8. **Paint / generate in passes** — masks → ground → water → path → buildings → props → FX.  
9. **Math at village scale** — sine/noise meander + multi-source distance fields; full drainage only for continents.

---

## Batch B — practitioners

| Topic | Note | Strongest transferable craft |
| --- | --- | --- |
| Engineers (tile) | `practitioners/engineers-tilemap-terrain.md` | Bitmask/Wang; wrap edges; runtime `set_cell` |
| Engineers (zones) | `practitioners/engineers-zone-richness.md` | **One pipeline, many ZoneParams**; multi-source BFS; Poisson props; crop grid vs organic yard |
| Artists (tiles) | `practitioners/artists-tile-pipeline.md` | Silhouette→value→color→detail; filler wrap first |
| Artists (sprites) | `practitioners/sprite-painting-specs.md` | Size matrix; walk 4/6/8; facing lock; inpaint hole recipe; 1× master |
| Agent tooling | `practitioners/agent-art-tooling.md` | rembg **must** `-m birefnet-general`; IOPaint/LaMa inpaint; Real-ESRGAN; no bare rembg (bria default) |
| District grammar | `practitioners/district-spatial-grammar.md` | GDC Bulavina street/square/backyard；Space Syntax 整合度；参数表 → `AREA_FRAMEWORK.md` |

### Engineer ∩ artist ∩ games

- Seamless fill ≠ transition tiles — author both.  
- Door facing is an art lock before layout code.  
- **Monotony = shared skeleton** — fix with `AREA_FRAMEWORK` params, not more deco.  
- Inpaint/cutout cannot invent correct facing or district openness.

---

## Implications for Dream

| Doc / skill | Role |
| --- | --- |
| `AREA_FRAMEWORK.md` | **District parameter lock** (plaza / residential / farm_home / farmland / market) |
| `LAYOUT.md` / `SEAMLESS.md` / `BUILDING_PLACEMENT.md` | Execution rules |
| `realistic-scene-craft` | Assembler checklist + formulas + anti-lazy |
| `painting-asset-craft` | Sizes, frames, views, inpaint, tool loop |

### Priority craft upgrades

1. Assemblers read explicit `district_id` + ZoneParams (ecology thresholds from formulas).  
2. Enforce silhouette test in QA (1/8 screenshot distinguishability).  
3. Optional Garden-Lane style buffer scene between farm hub and plaza (future).  
4. Water overlay animation on meander mask (Stardew).  
5. User installs IOPaint for hole-fill; always BiRefNet for 抠图.

---

## Anti-lazy（跨文档禁止偷懒）

- 禁止五区共用同一中心石板 + 北排房 + 西直河模板  
- 禁止只换贴图/坐标、不换路宽·密度·水体角色  
- 禁止全区同一生态 `dpath` 映射  
- 禁止农田无矩形田床却称农田；市集画成正中大广场  
- 禁止 raw AI 大图当 32 atlas；禁止跳过 filler wrap / 内角  
- 禁止 bare `rembg i`（默认 bria 非商用）— 必须 `-m birefnet-general`  
- 禁止跳过 silhouette test  

---

## Sources index

See `research-index.md` in the skill folder and files under `docs/research/games/` · `practitioners/`.
