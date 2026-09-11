# Sewer C31 — residential yard well pipe run + black market

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md)  
**Skills:** `interior-territory-craft`, `interior-visual-qa`  
**SceneRouter:** `SceneRouter.C31_SEWER_PATH` → `scenes/interiors/c31_sewer/c31_sewer.tscn`

## Goal

Enterable **sewer pipe corridor** from residential yard well + return to outdoor. Distinct from NE C14 well and from mine C17 silhouette.

Acceptance (Wave C Sewer team):

1. Residential yard well `~(480,280)` has portal 「↓下水道」→ `SceneRouter.C31_SEWER_PATH` (Lead-seeded; not InfoPanel-only)
2. Interior assembles via `InteriorProfiles` `c31_sewer` + `InteriorCraft`
3. ≥1 readable **pipe run** + **black_market** booth (actor optional, shipped)
4. Clear south door corridor; TopBar「返回室外」+ south door → `village_residential.tscn` (`RES`)

## Layout (profile `c31_sewer`)

| Zone | Cluster | Anchor (tx,ty) | Role |
| --- | --- | --- | --- |
| West pipe | `pipe_run` | 6, 4 | Horizontal barrel/keg pipe mass + valve crates + tool rack + farm lamp |
| Mid junction | `junction` | 15, 3 | Total-valve crate + overflow barrel + pipe map (north of door aisle) |
| East market | `black_market` | 25, 5 | Counter (customer west / vendor east) + dark shelves + loot chest + tavern lamp |
| Booth boundary | enclosure | rect 22–30 × 2–8 | Stall rails + 4 corners; west gaps `[22,4..6]` |
| Corridor | door 14–17 | — | ≥2-tile aisle south→north kept clear of props |

Floor: `stone`. No rug / window.  
Modulate: damp green-stone `Color(0.40, 0.48, 0.46)`.  
Room: **32×11** long horizontal — ≠ C17 mine (28×18 dig hall with rock faces).

Lights: cool green at pipe/junction; warm amber at black market.  
Actor: merchant「黑市摊主」patrols `pipe_run` → `junction` → `black_market`.

## Portal host (Lead-seeded; do not relocate)

| Piece | Path |
| --- | --- |
| Outdoor assembler | `scripts/areas/village_residential_assembler.gd` |
| Yard well world pos | **`(480, 280)`** — residential 院井（≠ NE C14 well） |
| Hotspot | 「院井」 |
| Portal | 「↓下水道」 → `SceneRouter.C31_SEWER_PATH` |
| Interior return | profile `return_path = RES` + south door portal |

## Code ownership

| Piece | Path |
| --- | --- |
| Profile | `scripts/interiors/interior_profiles.gd` key **`c31_sewer` only** |
| Scene shell | `scenes/interiors/c31_sewer/c31_sewer.tscn` |
| This doc | `docs/SEWER_C31.md` |

## Interior Visual QA (desk)

```
Interior Visual QA: PASS
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none
Blockers: none (user Godot playtest pending)
```

Evidence:

- **Reality / Peer:** Reads as damp sewer tunnel with east black-market alcove in ≤3s; peer = Stardew-style sewer / town-drain corridor (long pipe mass + side stall), not mine dig face.
- **Scene-fit:** Farm lamps on pipe/junction; tavern candle on black market — no `lamp_indoor_00`.
- **Territory:** Booth enclosure + west gaps; pipe mass via repeated barrels; stock shelves behind counter.
- **Composition / Ensemble:** Three verbs (maintain / valve / fence goods); primary eye hit = pipe run then market; ≥30% open mid-corridor.
- **Interact-ready:** Customer stand west of counter (`[-2,1]`); pipe approach south of run; door 14–17 clear.
- **Corridor:** South door → north aisle open; enclosure stays east of door axis.
- **Profile-wire:** All prop paths are existing interior/outdoor props; no new sheet required.

## 禁止偷懒

- 禁止下水道只有 InfoPanel、无管道簇/黑市可读空间  
- 禁止室内无返回（TopBar + 南门 → RES）  
- 禁止簇堵死门轴 14–17 通廊  
- 禁止做成矿洞 C17（凿岩面/矿石堆/高厅）  
- 禁止改 NE C14 井 portal 或住宅区大布局  
- 禁止改写其他 Wave C profile keys / 整文件重写 `interior_profiles.gd`  
- 禁止家用台灯进管道/黑市；无四角黑市 enclosure 却声称摊位  
- 禁止未写本 MD 声称 DONE；禁止用户中文路径下强跑易损 Godot CLI  

## Demo / QA (user local Godot)

1. Hub → 住宅区 → 院井 `(480,280)` / **↓下水道**（确认不是东北 C14 井）
2. Confirm long damp stone corridor, west pipe barrels, mid valve, east stall rails + counter
3. Watch black-market merchant patrol; click pipe / market titles → InfoPanel
4. 「返回室外」or south door → residential
