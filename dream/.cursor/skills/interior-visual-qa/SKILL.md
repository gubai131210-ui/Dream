---
name: interior-visual-qa
description: >-
  Post-change visual acceptance for Dream interiors/props. Covers reality, peer,
  scene-fit, territory, composition, ensemble (整体感), interact-ready (承接人物/
  交互), multi-view, style, splice, Y-sort, corridor, craft, set-complete, bleed,
  FX, name≠pixels, size, profile-wire. Use AFTER any interior/prop edit,
  screenshot review, or when user mentions 验收, 整体感, 布局, 交互, 人物, 承接,
  visual QA. ≥2 fails on same gate → escalate (metrics → joiners → web → set sheet).
---

# Interior visual QA (Dream)

**Mandatory after every interior/asset delivery** before “done”.  
Locks: `INTERIOR_TERRITORY`, `INTERIOR_WAVE_C`, `INTERIOR_FURNITURE_COHESION`, `INTERIOR_COMPOSITION`, `INTERIOR_DIAGNOSIS`, `INTERIOR_ROOM_BRIEFS`, `SCALE.md`, `interior-territory-craft`.  
Anchors: [SLYNYRD PB3/PB21/PB35](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) · [RM interiors](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) · readability (silhouette / value / 3s).

## Output (mandatory)

```
Interior Visual QA: PASS | FAIL
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none | metrics | new joiners | set sheet | re-layout
Blockers: …
```

**FAIL ⇒ fix or escalate.** User Godot-tests; agent must **Read** PNGs / screenshots (not profiles alone).  
**“道具都放下了” ≠ PASS** — Ensemble / Interact-ready 不过就重排，别加 junk props。

## Gates (short)

### Place

| # | Gate | Pass if |
| --- | --- | --- |
| 1 | **Reality** | Reads as that place in ≤3s. InfoPanel text ≠ spatial grammar. |
| 2 | **Peer** | Cite **1** peer silhouette (tiny lamp-only may reuse last cite). |
| 3 | **Scene-fit** | Function **and** product OK (WAVE_C lamps). 功能对 ≠ 产品对. |
| 4 | **Territory** | **boundary → mass → count**. Coop/barn enclosure+corners; shops have stock mass. |
| 5 | **Composition** | One cluster = one verb; anchor+satellites (|d|≤3); face/align; rug under talk/dine; `actor.route` ≥2 anchors; animals at related clusters. |
| 6 | **Ensemble** | Whole room = **one intentional composition**: clear primary anchor, secondary zones, readable **negative space**. Not wall-ring dump, not even scatter, not “filled until busy”. Hierarchy: eye hits hearth/counter/pen first. |
| 7 | **Interact-ready** | Layout can absorb player + NPCs + future hotspots **without re-gutting**: ≥1 approach tile at each use-point (bed/counter/chest/shelf/forge/nest); staff vs customer sides kept; patrol lane free; prompt air above targets; density leaves headroom for 1 player + ≥1 NPC side-by-side on main path. |

### Art

| # | Gate | Pass if |
| --- | --- | --- |
| 8 | **Style** | One 3/4; TL light; shared outline/wood ramp. |
| 9 | **Craft** | Not flat PIL; spot metrics + `qa_interior_prop_quality.py` if doubt. |
| 10 | **Set-complete** | H+V+4 corners / table+matching stools present. |
| 11 | **Bleed** | No outdoor grass on indoor furniture. |
| 12 | **FX** | Sequence frames on correct base; don’t cover south exit / prompts. |

### Assembly

| # | Gate | Pass if |
| --- | --- | --- |
| 13 | **Multi-view** | H/V same family; dedicated L-corners. |
| 14 | **Splice** | Continuous runs (32px, step=1); hard butts → new joiners. |
| 15 | **Y-sort** | Shared Y-sort parent; feet origin; no mid-stride eat / z-fight. |
| 16 | **Corridor** | Door→axis ≥2 tiles; south door clear; stall aisles readable. |

### Meta

| # | Gate | Pass if |
| --- | --- | --- |
| 17 | **Name≠pixels** | Filename = visible object. |
| 18 | **Size** | Family proportions; ≈BASE_TILE=32; no fake 64h normalize. |
| 19 | **Profile-wire** | Touched profile paths exist; lamp/enclosure/mass match docs. |

## Out of this sheet (Godot playtest)

Collider pixel-fit / diegetic light / prompt polish — user QA. Escalate if shot shows blocked walk or broken occlusion.

## Screenshot protocol

1. Read room shot (+ `_diag_*` if any).  
2. **3s ensemble test:** room type? primary anchor? walk path? where would an NPC stand to work / a player press interact?  
3. Score every gate in one evidence clause.  
4. If Ensemble or Interact-ready FAIL → prefer **re-layout** over more props.

## Escalation (≥2 fails on same gate)

1. **Metrics** — skill script + `tools/qa_interior_prop_quality.py`.  
2. **Joiners** — new corners/connectors (ban tint/rotate splice).  
3. **Web** — peer + SLYNYRD / RM interior refs.  
4. **Set sheet** — one atlas then slice.  
5. **Re-layout** — Ensemble / Interact-ready / Composition FAIL after art PASS → rewrite `clusters`/`enclosures`/`rails`/`actor.route`, do **not** sprinkle more props.

## 禁止偷懒

- 禁止不 Read 成果图/PNG  
- 禁止「放下就算」——整体无主次/无负空间仍报 PASS  
- 禁止塞满到无法并排走人或无法站在柜台前交互  
- 禁止无 use-point 站位、NPC 只绕空地矩形  
- 禁止家用灯跨场景；无四角 enclosure；H/V 两套设计  
- 禁止文件名对像素错；缺成员宣称成套  
- 禁止缩放/调色/旋转/inpaint 冒充连接件  
- 禁止同一 gate 第三次“再调调”不升级  
- 禁止不查 peer 开第三套风格；用 InfoPanel 补空间逻辑  
- 禁止饭桌自带椅再摆凳；室外草皮进室内；只改 MD 不改资产  

## Related

- Craft: `interior-territory-craft`, `painting-asset-craft`  
- Metrics: `.cursor/skills/interior-visual-qa/scripts/qa_interior_visual.py`  
- Prop quality: `tools/qa_interior_prop_quality.py`  
- Composition lock: `docs/INTERIOR_COMPOSITION.md`  
