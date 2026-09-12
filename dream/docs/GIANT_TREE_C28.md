# GiantTree C28 — 巨树洞 hall + climb + roots

**Status:** DONE (code) 2026-09-11 — user Godot QA next  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C28, [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-territory-craft`, `interior-visual-qa` (desk), `painting-asset-craft` (reuse only this wave)  
**Outdoor host:** A05 `forest_deep` 巨树 `tile~(16,14)` · portal 「进入巨树洞」 (Lead-seeded)

## Goal

| ID | Place | Enter from | Return |
| --- | --- | --- | --- |
| **C28** | 巨树洞 — 树洞厅 + 攀梯 + 根系窖 | Forest deep 巨树洞口 | TopBar + south door → `FDEEP` |

Acceptance (Wave C GiantTree): **≥1 树洞厅** with climb + roots readable; silhouette **≠** C27 猎人隐所.

## SceneRouter (pre-seeded — do not reorder)

```
C28_GIANT_TREE_PATH → res://scenes/interiors/c28_giant_tree/c28_giant_tree.tscn
```

Scene is InteriorProfiles + InteriorCraft stub (`profile_id` wired). Enrichment is **profile-only** for `c28_giant_tree`.

## Outdoor portal

| Portal | Assembler | Tile | Label |
| --- | --- | --- | --- |
| C28 巨树洞 | `forest_deep_assembler` | `~(16, 14)` | 进入巨树洞 |

## Design silhouette

- **Warm wood / straw** hollow: `floor: straw`, modulate amber-brown `(0.72, 0.58, 0.42)` — not C27 green camp tint.
- **Taller room** `22×22` so the hollow reads vertical.
- **Door aisle** mid `tx 9–12` kept clear south→north.
- **≠ C27A:** no hay bedroll, no hunt-gear crate wall, no hunter NPC — gathering hall + trunk climb + root cellar.

**Peer:** Great-Deku / hollow-tree shrine chamber — central stump table, peripheral climb wall, SE root mass.

## Interior profile (`c28_giant_tree`)

| Cluster | Anchor | Verb |
| --- | --- | --- |
| `hall` | (10, 8) | Primary — root stump table + stools + log pew; bark notice; indoor warm lamp |
| `climb` | (4, 7) | West trunk peg ladder (`peg_ladder_00`) + stump-step crates + climb shelf |
| `roots` | (17, 13) | SE root cellar — `root_mass_00` mass, crates, moss, resin sack, sap barrel, coin cache |

- `rug` under hall south sit (`ox/oy` 10, 10).
- Lights: hall amber key + climb + roots fills.
- Actor: **守树人** (`elder_woman`) patrols `hall` ↔ `climb` ↔ `roots` with south approach stands.

## Ownership / files touched

| Path | Role |
| --- | --- |
| `scripts/interiors/interior_profiles.gd` | Enrich **only** `c28_giant_tree` |
| `scenes/interiors/c28_giant_tree/**` | Stub scene (structure unchanged) |
| `docs/GIANT_TREE_C28.md` | This package doc |

**Not owned:** `scene_router.gd`, outdoor assembler, other Wave C profiles, C27 forest hides.

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk / profile-wire)
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none
Blockers: user Godot playtest for collider / diegetic light / prompt polish
```

| Gate | Evidence |
| --- | --- |
| Reality | Reads as hollow-tree hall in ≤3s (stump table + climb wall + root mass) |
| Peer | Hollow-tree shrine chamber (central sit, climb periphery, root cellar) |
| Scene-fit | Warm wood/straw; `lamp_indoor` hall + `lamp_farm` climb/roots (not shop/smith/tavern) |
| Territory | Roots use **mass** (`root_mass_00` + crate stack); no fake barn enclosure |
| Composition | Three verbs; satellites \|d\|≤3; rug under hall talk |
| Ensemble | Primary hall + secondary climb/roots + open mid aisle ≥30% |
| Interact-ready | South stands at hall/climb/roots; door 9–12 clear ≥2 tiles |
| Corridor | South door → axis clear; climb west, roots east of aisle |
| Profile-wire | Paths use dedicated root/peg props + shared crates/lamps; scene `profile_id` = `c28_giant_tree` |
| Bleed | No outdoor grass furniture |

## 禁止偷懒

1. 禁止做成 C27 猎人卧铺/猎具屋  
2. 禁止堵死南门 `tx 9–12`  
3. 禁止只有 InfoPanel、无厅/梯/根三簇  
4. 禁止改别人 profile / 整文件重写 `interior_profiles.gd`  
5. 禁止棋盘格地板 / 整屋脏橙洗色  
6. 禁止未写本 MD 声称 DONE  

## User test (请自行在 Godot 测)

1. `forest_deep` → 巨树旁 「进入巨树洞」  
2. 南门 / TopBar 返回深林  
3. 通廊可并排走；根桌南、根宝匣南可站交互  
4. 守树人在厅↔梯↔根之间走动  
