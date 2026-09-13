extends Node

## Pending arrival spawn for SceneRouter transitions (Stardew-like warp dest).

signal pending_consumed(spawn_id: String)

var _pending_id: String = ""
var _pending_pos: Vector2 = Vector2.INF


func set_pending(spawn_id: String, world_pos: Vector2 = Vector2.INF) -> void:
	_pending_id = spawn_id.strip_edges()
	_pending_pos = world_pos


func has_pending() -> bool:
	return not _pending_id.is_empty() or _pending_pos != Vector2.INF


func peek_id() -> String:
	return _pending_id


func take_pending() -> Dictionary:
	var out := {"id": _pending_id, "pos": _pending_pos}
	_pending_id = ""
	_pending_pos = Vector2.INF
	pending_consumed.emit(str(out.get("id", "")))
	return out


## Named defaults when a scene has no Spawn_<id> marker node.
func default_local_pos(scene_path: String, spawn_id: String) -> Vector2:
	var key := "%s|%s" % [scene_path, spawn_id]
	var table := {
		"res://scenes/areas/station/station.tscn|from_square": Vector2(200, 520),
		"res://scenes/areas/village_square/village_square.tscn|from_station": Vector2(1100, 520),
		"res://scenes/areas/farmland/farmland.tscn|default": Vector2(640, 520),
		"res://scenes/areas/farmland/farmland.tscn|from_home": Vector2(640, 560),
		"res://scenes/interiors/c29_ruins/c29_ruins.tscn|entrance": Vector2(400, 280),
		"res://scenes/interiors/c29_ruins/c29_ruins.tscn|default": Vector2(400, 280),
		"res://scenes/areas/forest_deep/forest_deep.tscn|from_ruins": Vector2(900, 400),
	}
	if table.has(key):
		return table[key]
	if spawn_id == "default" or spawn_id.is_empty():
		return Vector2.INF
	return Vector2.INF
