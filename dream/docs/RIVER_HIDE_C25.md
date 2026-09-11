# RiverHide C25 — 河流隐藏（芦苇岔 / 小船窖）

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C25, [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa`, `interior-territory-craft` (mass via stacks/crates; no enclosure needed), `painting-asset-craft` (reuse only this pass)  
**Peer silhouette:** Link’s Awakening / Zelda bank reed pocket — damp green bank → stepping-stone fork → beached skiff cache (reads as “secret river cut” in ≤3s)

## Goal

| ID | Place | Enter from | Return |
| --- | --- | --- | --- |
| **C25** | 芦苇岔路（芦苇口 · 跳石隐径 · 小船窖） | A06 river 西岸芦苇岔 `~(220,380)` | TopBar + south door → `RIV` |

Acceptance (Wave C RiverHide): **≥1 隐藏岔路**, `scene_path` portal (not InfoPanel-only), interior `return_path` = river.

## SceneRouter (pre-seeded — do not reorder)

```
C25_RIVER_HIDE_PATH → res://scenes/interiors/c25_river_hide/c25_river_hide.tscn
```

Scene is InteriorProfiles + InteriorCraft shell (`profile_id = "c25_river_hide"`). Enrichment is **profile-only** for this key + this MD.

## Outdoor portal (Lead-seeded — do not move)

| Portal | Assembler | World | Label |
| --- | --- | --- | --- |
| C25 reed fork | `river_assembler` | `(220, 380)` + portal @ `+ (0,12)` | 进入芦苇岔 |

Hotspot title: **芦苇岔口**. Outdoor layout is Lead-owned; RiverHide does not edit the assembler.

## Interior profile (functional clusters)

| Field | Value |
| --- | --- |
| Room | `22×14` |
| Door aisle | `door_tx0..1 = 9..12` |
| Floor | `straw` |
| Modulate | damp green `Color(0.58, 0.70, 0.54)` |
| Return | `RIV` → `scenes/areas/river/river.tscn` |

| Cluster | Anchor | Verb |
| --- | --- | --- |
| `reed` | (4, 7) | 芦苇口 — hay/herb reed clumps + basket + wet sack + farm lamp |
| `stepping` | (11, 4) | 倒木/跳石隐径 — rock chain + path mark (north of door aisle) |
| `skiff` | (17, 8) | 小船窖 — crate pair + barrel + coin cache + bamboo rod + lamp |

- **Door corridor:** tiles 9–12 kept clear south→north (≥2 tile aisle).  
- **Modulate:** damp green — no orange wash / checker floor.  
- **Floor:** straw (soft bank, not indoor plank).  
- **Actor:** 苇岸渔人 patrols `reed` ↔ `skiff` with south approach stands.  
- **Lights:** reed mouth + stepping + skiff (cool-green damp).  
- **No 占位** in hint / titles.

## Ownership / files touched

| Path | Role |
| --- | --- |
| `scripts/interiors/interior_profiles.gd` | Enrich **only** `"c25_river_hide"` |
| `scenes/interiors/c25_river_hide/**` | Stub scene (structure unchanged) |
| `docs/RIVER_HIDE_C25.md` | This package doc |

**Not owned:** `river_assembler.gd`, `scene_router.gd`, other Wave C profiles, outdoor reed art.

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A06 river west bank | `make_portal("进入芦苇岔", C25_RIVER_HIDE_PATH)` | C25 interior |
| C25 south door / TopBar 返回室外 | `return_path` = `RIV` | `scenes/areas/river/river.tscn` |
| C25 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测）。  
2. Run **河流** `res://scenes/areas/river/river.tscn`（Hub → 河流，或邻区 →河流）。  
3. Click **进入芦苇岔** near west bank `~(220,380)`.  
4. Read in ≤3s: west reeds → north stepping path → east skiff cache; click props for InfoPanel.  
5. Exit: south **← 返回** or TopBar **返回室外** → river.

## 禁止偷懒

1. 禁止拆掉 Lead 已挂的 `进入芦苇岔` portal  
2. 禁止室内无 `return_path` / 堵死南门廊道 9–12  
3. 禁止改别人 profile；禁止整文件重写 `interior_profiles.gd`  
4. 禁止大改室外河流布局  
5. 禁止棋盘格地板 / 整屋橙色洗色  
6. 禁止只有 InfoPanel、无可读芦苇/小船簇就声称 DONE  
7. 禁止未写本 MD 声称 DONE  
8. 禁止塞满到无法并排走人、无法站在苇篮/船箱前交互  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (reed fork + skiff) | Peer PASS (LA bank pocket)
      Scene-fit PASS (damp green, farm lamp, straw) | Territory SOFT (mass via crates/hay; open fork)
      Composition PASS (3 verbs) | Ensemble PASS (primary reed west, skiff east, open aisle)
      Interact-ready PASS (via_stands south of reed/skiff)
Art: reuse props + fishing rod; no new sheet
Assembly: Corridor PASS (door 9–12) | Y-sort via craft | Profile-wire PASS
Escalation: none
Blockers: none desk-side; confirm portal pick + return in editor
```

## Acceptance checklist

- [x] `c25_river_hide` profile: reed + stepping + skiff clusters, green damp modulate, `return_path` RIV  
- [x] Actor route reed ↔ skiff  
- [x] South door corridor clear  
- [x] Outdoor portal Lead-seeded at river ~(220,380)  
- [x] This package MD  
- [ ] User Godot enter / read path / return QA  
