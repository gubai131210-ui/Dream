# Interior Wave D — Ensemble · Interact-ready · Shell polish

**Status:** LANDED 2026-09-11 (code) — user Godot screenshot QA next  
**Next focus:** [`PHASE5_WAVE_A2.md`](./PHASE5_WAVE_A2.md) — Stall/Fish/Mine/Well/Lighthouse/Forest/Env（**不**继续抛光 C01–C04）  
**After:** Wave C (scene-fit + territory) SHIPPED  
**Locks:** [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md), [`research/INTERIOR_NEXT_LAYER_RESEARCH.md`](./research/INTERIOR_NEXT_LAYER_RESEARCH.md)  
**Skills:** [`interior-visual-qa`](../.cursor/skills/interior-visual-qa/SKILL.md) (mandatory accept), [`interior-territory-craft`](../.cursor/skills/interior-territory-craft/SKILL.md), [`painting-asset-craft`](../.cursor/skills/painting-asset-craft/SKILL.md)

## Goal

Wave C 把区界/灯矩阵铺全后，Wave D 做两件事：

1. **整体感 + 交互承接** — 全 Wave A profile 按 Ensemble / Interact-ready 重验；FAIL 则 **re-layout**（改 clusters/route/enclosures），不撒 junk。  
2. **壳层抛光地基**（NEXT_LAYER §4，本波只做可落地子集）  
   - Y-sort / feet origin 审计与修复  
   - `door_frame` 成套（非可选）  
   - 光源绑在真实灯/炉锚点  
   - 世界锚点 **最近热点接近提示**（为后续对话/商店留承接，不做玩法树）

**不做本波：** 对话树 / 制作 / 商店经济 / 全新房间包。

## Multi-agent roles

| Agent | Owns | Done when |
| --- | --- | --- |
| **Audit** | Score every Wave A profile vs visual-qa Place gates 5–7 + Corridor | Matrix in this doc: PASS/FAIL + blockers |
| **Layout** | Re-layout FAIL rooms in `interior_profiles.gd` | Approach tiles + ≥30% open + routes hit workpoints |
| **Shell** | `interior_craft.gd` Y-sort/feet, door_frame required, light anchors | No fake z_index; door kit always; lights on props |
| **Prompt** | Nearest-only world prompt on `InteractableHotspot` | Cue above target; not TopBar-only; clears south exit |
| **QA** | Run metrics + skill report; subagent review | Ship only if Visual QA PASS or blockers listed |

## Profile checklist (Audit fills)

Audit date: 2026-09-11. Method: profile tile math (`room_w*room_h` vs cluster bbox mass), door-strip occupancy, use-point cardinal approaches, `via_clusters` → craft stop at `anchor+(0,1)`. Open-floor estimate = 1 − Σ(cluster bbox) / (room_w·room_h); all rooms ≥83% by bbox (PASS threshold ≥30%).

| Profile | Ensemble | Interact-ready | Corridor | Blockers |
| --- | --- | --- | --- | --- |
| `c01_home` | PASS | FAIL | FAIL | `hearth_talk` table/stools on door mid (tx15–18); sleep actor stop on bed |
| `c02_elder` | PASS | PASS | PASS | — (sleep stop on bed is minor; bed still has S approach) |
| `c02_farmer` | PASS | FAIL | FAIL | `dining` on door mid; mudroom OK; dining/sleep actor stops on props |
| `c02_merchant` | PASS | PASS | PASS | — (`via` ledger+cargo hits work; sleep private) |
| `c02_blacksmith_home` | PASS | FAIL | FAIL | `living` on door mid; all three actor stops on prop tiles |
| `c03_barn` | PASS | SOFT | FAIL | `aisle_feed` grain@18,7 pinches door aisle; stall_w actor stop in hay |
| `c03_coop` | SOFT | SOFT | FAIL | Full-pen OK as territory; `feed` trough on door mid; north fence crosses axis |
| `c04_grocery` | PASS | FAIL | FAIL | Customer-side baskets block door→counter; shelf actor stops on shelves |
| `c04_smith` | PASS | PASS | SOFT | Wait stool grazes door band; forge actor stop on forge (approach S still free) |
| `c04_tavern` | SOFT | FAIL | FAIL | `party_a` on door mid steals focus; bar/hearth actor stops blocked |

## Shell changes

- **Feet origin (Y-sort):** furniture + fence segments share `PROP_FOOT_NUDGE` / `_feet_sprite_offset` — `offset_y = -tex_height * scale * 0.5 + 4`. Hotspot at tile ground; no per-prop `z_index` depth hacks (Foundation stays low; `InteriorWorld.y_sort_enabled`).
- **door_frame kit:** required — always spawn both door-side frames; loud `push_warning` if `door_frame_00.png` missing/unloadable (asset present under `assets/sprites/interior/tiles/`).
- **Lights:** room PointLights stay profile `lights[]`-anchored only (plus diegetic FX fire/forge); no unbound flood.

