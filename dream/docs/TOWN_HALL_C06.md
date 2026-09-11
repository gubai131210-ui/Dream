# Town Hall C06 — 村公所内部

**Status:** DONE  
**Date:** 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa` (desk PASS), reuse props (no new art this wave)

## Goal (Wave B Done-when)

大厅 + 办公室 ≥2 distinct clusters; enter from square portal; return to square.

| Cluster | Verb | Anchor | Key props |
| --- | --- | --- | --- |
| `hall` | 公示 / 议事 | (7, 9) | notice + dining table + stools (approach south) |
| `office` | 批文 / 归档 | (19, 7) | counter (visitor south) + ledger + dresser/shelf/crates mass |

## Enter / return

| Step | Path |
| --- | --- |
| Hub → 广场 | village square |
| 进入村公所 | Square building「村公所」portal → `scenes/interiors/c06_town_hall/c06_town_hall.tscn` |
| Return | TopBar / south door → `return_path` = village square (`SQ`) |

Lead-seeded: `SceneRouter.C06_TOWN_HALL_PATH`, square portal label「进入村公所」— **not** owned by this package.

## Profile ownership

| Piece | Path |
| --- | --- |
| Profile block only | `scripts/interiors/interior_profiles.gd` → `"c06_town_hall"` |
| This MD | `docs/TOWN_HALL_C06.md` |
| Props | Reused: `notice`, `table_dining`, `stool`/`stool_tea`, `counter`, `ledger`, `dresser`, `shelf`, `crate_*`, `lamp_indoor` |

**Silhouette:** room `26×19` plank; west meeting hall + east archive office; center south aisle `door_tx0–door_tx1 = 11–14`. ≠ school rows / clinic bed / library stacks / church nave / station waiting.

## Circulation

- South door aisle columns **11–14** kept clear (hall east stool ≤ tx9; office west ≥ tx18).
- Hall: free approach south of旁听凳 `(7,12)` and south of notice `(6,6)`.
- Office: staff at counter north (`via_stands.office [0,0]`); visitor approach south of办证柜 `(19,10)`.
- Actor 镇长: `via_clusters` ≥2 (`office`, `hall`).

## Lights

Local `PointLight2D` at hall lamp, office desk, soft north window — **no** full-room orange wash.

## User QA checklist (Godot playtest)

- [ ] Hub → 广场 →「进入村公所」loads C06
- [ ] South door / TopBar returns to square
- [ ] South aisle walkable (not blocked by meeting or office props)
- [ ] Hall reads as公告+议事 (notice + table seating) in ≤3s
- [ ] Office reads as职员北 / 访客南 + archive mass east
- [ ] 镇长 patrol visits office then hall stands
- [ ] Local lamps only (no whole-room orange)

## Interior Visual QA (desk)

```
Interior Visual QA: PASS
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none
Blockers: none (user Godot playtest for colliders / prompts)
```

### Evidence (desk)

| Gate | Evidence |
| --- | --- |
| Reality | Civic hall: west公告+议事桌, east办证柜+案牍+档案体量 — reads 村公所 ≤3s (not shop/school). |
| Peer | Civic split like RPG Maker town-hall / clerk-office: public board+table vs staff desk+filing (vs C04 grocery wall-shelf+south counter only). |
| Scene-fit | Function = 大厅公示/议事 + 办公室批文归档; product = reused interior props, no outdoor grass. |
| Territory | Office archive **mass** = dresser + 2 shelves + 2 crates east of staff; no pen needed. |
| Composition | One verb/cluster; satellites \|d\|≤3; stools face table; staff≠visitor at counter. |
| Ensemble | Primary hall table + secondary office; center aisle + ≥30% open floor south/center. |
| Interact-ready | Approach tiles at notice south, meeting south `(7,12)`, visitor south of counter; patrol lane free; door aisle ≥2 tiles. |
| Style / Craft | Read PNGs: notice board, dining table, ledger desk, shelf jars, dresser, stool, counter bell, indoor lamp — shared 3/4 wood ramp. |
| Set-complete | Table + matching stools; shelf pair + crates as archive set. |
| Bleed | Indoor props only; crates are outdoor storage sprites used as archive mass (no grass tile). |
| FX | None required (no hearth/forge). |
| Corridor | `door_tx0–14` clear; hall/office flanking west/east. |
| Name≠pixels | Titles match sprites (公告板/会议桌/镇长案/办证柜/卷宗架). |
| Size | Scales 0.5–1.0 family; signature counter 1.0, stools ~0.55. |
| Profile-wire | `c06_town_hall` paths = existing `P_*` constants; lights local; `return_path` = SQ. |

## 禁止偷懒

- 禁止门只有 InfoPanel、无 `scene_path`（Lead portal 已挂）
- 禁止堵死南门廊道 / 复制杂货双侧货架轮廓
- 禁止整文件重写 `interior_profiles.gd` / 改 C01–C05、C07–C11
- 禁止整屋橙色洗色；未写本 MD 就声称 DONE
- 禁止用户中文路径强跑 Godot CLI（交付后用户本地测）
