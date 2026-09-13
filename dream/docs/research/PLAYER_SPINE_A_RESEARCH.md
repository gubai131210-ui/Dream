# Player Spine A research — spawn-on-map-change, collision/walkability, minimal inventory

**Date:** 2026-09-13  
**Status:** Phase0 **IMPLEMENTED** in repo (`SpawnRegistry` + `InventoryService` autoloads; `SceneRouter.change_to(..., spawn_id)`; apron +48y). See [`GOAL_SPINE_ABD.md`](../GOAL_SPINE_ABD.md).  
**Scope:** Phase 0 design for Dream player continuity across `SceneRouter` loads: arrival spawn points, 3/4-view collision + Y-sort feet, and a minimal cozy inventory (item id / stack / pickup).  
**Out of scope:** Full backpack UI polish, crafting recipes, shops economy, save serialization format (sketch only).

---

## 0. Dream repo snapshot (grep-backed — do not design blind)

| Piece | Exists? | Role today |
| --- | --- | --- |
| `SceneRouter` | Yes (`scripts/core/scene_router.gd`) | Path constants + `static change_to(tree, path)` → `tree.change_scene_to_file(path)`. **No spawn payload.** |
| `PlayerBootstrap` | Yes (autoload) | On `scene_changed`, spawn `PlayerActor` under `WorldSpawnUtil.resolve_ysort`, position via `_resolve_spawn`. |
| Spawn resolve | Partial | Prefers `Portal_Return` global pos + `(0, -40)`; else camera; else `(640, 480)`. **Ignores which door/portal you came from.** |
| `WorldSpawnUtil` | Yes | Hotspots, portal cues (`doorstep` / `arch` / `facade`), `make_portal` + `wire_portal_click` → `SceneRouter.change_to` with **only** `meta.scene_path`. Feet-anchored `attach_prop_sprite`. |
| `AreaCraft.make_portal` | Yes | Outdoor `Portal_*` Area2D; same `scene_path` meta pattern. |
| `InteractableHotspot` | Yes | `Area2D` for interactables; overlap + click; **not** solid collision. |
| Walkability | Yes | `AreaCraft.is_npc_walkable` (water / blocked footprint); `PlayerActor` uses **tile mask + axis-slide**, not `move_and_slide` vs StaticBody2D. |
| Feet / Y-sort | Partial | `PlayerActor.FOOT_CONTACT_Y = 0`; interiors `y_sort_enabled`; props feet-anchored. |
| Inventory (gameplay) | **No** | No `InventoryService` / item id / stack / pickup. “inventory” in docs/tools = **sprite/QA asset inventory**, not player bag. |
| Autoloads today | `MCPRuntime`, `PlayerBootstrap`, `TrainService` | No `SpawnRegistry` / `InventoryService`. |

**Gap in one line:** every portal knows *where to go*, almost none know *where you should appear* or *which exit marker to stand at*.

---

## 1. How Stardew / similar 2D top-downs handle warp spawn & door exits

### 1.1 Stardew Valley — map Warp is a 5-tuple (source → dest + tile)

