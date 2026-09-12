class_name InteractProximityDirector
extends RefCounted

## Shared hover-wins / nearest-in-reach selector for 「互动」prompts.
## Used by interiors and outdoor AreaInteractHost (INTERACTION_DESIGN parity).

const GROUP_HOTSPOTS := "interactable_hotspots"

var prompt_active: InteractableHotspot = null


func update(host: Node, camera: Node2D = null, search_root: Node = null) -> InteractableHotspot:
	var hotspots := _collect_hotspots(host, search_root)
	var best: InteractableHotspot = null
	for hs in hotspots:
		if is_instance_valid(hs) and hs.is_mouse_hovered():
			best = hs
			break

	if best == null:
		var player := _find_player_body(host, search_root)
		var has_player_body := player != null
		var anchor: Vector2
		if has_player_body:
			anchor = player.global_position
		elif camera != null and is_instance_valid(camera):
			anchor = camera.global_position
		elif host is Node2D:
			anchor = (host as Node2D).global_position
		else:
			anchor = Vector2.ZERO

		var best_dist := INF
		for hs in hotspots:
			if not is_instance_valid(hs):
				continue
			var candidate := false
			if has_player_body:
				candidate = hs.has_player_overlap()
			else:
				candidate = hs.is_point_in_reach(anchor)
			if not candidate:
				continue
			var d := hs.global_position.distance_squared_to(anchor)
			if d < best_dist:
				best_dist = d
				best = hs

	_apply_prompt(best)
	return prompt_active


func sync_click(hotspot: InteractableHotspot) -> void:
	if hotspot == null:
		return
	_apply_prompt(hotspot)


func get_executable() -> InteractableHotspot:
	return prompt_active


func _apply_prompt(best: InteractableHotspot) -> void:
	if prompt_active == best:
		return
	if prompt_active and is_instance_valid(prompt_active):
		prompt_active.set_proximity_prompt_shown(false)
	prompt_active = best
	if prompt_active:
		prompt_active.set_proximity_prompt_shown(true)


func _collect_hotspots(host: Node, _search_root: Node) -> Array[InteractableHotspot]:
	var out: Array[InteractableHotspot] = []
	if host == null or host.get_tree() == null:
		return out
	for n in host.get_tree().get_nodes_in_group(GROUP_HOTSPOTS):
		if not (n is InteractableHotspot):
			continue
		var hs := n as InteractableHotspot
		if not is_instance_valid(hs):
			continue
		if hs != host and not host.is_ancestor_of(hs):
			continue
		out.append(hs)
	return out


func _find_player_body(host: Node, search_root: Node) -> Node2D:
	if host == null or host.get_tree() == null:
		return null
	for n in host.get_tree().get_nodes_in_group("player"):
		if n is Node2D and is_instance_valid(n):
			return n as Node2D
	var root := search_root if search_root != null else host
	if root == null:
		return null
	return _find_character_body(root)


func _find_character_body(node: Node) -> CharacterBody2D:
	if node is CharacterBody2D:
		return node as CharacterBody2D
	for child in node.get_children():
		var found := _find_character_body(child)
		if found:
			return found
	return null
