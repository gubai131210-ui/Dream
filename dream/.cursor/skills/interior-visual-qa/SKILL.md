---
name: interior-visual-qa
description: >-
  Post-change visual acceptance for Dream interiors/props. Covers reality, peer
  games, scene-fit, territory/composition, multi-view, style, splice/joiners,
  Y-sort/occlusion, walk corridors, craft density, set completeness, outdoor
  bleed, FX, filename≠pixels, size/scale, profile wiring. Use AFTER any
  interior/prop/fence/lamp/furniture edit, screenshot review, or when the user
  mentions 验收, 成果图, 素材合适, 拼接, 多视角, 风格, 遮挡, 通廊, visual QA.
  If the same gate fails ≥2 fix rounds, escalate (metrics → new joiners → web
  → set sheet); do not keep splicing/tinting.
---

# Interior visual QA (Dream)

**Mandatory after every interior/asset delivery** before “done”.  
Locks: `INTERIOR_TERRITORY`, `INTERIOR_WAVE_C`, `INTERIOR_FURNITURE_COHESION`, `INTERIOR_COMPOSITION`, `INTERIOR_DIAGNOSIS`, `SCALE.md`, `interior-territory-craft`.  
Anchors: [SLYNYRD PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1) · [PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects) · [PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) · readability (silhouette / value / 3s read).

## Output (mandatory)

```
Interior Visual QA: PASS | FAIL
Place: Reality | Peer | Scene-fit | Territory | Composition
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none | metrics | new joiners | set sheet
Blockers: …
```

**FAIL ⇒ fix or escalate.** User Godot-tests; agent must **Read** PNGs / screenshots (not profiles alone).

## Gates (short)

### Place

| # | Gate | Pass if |
| --- | --- | --- |
| 1 | **Reality** | Reads as that place in ≤3s (coop≠empty room with chickens). InfoPanel text ≠ spatial grammar. |
| 2 | **Peer** | Stardew / RM / farm-sim silhouette; cite **1** ref (web OK). |
| 3 | **Scene-fit** | Function **and** product OK (WAVE_C lamp matrix). 功能对 ≠ 产品对. |
| 4 | **Territory** | Order: **boundary → mass → count**. Coop/barn need enclosure+corners; shops need stock mass. |
| 5 | **Composition** | One cluster = one verb; anchor+satellites (|d|≤3); stools face table/hearth; rug under talk/dine; NPC route hits ≥2 anchors; animals at related clusters. |

### Art

| # | Gate | Pass if |
| --- | --- | --- |
| 6 | **Style** | One 3/4; TL light; shared outline/wood ramp; no AA-density collage. |
| 7 | **Craft** | Not flat PIL bars. Opaque unique colors roughly outdoor-class (metrics / DIAGNOSIS); silhouette readable at glance. |
| 8 | **Set-complete** | Family has all members (H+V+4 corners; table+matching stools). Missing corner/joiner = FAIL. |
| 9 | **Bleed** | No outdoor grass/tufts on indoor furniture; no outdoor bench-as-table leftovers. |
| 10 | **FX** | Fire/forge/water/mist use **sequence frames** where assets exist; FX sit on correct base prop, not floating orphan. |

### Assembly

| # | Gate | Pass if |
| --- | --- | --- |
| 11 | **Multi-view** | H/V = same fence family; corners = dedicated L-joiners (not H∩V butts). |
| 12 | **Splice** | Continuous runs (32px, step=1). Hard butts / diagonal fillers / orphan rails = FAIL → draw joiners. |
| 13 | **Y-sort** | Tall props don’t eat the player wrongly; no random z-fighting; wall trim / counters occlude as expected. |
| 14 | **Corridor** | Door→main axis ≥2 tiles clear; clusters don’t plug the south door; stall aisles readable. |

### Meta

| # | Gate | Pass if |
| --- | --- | --- |
| 15 | **Name≠pixels** | Filename = visible object (`roost`≠fence). |
| 16 | **Size** | Family proportions (stool < table; bar stool taller). Footprint ≈ BASE_TILE=32 or documented scale. Don’t normalize all to 64h. |
| 17 | **Profile-wire** | `interior_profiles.gd` paths exist on disk; lamp/enclosure/mass match WAVE_C / TERRITORY tables. |

## Screenshot protocol

1. Read Godot/user shot with **Read**.  
2. Score every gate in one short evidence clause.  
3. Prefer `_diag_*` family rows + room shot.  
4. Squint / 3s test: room type, walk path, main anchor still readable.

## Escalation (≥2 fails on same gate)

1. **Metrics** — `.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py` (+ `tools/qa_interior_prop_quality.py` if craft).  
2. **Joiners** — draw new `*_corner_*` / gate / connectors; ban rotate/scale/inpaint as “join”.  
3. **Web** — peer + SLYNYRD before a third style.  
4. **Set sheet** — one atlas, then slice; stop solo thrash gens.  
5. If layout FAIL after art PASS → fix `clusters`/`enclosures`/`rails`, not more props.

## 禁止偷懒

- 禁止不 Read 成果图/PNG  
- 禁止家用灯进仓/店/铺/酒馆；跨场景复用同一灯 PNG  
- 禁止只有直线隔栏、无四角 enclosure  
- 禁止 H/V 两套设计或硬拼角  
- 禁止文件名对、像素错；缺成员仍宣称成套  
- 禁止只缩放/调色/旋转/inpaint 冒充成套或连接件  
- 禁止第三次“再调调”同一 gate 而不升级  
- 禁止不查 peer/SLYNYRD 开第三套风格  
- 禁止均匀撒点充“满”；堵门；用 InfoPanel 补空间逻辑  
- 禁止饭桌自带椅子再摆独立凳；全员强制 64h  
- 禁止室外草皮凳进室内；扁平色块当成品  
- 禁止只改 MD/文案不改 profile/资产  

## Related

- Craft: `interior-territory-craft`, `painting-asset-craft`  
- Metrics: `.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py`  
- Prop quality: `tools/qa_interior_prop_quality.py`  
