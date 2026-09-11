# Phase 5 Wave B — Civic interiors (C06–C11)

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**User lock:** Expand public-service interiors. **Do not polish C01–C04** (Wave E deferred).  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills (mandatory):** `realistic-scene-craft` (outdoor portal host only), `interior-territory-craft` (if enclosure/mass needed), `painting-asset-craft` (new props only), `interior-visual-qa` (desk PASS before claiming DONE)

## Parallel teams (file ownership mutual exclusion)

| Team | Package | Own (create/edit) | Portal host (Lead-seeded; teams do NOT edit) | Done when |
| --- | --- | --- | --- | --- |
| **TownHall** | C06 | **only** `c06_town_hall` block in `interior_profiles.gd` + `docs/TOWN_HALL_C06.md` + optional unique props | Square 村公所 door — already seeded | **DONE** — 见 [`TOWN_HALL_C06.md`](./TOWN_HALL_C06.md) |
| **School** | C07 | **only** `c07_school` + `docs/SCHOOL_C07.md` + optional props | Square 学校 | **DONE** — 见 [`SCHOOL_C07.md`](./SCHOOL_C07.md) |
| **Clinic** | C08 | **only** `c08_clinic` + `docs/CLINIC_C08.md` + optional props | Square 医馆 | **DONE** — 见 [`CLINIC_C08.md`](./CLINIC_C08.md) |
| **Library** | C09 | **only** `c09_library` + `docs/LIBRARY_C09.md` + optional props | Square 图书馆 | **DONE** — 见 [`LIBRARY_C09.md`](./LIBRARY_C09.md) |
| **Church** | C10 | **only** `c10_church` + `docs/CHURCH_C10.md` + optional props | Square 教堂 | **DONE** — 见 [`CHURCH_C10.md`](./CHURCH_C10.md) |
| **StationInt** | C11 | **only** `c11_station` + `docs/STATION_C11.md` + optional props | A11 车站主楼门 — seeded | **DONE** — 见 [`STATION_C11.md`](./STATION_C11.md) |

**Shared (Lead only):** `scene_router.gd` constants, `tools/gen_interior_scenes.py`, `village_square_assembler.gd` civic titles+portals, `station_assembler.gd` enter portal, stub profiles, this MD, `PHASE5.md` table.

### Outdoor host map (A09 plaza remapped for missing civic shells)

| Building (approx pos) | Title | Portal label | Interior |
| --- | --- | --- | --- |
| `building_00` ~(640,280) | 村公所 | 进入村公所 | C06 |
| `building_02` ~(320,280) | 学校 | 进入学校 | C07 |
| `building_04` ~(440,280) | 医馆 | 进入医馆 | C08 |
| `building_03` ~(1080,300) | 图书馆 | 进入图书馆 | C09 |
| `building_01` ~(1000,280) | 教堂 | 进入教堂 | C10 |
| Station `building_03` door | 车站主楼 | 进入车站 | C11 |

## SceneRouter paths (pre-seeded)

```
C06_TOWN_HALL_PATH → scenes/interiors/c06_town_hall/c06_town_hall.tscn
C07_SCHOOL_PATH → scenes/interiors/c07_school/c07_school.tscn
C08_CLINIC_PATH → scenes/interiors/c08_clinic/c08_clinic.tscn
C09_LIBRARY_PATH → scenes/interiors/c09_library/c09_library.tscn
C10_CHURCH_PATH → scenes/interiors/c10_church/c10_church.tscn
C11_STATION_INT_PATH → scenes/interiors/c11_station/c11_station.tscn
```

## Patterns

- Enrich **stub profiles only** — replace your `c0X_*` dictionary; never rewrite peers / C01–C05 / Wave A2 rooms.
- Prefer reuse of existing interior props (`shelf`, `counter`, `notice`, `ledger`, `medicine`, `lamp_indoor/shop`, benches via outdoor `bench_*` if needed at ≤0.55).
- New art: unique filenames under `assets/sprites/interior/props/` via `painting-asset-craft`; no outdoor grass bleed.
- Every room: clear **south door aisle** (`door_tx0`–`door_tx1`), TopBar 返回室外 + Hub, `return_path` = square (C06–C10) or station (C11).
- Silhouettes must differ: hall≠classroom≠clinic≠library stacks≠nave≠waiting hall.
- Desk `interior-visual-qa` gates (especially Reality / Ensemble / Interact-ready / Corridor) before DONE.

## 禁止偷懒

1. 禁止再深挖 C01–C04 / Wave A2 已交付包  
2. 禁止门只有 InfoPanel、无 `scene_path`（Lead 已挂 portal；禁止拆掉）  
3. 禁止室内无返回 / 堵死南门廊道  
4. 禁止改别人 `c0X_*` profile；禁止整文件重写 `interior_profiles.gd`  
5. 禁止大改广场/车站室外布局（Lead 已改标题+portal；团队勿动 assembler）  
6. 禁止复制室外 assembler 改名交差  
7. 禁止棋盘格地板 / 整屋橙色洗色  
8. 禁止六个公服同一轮廓（相同 room 尺寸+相同双柜布局）  
9. 禁止未写本包 MD 就声称 DONE  
10. 禁止用户中文路径强跑易损 Godot CLI；交付后用户本地测  
11. 禁止一次做满地下室/二楼/夜市等扩展（本波只要库表「最小可玩交付」）  
12. 禁止抢改 `scene_router.gd` 已有常量顺序  

## Acceptance (Wave B)

1. Hub → 广场 → 五栋公服均可进并返回广场  
2. Hub → 车站 → 进入车站内部并返回车站室外  
3. 六包各有 MD；PHASE5 / 本表 DONE  
4. Commit + push  
5. User Godot QA  