## Acceptance

```
Interior Visual QA: (per touched room)
… Ensemble / Interact-ready must PASS
Escalation: re-layout if layout FAIL after art PASS
```

User Godot-tests screenshots; agent still Reads PNGs / profiles.

## Audit findings

**Auditor:** Wave D Audit · 2026-09-11  
**Scope:** All Wave A profiles in `interior_profiles.gd` vs visual-qa Place gates **Ensemble / Interact-ready** + Assembly **Corridor**.  
**Not scored here:** Style/Craft/Y-sort/door_frame/lights (Shell) · world prompt (Prompt).  
**Rule reminders:** “props placed” ≠ Ensemble PASS · ≥1 approach tile at use-points · ≥2-tile main path · ≥30% open floor (bbox estimate) · `via_clusters` must hit work points · no dialogue/shop invent.

### Score summary

| Verdict | Profiles |
| --- | --- |
| All PASS | `c02_elder`, `c02_merchant` |
| SOFT only (no FAIL) | `c04_smith` (Corridor SOFT) |
| ≥1 FAIL → Layout | `c01_home`, `c02_farmer`, `c02_blacksmith_home`, `c03_barn`, `c03_coop`, `c04_grocery`, `c04_tavern` |

Open-floor bbox estimates (all PASS ≥30%): home 90% · elder 89% · farmer 91% · merchant 92% · smith-home 90% · barn 87% · coop 83% · grocery 84% · smith 90% · tavern 84%.

---

### FAIL prescriptions (Layout agent — edit clusters only; do not sprinkle junk)

#### `c01_home` — Interact FAIL · Corridor FAIL

**Blockers:** `hearth_talk` anchor `(16,6)` puts fireplace+table+south stool on door strip tx **15–18**. Door→axis not ≥2 free tiles. Sleep `via` stop `anchor+(0,1)` lands on bed.

**Re-layout:**
1. Move `hearth_talk` off mid-axis → anchor **`(11,6)`** or **`(21,6)`** (prefer west of door if kitchen stays west: **`(12,6)`**).
2. Keep door columns **tx 15–18** clear from **ty 10 → room_h−2** (no stools/table on those tiles).
3. Leave **≥1 free tile south of dining table** and **≥1 west of stove** as use approaches; rug ox follow new hearth anchor (~hearth table).
4. Shift `sleep` anchor so `anchor+(0,1)` is a free stand tile (e.g. bed at `dy=2`, stop at foot, or move bed to `(28,12)` with dresser north).
5. Keep `via_clusters`: kitchen → hearth_talk → sleep (work order OK).

#### `c02_farmer` — Interact FAIL · Corridor FAIL

**Blockers:** `dining` `(14,7)` sits on door mid **13–16**; dining/sleep actor stops on table/bed.

**Re-layout:**
1. Move `dining` to **`(10,7)`** (west of door) or **`(18,7)`** (east); stools stay |d|≤2 around table.
2. Clear door strip **tx 13–16**, **ty 9 → door**.
3. Keep `mudroom` SW (near door west is OK) but ensure **≥2-tile** walk from door past mudroom to dining without crossing sack pile — if mudroom sacks spill to tx≥12, nudge mudroom anchor to **`(4,13)`**.
4. Sleep: free foot-of-bed stand for actor (`anchor+(0,1)` empty) — e.g. bed `dy=2` or stop cluster south of dresser.
5. Rug ox/oy track dining; `via` mudroom → dining → sleep unchanged.

#### `c02_blacksmith_home` — Interact FAIL · Corridor FAIL

**Blockers:** `living` `(12,8)` on door **12–15**; actor stops on anvil, table, and bed (all three blocked).

**Re-layout:**
1. Move `living` to **`(16,8)`** or **`(9,7)`** off door mid; leave **tx 12–15** open south of living.
2. `home_tools`: keep anvil+barrel west; set actor stand south of anvil — e.g. anvil at `(0,0)`, barrel `(2,1)`, leave `(6,9)` / `anchor+(0,2)` free; or bump `home_tools` anchor to `(6,6)` so `+(0,1)=(6,7)` is clear of anvil@`(6,8)`.
3. Living stools: only E/W of table (drop south stool if it lands on door band); **≥1 south approach** to table free.
4. Sleep: same foot-stand rule as homes.
5. `via` home_tools → living → sleep unchanged.

#### `c03_barn` — Corridor FAIL · Interact SOFT

**Blockers:** `aisle_feed` grain_stack at world `(18,7)` + sacks pinch door aisle **16–19**. West stall actor stop hits hay. Stall gaps `[11,7–10]` / `[24,7–10]` are correct — keep them.

