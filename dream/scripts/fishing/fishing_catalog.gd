class_name FishingCatalog
extends RefCounted

## C18–C21 catalog — sites, rods, placeholder fish tables.
## See docs/FISH_E.md.

const ROD_BAMBOO := "bamboo"
const ROD_IRON := "iron"

## Active rod for the session (persists across spots in the same run).
static var current_rod_id: String = ROD_BAMBOO

static func rods() -> Array[Dictionary]:
	return [
		{
			"id": ROD_BAMBOO,
			"name": "竹竿",
			"desc": "入门竿，抛投稳，咬钩偏慢。",
			"wait_mul": 1.15,
			"rare_bonus": 0.0,
			"icon": "res://assets/sprites/fishing/rod_bamboo_00.png",
		},
		{
			"id": ROD_IRON,
			"name": "铁竿",
			"desc": "加固竿，咬钩更快，稍易出非常见鱼。",
			"wait_mul": 0.75,
			"rare_bonus": 0.18,
			"icon": "res://assets/sprites/fishing/rod_iron_00.png",
		},
	]


static func rod_by_id(rod_id: String) -> Dictionary:
	for r in rods():
		if str(r["id"]) == rod_id:
			return r
	return rods()[0]


static func cycle_rod() -> Dictionary:
	var list := rods()
	var idx := 0
	for i in list.size():
		if str(list[i]["id"]) == current_rod_id:
			idx = i
			break
	idx = (idx + 1) % list.size()
	current_rod_id = str(list[idx]["id"])
	return list[idx]


static func site_label(site_id: String) -> String:
	match site_id:
		"river":
			return "河岸钓点"
		"lake":
			return "湖畔钓点"
		_:
			return "钓点"


static func fish_pool(site_id: String) -> Array[Dictionary]:
	## weight: relative pick weight. rarity used with rod rare_bonus.
	match site_id:
		"river":
			return [
				{"id": "river_minnow", "name": "河鲦", "rarity": "common", "weight": 55, "sprite": "res://assets/sprites/fishing/fish_minnow_00.png"},
				{"id": "river_trout", "name": "溪鳟", "rarity": "uncommon", "weight": 28, "sprite": "res://assets/sprites/fishing/fish_trout_00.png"},
				{"id": "weed", "name": "水草", "rarity": "junk", "weight": 17, "sprite": "res://assets/sprites/fishing/fish_weed_00.png"},
			]
		"lake":
			return [
				{"id": "lake_perch", "name": "湖鲈", "rarity": "common", "weight": 50, "sprite": "res://assets/sprites/fishing/fish_perch_00.png"},
				{"id": "lake_carp", "name": "锦鲤", "rarity": "uncommon", "weight": 30, "sprite": "res://assets/sprites/fishing/fish_carp_00.png"},
				{"id": "weed", "name": "水草", "rarity": "junk", "weight": 20, "sprite": "res://assets/sprites/fishing/fish_weed_00.png"},
			]
		_:
			return [
				{"id": "weed", "name": "水草", "rarity": "junk", "weight": 100, "sprite": "res://assets/sprites/fishing/fish_weed_00.png"},
			]


static func roll_fish(site_id: String, rod_id: String) -> Dictionary:
	var rod := rod_by_id(rod_id)
	var rare_bonus := float(rod.get("rare_bonus", 0.0))
	var pool := fish_pool(site_id)
	var total := 0.0
	var weights: Array[float] = []
	for fish in pool:
		var w := float(fish.get("weight", 1))
		var rarity := str(fish.get("rarity", "common"))
		if rarity == "uncommon":
			w *= 1.0 + rare_bonus * 2.0
		elif rarity == "junk":
			w *= maxf(0.35, 1.0 - rare_bonus)
		weights.append(w)
		total += w
	if total <= 0.0:
		return pool[0]
	var roll := randf() * total
	var acc := 0.0
	for i in pool.size():
		acc += weights[i]
		if roll <= acc:
			return pool[i]
	return pool[pool.size() - 1]
