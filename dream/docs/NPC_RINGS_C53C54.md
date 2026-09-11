# NPC Rings — C53 工作环 · C54 生活态

**Status:** DONE (Wave F NpcRing) 2026-09-11  
**Package:** occupational work loops + private life states  
**Owns:** `scripts/npc/**`, this doc  
**Hook:** thin mount in `village_square_controller.gd`, `market_street_controller.gd`, `farmland_controller.gd`  
**Does not:** rewrite outdoor assemblers, touch CivicTour / TransitDive / WorldSys files, Autoload every scene

---

## Delivered

| ID | Intent | Shipped |
| --- | --- | --- |
| C53 | ≥3 职业工作环 | **sow / smith / stall / cook** (4 wired; fish catalog id reserved) |
| C54 | ≥3 生活态 | **eat / sleep / read / laundry / idle_sit** (5 wired) |

### Work rings (C53) — runnable anchors

| id | Title | Outdoor demo | Indoor ref |
| --- | --- | --- | --- |
| sow | 播种环 | square 南田埂 · farmland 田垄 · market 南凹口 | — |
| smith | 打铁环 | square 东向市场口 · market 铁匠铺门脚 | `c04_smith` forge / anvil_quench / wait |
| stall | 摆货环 | square 东货箱 · market 北街摊面 | — |
| cook | 烹饪环 | square 西宅向 · market 酒馆翼 | `c01_home` kitchen / hearth_talk |

### Life states (C54) — runnable anchors

| id | Title | Outdoor demo | Indoor ref (C02+) |
| --- | --- | --- | --- |
| eat | 用餐 | square 井南餐点 · market 街心 | `c02_farmer` dining · `c01_home` hearth_talk |
| sleep | 睡眠 | square 东宅前 · market 西廊 | `c02_elder` / `c02_farmer` / `c01_home` sleep |
| read | 阅读 | square 长椅 · market 南步道 | `c02_elder` tea（摇椅） |
| laundry | 洗衣 | square 井↔桶↔椅 · market 西街 | `c49` yard `line`（室外示意） |
| idle_sit | 闲坐 | square / market 长椅短环 | `c02_elder` tea |

### C02 thin profile notes (additive only)

- `c02_elder` — desc + comments: tea = read/idle_sit, sleep = sleep  
- `c02_farmer` — desc + comments: dining = eat, sleep = sleep  

---

## API

`scripts/npc/npc_routine_rings.gd` — `class_name NpcRoutineRings` (RefCounted catalog)

```gdscript
NpcRoutineRings.work_demo_waypoints(host_key)  # ≥3 rings w/ Vector2 routes
NpcRoutineRings.life_demo_states(host_key)     # ≥3 life states w/ routes
# host_key: "square" | "market" | "farmland"
```

`scripts/npc/npc_routine_demo.gd` — `class_name NpcRoutineDemo` (Node, **not** Autoload)

```gdscript
NpcRoutineDemo.attach_to(host: Node2D, top_bar: Control = null, key := "square") -> NpcRoutineDemo
demo.cycle_work_ring()   # K
demo.cycle_life_state()  # L
```

Signals: `ring_changed(kind, id, title)` where `kind` is `"work"` | `"life"`.

---

## How to test (用户本机 Godot QA)

1. Open **村庄广场** (`village_square.tscn`).
2. TopBar:
   - **工作:…** — cycle C53 work rings (K)
   - **生活:…** — cycle C54 life states (L)
3. Confirm a **NpcRingDemoActor** walks the highlighted loop; status label top-left updates; InfoPanel shows ring/state text (**no「占位」**).
4. Open **商业街** (`market_street.tscn`) — same TopBar / K / L; smith door-feet + stall loops visible.
5. Optional: **农田** (`farmland.tscn`) — sow loop on field waypoints.
6. Optional indoor: enter **老人宅 / 农家宅** — existing `via_clusters` patrol covers eat/sleep/read stands.

Keys shared with Env-H on square: **N/R** = day/weather; **K/L** = NPC rings; **G** = grid.

---

## Files

| Path | Role |
| --- | --- |
| `scripts/npc/npc_routine_rings.gd` | C53/C54 catalog + host waypoints |
| `scripts/npc/npc_routine_demo.gd` | Demo node + TopBar + K/L |
| `scripts/areas/village_square_controller.gd` | Thin `attach_to` (square) |
| `scripts/areas/market_street_controller.gd` | Thin `attach_to` (market) |
| `scripts/areas/farmland_controller.gd` | Thin `attach_to` (farmland sow) |
| `scripts/interiors/interior_profiles.gd` | Additive C02 elder/farmer life comments |
| `docs/NPC_RINGS_C53C54.md` | This package doc |

---

## Desk acceptance

| Gate | Criterion | Result |
| --- | --- | --- |
| C53 count | ≥3 occupational loops wired with real waypoints | **PASS** (sow, smith, stall, cook) |
| C54 count | ≥3 life states wired with real waypoints | **PASS** (eat, sleep, read, laundry, idle_sit) |
| Mount | Env-H-style Node + TopBar + keys | **PASS** (square + market + farmland) |
| Actor | PatrolActor walk frames (not slide-only) | **PASS** |
| Strings | No public「占位」 | **PASS** |
| Scope | No assembler rewrite; no CivicTour/TransitDive/WorldSys edits | **PASS** |
| Indoor | C02 via_stands documented / additive ≤2 profiles | **PASS** (elder + farmer) |

**Desk verdict: PASS**

---

## 禁止偷懒

1. 禁止只写 MD 不接线 actor/route  
2. 禁止整文件重写 outdoor assembler  
3. 禁止工作环/生活态文案残留「占位」  
4. 禁止只用 Tween 位移无 PatrolActor 走路帧  
5. 禁止改 CivicTour / TransitDive / WorldSys 文件  
6. 禁止把 NPC UI 做成独立弹层堆控件（仅 TopBar 两按钮 + 键位 + 状态 Label）  
