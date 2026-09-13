extends Node

## Minimal cozy inventory — item id → stack count (no full bag UI yet).

signal changed(item_id: String, qty: int)

const MAX_STACK := 99
const CAPACITY_KINDS := 24

## Catalog: display + soft sink hints (Phase0).
const CATALOG := {
	"seed_turnip": {"title": "芜菁种子", "desc": "可种在农田试验畦。"},
	"crop_turnip": {"title": "芜菁", "desc": "收获物。可留作口粮或以后加工。"},
	"loot_moss_resin": {"title": "苔树脂", "desc": "遗迹苔团掉落。可做灯饰/家具 soft gate。"},
	"loot_ruin_shard": {"title": "遗迹碎晶", "desc": "遗迹口袋稀有碎片。黑市/装饰 soft gate。"},
}

var _bags: Dictionary = {}  # String -> int


func clear() -> void:
	_bags.clear()
	changed.emit("", 0)


func count(item_id: String) -> int:
	return int(_bags.get(item_id, 0))


func snapshot() -> Dictionary:
	return _bags.duplicate()


func title_of(item_id: String) -> String:
	var d: Dictionary = CATALOG.get(item_id, {})
	return str(d.get("title", item_id))


func desc_of(item_id: String) -> String:
	var d: Dictionary = CATALOG.get(item_id, {})
	return str(d.get("desc", ""))


func try_add(item_id: String, amount: int = 1) -> Dictionary:
	## Returns {ok, added, left, qty, msg}
	if item_id.is_empty() or amount <= 0:
		return {"ok": false, "added": 0, "left": amount, "qty": count(item_id), "msg": "无效物品"}
	if not CATALOG.has(item_id) and not _bags.has(item_id):
		# Allow unknown ids but warn via msg — still store for QA flexibility.
		pass
	if not _bags.has(item_id) and _bags.size() >= CAPACITY_KINDS:
		return {"ok": false, "added": 0, "left": amount, "qty": 0, "msg": "背包种类已满"}
	var cur := count(item_id)
	var room := MAX_STACK - cur
	if room <= 0:
		return {"ok": false, "added": 0, "left": amount, "qty": cur, "msg": "该物品已堆满"}
	var add_n := mini(amount, room)
	_bags[item_id] = cur + add_n
	changed.emit(item_id, int(_bags[item_id]))
	var left := amount - add_n
	return {
		"ok": true,
		"added": add_n,
		"left": left,
		"qty": int(_bags[item_id]),
		"msg": "获得 %s ×%d（现有 %d）" % [title_of(item_id), add_n, int(_bags[item_id])],
	}


func try_remove(item_id: String, amount: int = 1) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "removed": 0, "qty": count(item_id), "msg": "无效数量"}
	var cur := count(item_id)
	if cur < amount:
		return {"ok": false, "removed": 0, "qty": cur, "msg": "数量不足"}
	var nxt := cur - amount
	if nxt <= 0:
		_bags.erase(item_id)
		changed.emit(item_id, 0)
	else:
		_bags[item_id] = nxt
		changed.emit(item_id, nxt)
	return {"ok": true, "removed": amount, "qty": count(item_id), "msg": "消耗 %s ×%d" % [title_of(item_id), amount]}


func grant_starter_seeds_if_empty() -> void:
	if count("seed_turnip") <= 0 and count("crop_turnip") <= 0:
		try_add("seed_turnip", 6)