**Re-layout:**
1. Move grain_stack to **north wall off mid**: e.g. aisle anchor `(18,11)` with grain at **`(0,-6)` → (18,5)** only if still clear of door, **or** better **`(14,4)` / `(22,4)`** as satellite north corners (split mass OK).
2. Keep **center aisle tx 16–19 fully clear** ty 5→20 except intentional feed sacks **beside** aisle (dx ±3), not on mid.
3. Troughs stay aisle-facing through existing enclosure gaps; leave **≥1 approach tile in aisle** at each gap (e.g. `(12,8)` west gap, `(23,8)` east gap).
4. `stall_w` actor: move hay so `anchor+(0,1)` free inside pen, or set via stop conceptually by shifting stall_w anchor to trough approach `(8,9)` with hay behind.
5. Do **not** remove four-corner stall enclosures (Wave C lock).

#### `c03_coop` — Corridor FAIL · Ensemble SOFT · Interact SOFT

**Blockers:** Full-room pen is intentional territory (Ensemble SOFT, not auto-FAIL). `feed` trough@`(12,7)` + sacks sit on door mid **10–13**. North pen rail crosses door columns (OK if south gaps work — gaps `[10–13,13]` keep).

**Re-layout:**
1. Shift `feed` off axis → anchor **`(8,8)`** (west-center) or **`(15,8)`** (east of door); trough+sacks+barrel stay |d|≤3.
2. Keep **door strip tx 10–13** walkable from south gaps **north to at least ty 5** (path to nests/roost).
3. `nests` stay west wall; leave **≥1 tile east of each nest** (tx 5) free for player gather approach.
4. `roost` east; free actor stand west of roost (avoid landing on roost sprite).
5. Keep pen enclosure + south gaps; do not shrink to wall-ring props without rails.

#### `c04_grocery` — Interact FAIL · Corridor FAIL

**Blockers:** Baskets at counter `(-2,2)/(2,2)/(0,3)` sit on **customer south** between door and counter — blocks door→counter and customer stand. Shelf `via` stops land on shelf sprites. Staff/customer split otherwise correct (counter faces south).

**Re-layout:**
1. Relocate baskets to **sides/staff**: e.g. `(-3,0)`, `(3,0)`, `(-2,-1)` (north/staff) — **no basket on dy≥2 south of counter**.
2. Guarantee **≥1 customer approach** at `(14,10)` or `(15,10)` **and** clear door strip **tx 13–16** from door up to counter south face.
3. Staff stand north of counter: keep `via` counter stop free — counter anchor `(14,9)` → stop `(14,10)` is currently south (customer). Craft uses `anchor+(0,1)` = south. For staff-behind-counter, either move counter anchor to staff tile north of prop, or put counter member at `dy=+1` so anchor is staff north — **prefer**: counter sprite at `(0,1)`, cluster anchor `(14,8)` so actor stop `(14,9)` is staff behind counter; customer approaches `(14,11)`.
4. Shelf patrol: offset shelf anchors so `+(0,1)` is aisle (e.g. shelf_w anchor `(6,7)` with shelves at dx`-2`), not on shelf art.
5. Keep W/E shelf mass; rug under customer stop at counter south.

#### `c04_tavern` — Interact FAIL · Corridor FAIL · Ensemble SOFT

**Blockers:** `party_a` `(16,8)` on door mid steals 3s focus from bar/hearth. South stool of party_a on door band. Bar/hearth actor stops on kegs/fireplace.

**Re-layout:**
1. Move `party_a` to **`(12,9)`** (west of corridor) or **`(12,10)`**; `party_b` to **`(24,9)`** or **`(23,10)`** — leave **tx 15–18 clear** ty 6→door.
2. Primary read: bar (west) + hearth (east) should win 3s test; parties are secondary — do not center a table on door axis.
3. Bar: stools stay on customer (east) side of bar; leave bartender stand **west/behind** bar free — shift kegs so `bar` `anchor+(0,1)` is walkable service tile, or anchor bar at service point with bar sprite `dx=+1`.
4. Hearth: stool SW of fireplace; actor stop not on fireplace footprint (e.g. hearth anchor `(28,8)` with fireplace `(0,-2)`).
5. Rug under party or door stop — not blocking south exit. `via` bar → party_a → party_b → hearth OK once anchors are walkable.

---

### PASS / SOFT notes (no mandatory re-layout)

| Profile | Note |
| --- | --- |
| `c02_elder` | Tea↔sleep via OK; corridor clear; optional: nudge sleep so stop isn’t on mattress. |
| `c02_merchant` | Ledger+cargo work route OK; sleep private (not in via) OK; cargo mass intentional. |
| `c04_smith` | Corridor SOFT only — pull wait **1 tile east** (`(17,13)`) and/or drop stool off door tx12–15; forge S approach already free. |

