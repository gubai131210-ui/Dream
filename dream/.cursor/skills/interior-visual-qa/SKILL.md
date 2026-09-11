---
name: interior-visual-qa
description: >-
  Post-change visual acceptance for Dream interiors/props: real-world sense,
  peer games, scene-fit variants, multi-view (H/V/corners), style/palette/light,
  splice vs joiners, filename≠pixels, and size/scale. Use AFTER finishing any
  interior/prop/fence/lamp/furniture edit, when reviewing screenshots, or when
  the user mentions 验收, 成果图, 素材合适, 拼接, 多视角, 风格, 名称不符, visual QA,
  interior QA. If the same issue fails ≥2 fix rounds, escalate to metrics + new
  joiner assets (do not keep splicing).
---

# Interior visual QA (Dream)

**Run this after every interior/asset delivery** before telling the user “done”.  
Locks: `docs/INTERIOR_TERRITORY.md`, `docs/INTERIOR_WAVE_C.md`, `docs/INTERIOR_FURNITURE_COHESION.md`, `docs/INTERIOR_COMPOSITION.md`, `.cursor/skills/interior-territory-craft/`.  
Industry anchors: [SLYNYRD PB3](https://www.slynyrd.com/blog/2018/3/14/pixelblog-3-graphical-projections-1) (one projection), [PB21](https://www.slynyrd.com/blog/2019/9/18/pixelblog-21-top-down-objects) (man-made geometry), [PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) (furniture as sets), Pixnote (shared palette / light / outline / grid).

## Output (mandatory)

```
Interior Visual QA: PASS | FAIL
- Reality: …
- Peer games: …
- Scene-fit: …
- Multi-view: …
- Style: …
- Splice/join: …
- Name≠pixels: …
- Size/scale: …
Escalation: none | metrics | new joiners
Blockers: …
```

**FAIL ⇒ fix or escalate; do not ship “大概可以”.** User Godot-tests; agent still must Read PNGs / screenshots.

## Checklist (short)

| # | Gate | Pass if |
| --- | --- | --- |
| 1 | **Reality** | Zone reads as that place (coop=pen, barn=stall+aisle+mass, shop=counter axis). Enclosure/mass before prop count. |
| 2 | **Peer games** | Matches Stardew/RPG Maker / Farming-101 silhouettes; cite **1** peer ref or screenshot (web OK). Not a clutter dump. |
| 3 | **Scene-fit** | Function OK **and** product OK (lamp matrix in WAVE_C). 功能对 ≠ 产品对. |
| 4 | **Multi-view** | H/V = same fence family; corners are **dedicated** L-joiners; no ladder-vs-picket mix. |
| 5 | **Style** | One 3/4 projection; one light corner (TL); same outline weight; wood ramp shared; no AA-density collage. |
| 6 | **Splice** | Continuous runs (32px tiles, step=1). Hard butts / diagonal fillers / orphan rails = FAIL. |
| 7 | **Name≠pixels** | Filename matches visible object (`roost`≠fence, `lamp_indoor`≠barn lantern). |
| 8 | **Size/scale** | Family heights proportional (stool < table apron; bar stool taller). Tile props ≈32 footprint or documented scale. |

## Screenshot protocol

1. Read user/Godot screenshot with **Read** (images).  
2. Score each gate; cite visible evidence in one short clause.  
3. Prefer side-by-side `_diag_*` rows when available.

## Escalation (after ≥2 failed fix rounds on the same gate)

1. **Metrics** — run `.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py` (bbox height, palette L2 on family). Attach numbers to FAIL.  
2. **Joiners** — if corners/edges still look spliced: **draw new** `*_corner_*` / gate / connector sheets; do **not** keep rotating/scaling/inpainting mismatched edges.  
3. **Web** — search peer refs (Stardew coop, SLYNYRD PB35) before inventing a third style; skip = FAIL peer gate.  
4. Stop thrashing solo gens; author a **set sheet** then slice.

## 禁止偷懒

- 禁止只看文案/profile、不 Read 成果图/PNG  
- 禁止家用灯进仓/店/铺/酒馆  
- 禁止 H/V 两套设计或用四角硬拼  
- 禁止文件名对、像素错  
- 禁止同一问题第三次“再调调”而不升级 metrics/新连接件  
- 禁止只缩放/调色/旋转/局部 inpaint 冒充成套或连接件  
- 禁止不查 peer / SLYNYRD 就开第三套风格  

## Related

- Craft: `interior-territory-craft`, `painting-asset-craft`  
- Metrics: `.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py`  
