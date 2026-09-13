extends Node

## Spawns the playable protagonist and wires camera follow on outdoor/interior scenes.

const SKIP_SCENE_PREFIXES: Array[String] = [
	"res://scenes/hub/",
	"res://scenes/qa/",
]

const DEFAULT_SPAWN := Vector2(640, 480)


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	call_deferred("_bootstrap_current")


func _on_scene_changed() -> void:
	call_deferred("_bootstrap_current")


func _bootstrap_current() -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var scene_path := scene.scene_file_path
	for prefix in SKIP_SCENE_PREFIXES:
		if scene_path.begins_with(prefix):
			return
	if _find_existing_player(scene) != null:
		return
	var camera := _find_camera(scene)
	if camera == null:
		return
	var host := scene as Node2D
	if host == null:
		return
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	if ysort == null:
		return

	var player := PlayerActor.new()
	player.name = "Player"
	player.position = _resolve_spawn(host, ysort)
	ysort.add_child(player)

	# AreaCraft is RefCounted (not a Node). Assemblers expose it as `.craft`.
	var assembler := scene.get_node_or_null("Assembler")
	if assembler != null:
		var craft_variant: Variant = assembler.get("craft")
		if craft_variant is AreaCraft:
			player.set_area_craft(craft_variant as AreaCraft)

	if camera is CameraController:
		var cam := camera as CameraController
		cam.set_follow_target(player)
		cam.global_position = player.global_position
		cam.clamp_to_bounds()


func _resolve_spawn(host: Node2D, ysort: Node2D) -> Vector2:
	## Prefer SpawnRegistry pending (from SceneRouter.change_to spawn_id / portal meta).
	if SpawnRegistry.has_pending():
		var pending: Dictionary = SpawnRegistry.take_pending()
		var pos_v: Variant = pending.get("pos", Vector2.INF)
		if typeof(pos_v) == TYPE_VECTOR2 and pos_v != Vector2.INF:
			return ysort.to_local(pos_v)
		var sid := str(pending.get("id", ""))
		if not sid.is_empty():
			var marker := host.find_child("Spawn_%s" % sid, true, false) as Node2D
			if marker != null:
				return ysort.to_local(marker.global_position)
			var catalog := SpawnRegistry.default_local_pos(host.scene_file_path, sid)
			if catalog != Vector2.INF:
				return catalog
	# Legacy: south apron of Portal_Return (avoid instant re-trigger).
	var portal := host.find_child("Portal_Return", true, false) as Node2D
	if portal != null:
		return ysort.to_local(portal.global_position + Vector2(0, 48.0))
	var camera := _find_camera(host)
	if camera != null:
		return ysort.to_local(camera.global_position)
	return DEFAULT_SPAWN


func _find_camera(root: Node) -> Camera2D:
	if root is Camera2D:
		return root as Camera2D
	for child in root.get_children():
		var found := _find_camera(child)
		if found:
			return found
	return null


func _find_existing_player(root: Node) -> Node:
	for n in root.get_tree().get_nodes_in_group("player"):
		if n is PlayerActor and is_instance_valid(n):
			return n
	return null