### Layout handoff checklist

- [x] Edit only FAIL (and smith SOFT) profiles in `interior_profiles.gd`
- [x] Re-check door strip clear ≥2 tiles · use-point approach ≥1 · open bbox ≥30% · via stops on empty tiles at work clusters
- [x] No new junk props · no Wave C enclosure/lamp matrix rewrite
- [ ] QA re-scores Ensemble / Interact-ready / Corridor after layout

## Layout changes

Wave D Layout · 2026-09-11 — followed Audit FAIL prescriptions; clusters/`via_stands`/`rug`/`fx`/`lights` only. Enclosures + lamp *assets* unchanged.

| Profile | Change | Why |
| --- | --- | --- |
| `c01_home` | `hearth_talk` → `(11,6)`; rug/fx; `via_stands` kitchen/hearth/sleep | Clear door 15–18; NPC not on table/bed |
| `c02_farmer` | `dining` → `(10,7)`; mudroom sacks tighter; `via_stands` | Dining off door mid; approach stands free |
| `c02_blacksmith_home` | `living` → `(9,8)`; tools west; `via_stands` | Living off door 12–15 |
| `c03_barn` | `aisle_feed` north `(18,4)`; sacks **dx±3**; gap stands | Mid-aisle clear; trough approaches |
| `c03_coop` | `feed` → `(7,6)` off axis; nests \|d\|≤2; roost tighter; chickens + `via_stands` | Door strip + nest approach; pen/gaps kept |
| `c04_grocery` | baskets **staff/sides**; counter face `dy=1`; shelf aisle anchors | Customer approach + staff behind counter |
| `c04_smith` | forge/anvil west; `wait` `(20,12)`; `via_stands` | Corridor SOFT → clear; stool approach |
| `c04_tavern` | `party_a` `(12,7)` / `party_b` east; hearth crates tight; `via_stands` | Door 15–18 free; bar/hearth primary read |

Unchanged (Audit PASS): `c02_elder`, `c02_merchant`.

## 禁止偷懒

1. 禁止「道具放下」就算 Ensemble PASS  
2. 禁止塞满导致无法并排玩家+NPC / 无法站在使用点前  
3. 禁止 NPC 只绕空地、不经工作点  
4. 禁止用抬高 `z_index` 冒充 Y-sort  
5. 禁止跳过 door_frame / 通廊未清就开对话玩法  
6. 禁止全屋堆 PointLight 不绑真实光源  
7. 禁止只改 TopBar、物体旁无接近提示  
8. 禁止抽查一间房代表全部 profile  
9. 禁止只改 MD 不改 `interior_profiles.gd` / `interior_craft.gd`  
10. 禁止 Wave D 借口重做 Wave C 灯矩阵 / 无四角 enclosure  
11. 禁止移动 PNG 丢 `.import`  
12. 禁止不跑 `interior-visual-qa` 就声称完成  
13. 禁止 Audit 只填 PASS 不写 FAIL 房的具体挪簇处方  
14. 禁止把 enclosure 内动物活动空间算成“塞满”而误杀 Ensemble（鸡舍/畜栏以通廊+使用点为准）  

## Prompt changes

Wave D proximity cue (no dialogue trees / no TopBar-only hint):

| Piece | Behavior |
| --- | --- |
| `InteractableHotspot` | `body_entered` / `body_exited` track `CharacterBody2D` or group `"player"`. Floating Label `"互动"` sits ~16px above the Visual sprite top. Mouse hover highlight + click `activated` unchanged. |
| `InteriorRoomController` | Each frame collects body-near (or camera-near if no player yet) hotspots under `InteriorWorld`, shows the prompt on **only the nearest**, clears the previous. |
| South exit | `Portal_Return` stays its own labeled Area2D; prompts are ephemeral + nearest-only so they never permanently cover the exit. |
| TopBar `Hint` | Still shows room title/hint — **not** the interaction affordance. |

**Nearest selection:** `InteriorRoomController._update_nearest_proximity_prompt()` → resolve anchor (`player` group / first `CharacterBody2D` under world, else `CameraController.global_position`) → candidates = `has_player_overlap()` when a player body exists, else `is_point_in_reach(anchor)` → min `distance_squared_to(anchor)` wins → `set_proximity_prompt_shown(true)` on winner only.

**Craft note:** `_spawn_actor` default stand = `anchor+(0,2)`; profiles may override with `via_stands`. Feet formula unified; `door_frame` required.

## Post-layout checklist (profile estimate — **Godot Visual QA pending**)

| Profile | Ensemble | Interact-ready | Corridor | Note |
| --- | --- | --- | --- | --- |
| all Wave A | pending shot | pending shot | pending shot | Metrics script PASS; user confirms Ensemble/Interact in-engine |
