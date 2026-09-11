# Mine C17 — hill mine entrance floor

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_A2.md`](./PHASE5_WAVE_A2.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md)  
**SceneRouter:** `SceneRouter.C17_MINE_PATH` → `scenes/interiors/c17_mine/c17_mine.tscn`

## Goal

Enterable **mine entrance floor** from hill farm (A12) + return to outdoor.

Acceptance (Wave A2 Mine team):

1. Hill farm mouth has portal with `scene_path = SceneRouter.C17_MINE_PATH` (not InfoPanel-only)
2. Interior assembles via `InteriorProfiles` `c17_mine` + `InteriorCraft`
3. Dig / ore hotspots titled for interaction; clear south door corridor
4. TopBar「返回室外」+ south door portal → `hill_farm.tscn`

## Layout (profile `c17_mine`)

| Zone | Cluster | Anchor (tx,ty) | Role |
| --- | --- | --- | --- |
| West dig | `dig` | 5, 7 | Rock dig faces + pick rack + smith mine lamp + blast barrel |
| East ore | `ore` | 21, 8 | Ore crates / sacks / pick basket + farm lamp |
| North timber | `timber` | 8, 4 | Support crates + wash barrel + north dig rock + notice |
| Corridor | door 12–15 | — | ≥2-tile aisle south→north kept clear of props |

Floor: `stone`. No rug / window. Local PointLights at dig + ore. Miner patrol via dig → timber → ore.

Dig hotspot titles (InfoPanel): **可挖岩面** · **矿脉凿口** · **碎石堆** · **可挖岩壁**.

Art: reuse outdoor `rock_0*` + crates/tools/lamps — no new specialty prop sheet.

## Portal host (append-only)

| Piece | Path |
| --- | --- |
| Outdoor assembler | `scripts/areas/hill_farm_assembler.gd` → `_spawn_portals` |
| Mouth world pos | **`(180, 200)`** — NW hillside cut (west of upper terrace / switchback) |
| Hotspot | 「矿洞口」 |
| Portal | 「进入矿洞」 → `SceneRouter.C17_MINE_PATH` at mouth + `(0, 12)` |
| Visual cue | `rock_02.png` at mouth (scale 0.7) |

Interior return: profile `return_path` + `InteriorCraft` south door portal.

## Code ownership

| Piece | Path |
| --- | --- |
| Profile | `scripts/interiors/interior_profiles.gd` key **`c17_mine` only** |
| Scene shell | `scenes/interiors/c17_mine/c17_mine.tscn` |
| This doc | `docs/MINE_C17.md` |
| Portal append | `hill_farm_assembler.gd` (portals only) |

## 禁止偷懒

- 禁止矿洞口只有 InfoPanel、无 `scene_path`  
- 禁止室内无返回（TopBar + 南门）  
- 禁止簇堵死门轴 12–15 通廊  
- 禁止可挖点只有文案、无岩石/箱热点标题  
- 禁止改写山坡农田布局（只追加口）  
- 禁止动 C01–C04 或其他 Wave A2 profile keys  
- 禁止新画一整套矿洞美术冒充交付（优先复用 rock/crate/tool）  
- 禁止用户中文路径下强跑易损 Godot CLI；交付后本地 QA  

## Demo / QA (user local)

1. Hub → 山坡农田 → NW **矿洞口** / **进入矿洞**
2. Confirm stone floor, dig rocks west, ore east, aisle open
3. Click dig titles → InfoPanel
4. 「返回室外」or south door → hill farm
