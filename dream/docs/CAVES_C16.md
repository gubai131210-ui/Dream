# Caves C16 — ordinary cave entry + crystal mid

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `interior-visual-qa` (desk PASS); no new prop sheet this wave  
**SceneRouter (Lead-seeded):**  
`C16_CAVE_ENTRY_PATH` → `scenes/interiors/c16_cave_entry/c16_cave_entry.tscn`  
`C16_CAVE_MID_PATH` → `scenes/interiors/c16_cave_mid/c16_cave_mid.tscn`

## Goal

Two-layer ordinary cave from hill farm east mouth (**≠** NW mine / C17):

| Layer | Profile | Theme | Return |
| --- | --- | --- | --- |
| Entry | `c16_cave_entry` | Stone vestibule + descent shaft | TopBar + south door → `hill_farm` |
| Mid | `c16_cave_mid` | Crystal plinth + seep pool (cool lights) | TopBar + south door → entry |

Acceptance (Wave C Caves):

1. Hill farm 「进入洞穴」 → entry (Lead portal host; not owned here)
2. Entry `extra_portals` 「↓中层」 → mid
3. Mid returns to entry; entry returns outdoors
4. Distinct silhouettes entry vs mid (and vs C17 dig/ore mine)
5. Stone floors; clear south door aisles; **no** full lava/ice/mushroom family this wave

## Outdoor host (Lead-seeded — do not edit)

| Piece | Value |
| --- | --- |
| Assembler | `scripts/areas/hill_farm_assembler.gd` |
| Landmark | 普通洞口 `~(1000, 240)` east hillside |
| Hotspot | 「进入洞穴」 → `SceneRouter.C16_CAVE_ENTRY_PATH` |

## Layout

### `c16_cave_entry` — stone entry

| Zone | Cluster | Anchor | Role |
| --- | --- | --- | --- |
| West mouth | `mouth` | 5, 9 | Vestibule rubble + pack crate + farm lamp |
| NW camp | `camp` | 6, 5 | Hay rest + probe rack + supply crate |
| East shaft | `descent` | 18, 7 | Notice / rope crate / well-lip rocks |
| Corridor | door 11–14 | — | ≥2-tile south→north aisle clear |
| Portal | `extra_portals` | **(18, 10)** | 「↓中层」 → mid (south of descent) |

Floor: `stone`. Warm-grey modulate. Warm PointLights at mouth + descent. Actor: 探洞人 `mouth` → `camp` → `descent`.

Peer silhouette: ordinary cave vestibule + rope shaft (not mine dig face).

### `c16_cave_mid` — crystal chamber

| Zone | Cluster | Anchor | Role |
| --- | --- | --- | --- |
| West crystal | `crystal` | 6, 6 | Crystal-cache chest + crystal-stand-in rocks + niche lamp |
| East pool | `glow_pool` | 16, 8 | Seep barrels + wet rocks + cool lamp |
| North bench | `sample` | 15, 4 | Sample crate / basket / tool rack |
| Corridor | door 9–12 | — | South door aisle clear |

Floor: `stone`. Cool blue-grey modulate. **Cool** cyan PointLights at crystal + pool (+ soft mid fill). Actor: 晶脉探工 `crystal` → `sample` → `glow_pool`.

Peer silhouette: crystal plinth chamber (Stardew/RM crystal cave read) vs entry’s rubble camp + shaft.

Art: reuse outdoor `P_ROCK0`–`P_ROCK3` (`rock_00`…`rock_03.png`) + crates/barrels/lamps/`coin_chest` — no new specialty crystal sheet this wave.

## Layer portals

```
hill_farm ──进入洞穴──► c16_cave_entry ──↓中层──► c16_cave_mid
                ▲                                    │
                └──────── return_path / 南门 ─────────┘
c16_cave_entry return_path → hill_farm
```

## Ownership

| Path | Role |
| --- | --- |
| `scripts/interiors/interior_profiles.gd` | Enrich **only** `c16_cave_entry` + `c16_cave_mid` |
| `scenes/interiors/c16_cave_entry/**` | Stub scene (structure unchanged) |
| `scenes/interiors/c16_cave_mid/**` | Stub scene |
| `docs/CAVES_C16.md` | This package doc |

**Not owned:** outdoor assemblers, `scene_router.gd`, other Wave C keys, C17 mine.

## Interior Visual QA (desk)

```
Interior Visual QA: PASS
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete(N/A no fence set) | Bleed | FX
Assembly: Multi-view(N/A) | Splice(N/A) | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none
Blockers: none (user Godot playtest for colliders / diegetic light)
```

Evidence (profile + peer reuse):

- **Reality / Peer:** Entry reads as stone vestibule + rope shaft; mid as crystal plinth + seep (vs C17 dig/ore / C26 wet relic).
- **Scene-fit:** Entry `lamp_farm`; mid niche/pool `lamp_indoor` + cool PointLights (not farm/shop misuse).
- **Composition:** One verb per cluster; satellites |d|≤3; actor via ≥2 stands with south approach on use points.
- **Ensemble / Interact-ready:** Three zones + open center corridor; door axes 11–14 / 9–12 free; portal south of descent props.
- **Corridor:** South door aisles kept clear of rocks/crates.
- **Profile-wire:** Paths to mid/entry/hill_farm + rock/crate/lamp assets that exist.

## 禁止偷懒

- 禁止只有一层却声称分层 Done  
- 禁止拆掉 `extra_portals` / 堵死南门廊道  
- 禁止做成 C17 矿洞翻版（可挖面/矿石堆）  
- 禁止一次做满熔岩/冰/蘑菇全主题族  
- 禁止改室外 assembler / 其他 profile keys  
- 禁止整文件重写 `interior_profiles.gd`  
- 禁止棋盘格地板 / 整屋橙色洗色  
- 禁止用户中文路径下强跑易损 Godot CLI；交付后本地 QA  

## Demo / QA (user local)

1. Hub → 山坡农田 → 东侧 **进入洞穴** (~1000, 240) ≠ NW 矿洞  
2. Entry: stone floor, west rubble camp, east 「↓中层」  
3. Mid: cooler light, crystal plinth west, seep pool east  
4. Mid 「返回」/南门 → entry → outdoor hill farm  
