class_name SecretPassageChain
extends Node

## C62 — secret passage chain: forest_deep → cave → waterfall → lake (real portals).

const NODE_NAME := "SecretPassageChain"

## Canonical chain (outdoor + cave hop).
const CHAIN_A := [
	{
		"from": "forest_deep",
		"label": "树洞密道",
		"to_path": "res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn",
		"pos": Vector2(480, 360),
		"facade": "res://assets/sprites/props/ruin_arch_00.png",
	},
	{
		"from": "c16_cave_entry",
		"label": "暗河出口",
		"to_path": "res://scenes/areas/waterfall/waterfall.tscn",
		"pos": Vector2(240, 528),
		"facade": "res://assets/sprites/props/door_facade_00.png",
	},
	{
		"from": "waterfall",
		"label": "瀑后回湖",
		"to_path": "res://scenes/areas/lake/lake.tscn",
		"pos": Vector2(860, 560),
		"facade": "res://assets/sprites/props/door_facade_00.png",
	},
]

signal portal_used(label: String, to_path: String)

var _root: Node2D


static func stub_chain() -> Array:
	return CHAIN_A


static func chain_links() -> Array:
	return CHAIN_A


static func attach_for_host(host: Node2D, host_key: String) -> SecretPassageChain:
	if host == null or host_key.is_empty():
		return null
	var node_name := "%s_%s" % [NODE_NAME, host_key]
	var existing := host.get_node_or_null(node_name) as SecretPassageChain
	if existing:
		return existing
	var links: Array = []
	for link in CHAIN_A:
		if str(link["from"]) == host_key:
			links.append(link)
	if links.is_empty():
		return null
	var kit := SecretPassageChain.new()
	kit.name = node_name
	host.add_child(kit)
	kit.setup(host, links)
	return kit


## Thin interior hook — call from InteriorRoomController when profile is on the chain.
static func try_attach_interior(host: Node2D) -> SecretPassageChain:
	if host == null:
		return null
	var profile_id := ""
	if host.get("profile_id") != null:
		profile_id = str(host.get("profile_id"))
	if profile_id.is_empty() and host.has_meta("profile_id"):
		profile_id = str(host.get_meta("profile_id"))
	return attach_for_host(host, profile_id)


func setup(host: Node2D, links: Array) -> void:
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "SecretPassageRoot"
	_root.y_sort_enabled = true
	_root.z_index = 6
	ysort.add_child(_root)
	for link in links:
		var label := str(link["label"])
		var to_path := str(link["to_path"])
		var pos: Vector2 = link["pos"] as Vector2
		var facade_path := str(link.get("facade", WorldSpawnUtil.DOOR_FACADE))
		var portal := WorldSpawnUtil.make_portal(
			_root,
			label,
			to_path,
			pos,
			Vector2(100, 56),
			Color(0.45, 0.85, 0.95, 0.95),
			facade_path,
		)
		portal.set_meta("secret_chain", true)
		var captured_label := label
		var captured_path := to_path
		# Emit before SceneRouter navigate so listeners always observe the click.
		portal.input_event.connect(func(_vp: Node, event: InputEvent, _si: int) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				portal_used.emit(captured_label, captured_path)
		)
		WorldSpawnUtil.wire_portal_click(portal, host.get_tree())