Primary: [Modding:Maps — Warps & map positions](https://stardewvalleywiki.com/Modding:Maps)

| Mechanism | Behavior |
| --- | --- |
| Map property `Warp x y Location destX destY` | Stepping on source tile `(x,y)` loads location `Location` and places the player at `(destX, destY)`. Example: `6 20 Mountain 76 9`. |
| `DefaultWarpLocation x y` | Fallback arrival when warped **without** an explicit destination tile (debug warp, some events). |
| `TouchAction Warp Location x y` | Player-only step warp (same dest idea; no magic VFX). |
| `Action Warp Location x y` | Click/activate warp (doors, interact tiles). |
| `Action LockedDoorWarp …` | Same dest tuple + time window (+ optional friendship). |
| Interior `Doors` + `Action Door` | Door *animation/open* layer; warps still carry dest coordinates. |

**Steal for Dream:** a transition is never “scene path only” — it is always **`(to_scene, spawn_id | tile/world pos [, facing])`**. Bidirectional doors are *two* warps (A→B spawn at B’s door apron; B→A spawn at A’s door apron).

### 1.2 Stardew — location data default arrival

Primary: [Modding:Location data](https://stardewvalleywiki.com/Modding:Location_data)

- `DefaultArrivalTile` — recommended default when a warp omits a tile; without it, arrival often collapses toward `(0,0)`.
- Content Patcher `AddWarps` strings use the same `srcX srcY DestLocation destX destY` grammar.

### 1.3 Stardew — farm buildings / human door

Primary: [Modding:Buildings](https://stardewvalleywiki.com/Modding:Buildings)

- `HumanDoor` is the outdoor click tile into the interior.
- Player entry after entering a building is defined relative to the **first warp** in that interior’s warp list (wiki: typically **1 tile north** of that warp).

**Steal:** outdoor door marker ≠ spawn feet; spawn sits on a **clear walkable apron** just outside / inside the threshold so the player does not re-trigger the portal instantly.

### 1.4 Stardew — Warp Totems (named destination, fixed entry)

Primary: [Warp Totem](https://stardewvalleywiki.com/Warp_Totem)

- Consumables / obelisks teleport to a **named location’s fixed entry** (e.g. farm warp statue / beach / mountain), not “wherever you last stood.”
- Map property `WarpTotemEntry` (farm) documents the dedicated farm arrival for totems / Return Scepter ([Modding:Maps](https://stardewvalleywiki.com/Modding:Maps)).

**Steal:** rare fast-travel uses **named spawn ids** (`farm_statue`, `station_platform`), not free-form coordinates scattered in call sites.

### 1.5 Animal Crossing — station as travel verb (arrival ritual)

Primary context for transit (not tile warps): [Nookipedia — Train](https://nookipedia.com/wiki/Train) (see also Dream `TRAIN_SERVICE_RESEARCH.md`).

- Board at station → travel → arrive elsewhere; arrival is a **hub ritual**, not a mid-map dump.
- Dream already mirrors this with `TrainService` → `SceneRouter.change_to(dest)` after window ride — still needs a **destination spawn id** (e.g. `station_exit` / `hill_farm_platform`).

---

## 2. Collision patterns for 3/4 pixel games (Y-sort feet, Area2D vs StaticBody2D)

### 2.1 Godot object roles (official)

Primary: [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html), [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html), [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html), [CanvasItem.y_sort_enabled](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)

| Node | Use in cozy 3/4 |
| --- | --- |
| `CharacterBody2D` | Player / NPC movers. Top-down: `motion_mode = MOTION_MODE_FLOATING` when using `move_and_slide` (all hits are walls; no floor/ceiling). |
| `StaticBody2D` | Solid environment (walls, fence posts, furniture volume) that **blocks** `move_and_slide`. Does not move from physics. |
| `Area2D` | **Detection only** — portals, pickups, interact hotspots, hurtboxes. Does **not** replace solid walls. |
| Shared `y_sort_enabled` parent | Children with higher **Y** draw in front; only same `z_index` peers sort ([CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)). |

### 2.2 Feet = sort origin = collision contact

Industry + Godot forum consensus (aligns with Dream `FOOT_CONTACT_Y` / `attach_prop_sprite`):

1. Node origin at **ground contact (feet)**, not sprite center.
2. Sprite offset **up** so art sits above feet; collision capsule/rect sits on the **lower third** of the silhouette (Dream player: `28×20` at `(0, -10)`).
3. Tall props (trees, shelves): origin at trunk/base; canopy may overhang visually while footprint stays blocked.
4. Disable Y-sort on the character root so children share the root’s sort Y ([Godot forum Y-sort guidance](https://forum.godotengine.org/t/y-sorting-difficulties/135043)).

### 2.3 Two valid collision strategies (Dream already chose A)

| Strategy | How | When |
| --- | --- | --- |
| **A. Tile walkability mask** (current) | `AreaCraft.is_npc_walkable` + axis-slide; optional `blocked_mask` for footprints | Outdoor tile maps; matches Stardew Buildings impassable + Back walkable ([NPC_MOTION_COLLISION_RESEARCH.md](NPC_MOTION_COLLISION_RESEARCH.md)) |
| **B. Physics solids** | `StaticBody2D` walls + `CharacterBody2D.move_and_slide` | Interiors with freeform furniture hulls, or when tile grid is too coarse |

**Dream Phase 0 recommendation:** keep **A for outdoors**; for interiors, either extend `InteriorCraft` walk masks **or** add sparse `StaticBody2D` footprints under tall props — do **not** turn every `InteractableHotspot` into a StaticBody (hotspots must stay Area2D).

### 2.4 Layer split (suggested)

| Layer | Contents |
| --- | --- |
| 1 WorldSolid | StaticBody walls / tile blockers if used |
| 2 Player | `PlayerActor` |
| 3 Interact | `InteractableHotspot` / portals (mask includes Player) |
| 4 Pickup | world items Area2D |

Today everything sits on layer `1` — fine for Phase 0 mask walking; split before mixing `move_and_slide` solids with Area2D portals.

---

## 3. Minimal inventory design for cozy games (item id, stack, pickup)

### 3.1 Stardew Valley — slots, hotbar, stacking

Primary: [Inventory](https://stardewvalleywiki.com/Inventory), [Chest](https://stardewvalleywiki.com/Chest)

- Backpack = **fixed slots** (12 → 24 → 36); one row = hotbar.
- Stacks: identical items combine; chest slots hold up to **999** of one type.
- Tools / weapons / tackle often **do not** stack — they burn slots (design pressure).
- Pickup is proximity / world debris → inventory (auto-pickup is base feel; mods can disable).

### 3.2 Animal Crossing — pockets as hard capacity

Primary: [Nookipedia — Pockets](https://nookipedia.com/wiki/Pockets)

- NH starts at **20** pocket slots; upgrades to **30** then **40** (Nook Miles guides).
- Capacity is a **gameplay verb** (inventory management as cozy friction), not an infinite bag.

### 3.3 Godot implementation pattern (data ≠ UI)

Practitioner pattern (Resource defs + slot array + signal): [Coding Quests — Godot 4 inventory](https://codingquests.io/blog/godot-4-inventory-system-tutorial), [gameidea inventory](https://gameidea.org/2024/08/26/make-inventory-system-in-godot/)

Minimal cozy data model:

```text
ItemDef (Resource): id, display_name, icon, max_stack, tags[]
Slot: { item_id: StringName, count: int } | empty
Bag: Array[Slot] with capacity N
API: try_add(id, n) → remainder; remove(id, n) → bool; count(id) → int
Pickup: Area2D / hotspot → InventoryService.try_add → queue_free if remainder==0
```

**Dream Phase 0 scope:** capacity ~12–20, stackables for fish/forage/tickets, unique/non-stack for tools/keys; **no** crafting grid, **no** chest network yet.

---

## 4. Dream-specific recommendation (fits SceneRouter / InteractableHotspot / WorldSpawnUtil)

### 4.1 Ubiquitous language

| Term | Meaning |
| --- | --- |
| Portal | `Area2D` with `scene_path` (+ future `spawn_id`) — outdoor `Portal_*`, interior `Portal_Return` / `Portal_Extra_*`, `WorldPortal_*` |
| SpawnMarker | Named `Marker2D` / meta node under YSort: `Spawn_<id>` with optional facing |
| ArrivalIntent | Autoload-held `{ scene_path, spawn_id, facing }` set **before** `change_to` |
| Walk mask | `AreaCraft` / interior equivalent — source of truth for feet placement |
| Hotspot | `InteractableHotspot` — interact / pickup affordance, never solid wall |

### 4.2 Transition flow (target)

```text
Portal / TrainService / UI
  → SpawnRegistry.set_intent(to_path, spawn_id, facing?)
  → SceneRouter.change_to(tree, to_path)
  → PlayerBootstrap spawns PlayerActor
  → SpawnRegistry.consume_intent() → resolve Marker / fallback Portal_Return / DEFAULT
  → snap to nearest walkable tile if marker blocked
```

### 4.3 Where to hang spawn metadata (minimal churn)

1. **Prefer** `area.set_meta("spawn_id", "door_south")` beside existing `scene_path` in `WorldSpawnUtil.make_portal`, `AreaCraft.make_portal`, `interior_craft` portals.
2. **Extend** `SceneRouter.change_to` **or** wrap it:

   `SceneRouter.change_to(tree, path, spawn_id := "")` → if `spawn_id` non-empty, `SpawnRegistry.set_intent(...)`.

3. **Do not** encode spawn in scene path strings; keep paths as today (`SceneRouter.*_PATH` constants).
4. **Outdoor return:** when leaving interior via `Portal_Return`, set intent spawn on the **outdoor door** that matches `return_path` (profile or portal meta `return_spawn_id`), instead of always landing on that interior’s `Portal_Return` when *entering*.

### 4.4 Collision / walkability Phase 0

- Keep `PlayerActor` tile walk + axis-slide outdoors.
- Guarantee spawn markers sit on `is_npc_walkable` (or interior walkable) tiles; if not, spiral-search like `PatrolActor._find_npc_walkable_near`.
- Portals remain **Area2D**; add a short **re-entry grace** (0.4–0.8s ignore portal) after spawn so door aprons do not ping-pong.
- Continue feet contract: `FOOT_CONTACT_Y`, prop sprites via `WorldSpawnUtil.attach_prop_sprite`.

### 4.5 Inventory Phase 0

- New autoload `InventoryService` (not UI).
- Pickup = `InteractableHotspot` subclass or meta `pickup_item_id` + count → `try_add`.
- Fish catch / breakables / chests feed the same API (replace “InfoPanel only” rewards later).
- UI can be a later DreamUI strip; service must work headless for QA.

### 4.6 What not to reinvent

- Do not fork `WorldSpawnUtil` portal visuals for spawn logic — only meta + registry.
- Do not put inventory counts on scene nodes; autoload survives `change_scene_to_file`.
- Do not confuse QA `qa_interact_sprite_inventory.py` with gameplay inventory.

---

## 5. Phase 0 API sketch

### 5.1 `SpawnRegistry` (autoload)

```gdscript
# Conceptual API — research only; not implemented in this doc pass.
extends Node

signal arrival_applied(scene_path: String, spawn_id: String, world_pos: Vector2)

var _intent_scene: String = ""
var _intent_spawn: String = ""
var _intent_facing: String = ""  # "up"|"down"|"left"|"right"|""

func set_intent(scene_path: String, spawn_id: String, facing: String = "") -> void:
	_intent_scene = scene_path
	_intent_spawn = spawn_id
	_intent_facing = facing

func peek_intent() -> Dictionary:
	return {"scene_path": _intent_scene, "spawn_id": _intent_spawn, "facing": _intent_facing}

func clear_intent() -> void:
	_intent_scene = ""
	_intent_spawn = ""
	_intent_facing = ""

## Called by PlayerBootstrap after player exists under ysort.
func apply_to_player(host: Node2D, ysort: Node2D, player: Node2D) -> Vector2:
	# 1) If intent.scene matches host.scene_file_path and spawn_id set:
	#      find Spawn_<id> or meta spawn_id marker → local pos
	# 2) Else Portal_Return + doorstep offset (current behavior)
	# 3) Else camera / DEFAULT_SPAWN
	# 4) Snap walkable; clear_intent(); emit arrival_applied
	return player.position

func register_marker(scene_path: String, spawn_id: String, node: Node2D) -> void:
	# Optional runtime index; markers can also be discovered via groups "spawn_markers"
	pass
```

**SceneRouter glue (preferred one-liner callers keep working):**

```gdscript
static func change_to(tree: SceneTree, path: String, spawn_id: String = "") -> void:
	if path.is_empty():
		return
	if not spawn_id.is_empty() and Engine.has_singleton("SpawnRegistry") == false:
		# autoload is a node; call via /root/SpawnRegistry in real code
		pass
	# SpawnRegistry.set_intent(path, spawn_id)
	tree.change_scene_to_file(path)
```

**Marker convention:** `Marker2D` named `Spawn_door_south` in group `spawn_markers`, or portal meta `arrival_spawn_id` on the **destination** scene’s door apron node.

### 5.2 `InventoryService` (autoload)

```gdscript
extends Node

signal changed()
signal rejected_full(item_id: StringName, attempted: int, remainder: int)

const DEFAULT_SLOTS := 16

var _slots: Array[Dictionary] = []  # { "id": StringName, "n": int }

func _ready() -> void:
	resize(DEFAULT_SLOTS)

func resize(n: int) -> void:
	# grow/shrink preserving items
	pass

func capacity() -> int:
	return _slots.size()

func count(item_id: StringName) -> int:
	return 0

func max_stack(item_id: StringName) -> int:
	# from ItemCatalog Resource; default 99 for stackables, 1 for unique
	return 99

func try_add(item_id: StringName, amount: int = 1) -> int:
	## Returns remainder that did not fit. Emits changed / rejected_full.
	return amount

func remove(item_id: StringName, amount: int = 1) -> bool:
	return false

func has(item_id: StringName, amount: int = 1) -> bool:
	return count(item_id) >= amount

func slots_snapshot() -> Array:
	return _slots.duplicate(true)

func clear() -> void:
	pass
```

**Item catalog (data only):** `res://data/items/*.tres` or one `ItemCatalog` Resource map `id → { max_stack, icon, tags }`.

**Pickup hook:** hotspot `activated` → `var left := InventoryService.try_add(id, n)` → if `left == 0`: remove world node; else keep remainder in world or show “口袋满了”.

---

## 6. 禁止偷懒 checklist

执行 Phase 0 / Spine A 时 **禁止**：

1. **禁止** `SceneRouter.change_to` 只传 path、永远依赖 `Portal_Return` / 相机中心当“万能出生点”（双向门会错边、错门口）。
2. **禁止** 在每个 controller 里复制粘贴 `player.position = Vector2(...)` 魔法数；必须走 `SpawnRegistry` + 命名 marker。
3. **禁止** 把出生点放在 portal 碰撞盒正中心导致进门立刻再触发传送；必须 apron + 短 grace。
4. **禁止** 用 `InteractableHotspot` / portal `Area2D` 冒充墙体；固体与检测职责分离。
5. **禁止** 忽略 `AreaCraft.is_npc_walkable` / 室内等价掩码，把玩家刷进水里或建筑 footprint。
6. **禁止** Y-sort 用 sprite 中心当脚底；破坏现有 `FOOT_CONTACT_Y` / `attach_prop_sprite` 合同。
7. **禁止** 做“无限 Dictionary 背包”却没有 slot 上限与 `try_add` 剩余量；cozy 需要容量反馈。
8. **禁止** 把库存写在当前场景节点上（换景即丢）；必须 autoload（或等价跨场景 store）。
9. **禁止** 只做 UI 空壳不接 `try_add` / pickup；也禁止只改 QA sprite inventory 文档冒充 gameplay inventory。
10. **禁止** TrainService / 密道 / `Portal_Extra` 特例绕过 intent；所有 `change_to` 入口同一套 spawn 合同。
11. **禁止** 一次做满商店+箱子网络+装备栏；Phase 0 只交付 registry + service API + 1–2 条真传送验收 + 1 个真 pickup。
12. **禁止** 不写验收：至少自动化/MCP 断言“从 A 门进 B 出现在 Spawn_X，从 B 回 A 出现在 Spawn_Y”。

---

## 7. Cite URLs (canonical)

### Stardew / cozy design
- https://stardewvalleywiki.com/Modding:Maps
- https://stardewvalleywiki.com/Modding:Location_data
- https://stardewvalleywiki.com/Modding:Buildings
- https://stardewvalleywiki.com/Warp_Totem
- https://stardewvalleywiki.com/Inventory
- https://stardewvalleywiki.com/Chest
- https://nookipedia.com/wiki/Pockets
- https://nookipedia.com/wiki/Train

### Godot
- https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html
- https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html
- https://docs.godotengine.org/en/stable/classes/class_canvasitem.html
- https://forum.godotengine.org/t/y-sorting-difficulties/135043

### Inventory implementation references
- https://codingquests.io/blog/godot-4-inventory-system-tutorial
- https://gameidea.org/2024/08/26/make-inventory-system-in-godot/

### Dream internal
- `docs/research/NPC_MOTION_COLLISION_RESEARCH.md`
- `docs/research/TRAIN_SERVICE_RESEARCH.md`
- `scripts/core/scene_router.gd`
- `scripts/core/player_bootstrap.gd`
- `scripts/world/world_spawn_util.gd`
- `scripts/actors/player_actor.gd`
- `scripts/interact/interactable_hotspot.gd`

---

## 8. Suggested Phase 0 acceptance (for implementer)

| ID | Check |
| --- | --- |
| S1 | Enter C01 from residential door → player at indoor `Spawn_entrance` (not map center). |
| S2 | Exit C01 → player at outdoor door apron spawn for that house (not random `Portal_Return` of another building). |
| S3 | After spawn, walking into the same portal within grace does not instantly re-warp. |
| S4 | `InventoryService.try_add("fish_carp", 1)` from one hotspot updates snapshot; second add stacks; fill slots → remainder > 0. |
| S5 | Scene change preserves inventory counts (autoload). |
