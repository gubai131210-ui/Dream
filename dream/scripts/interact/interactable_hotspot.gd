class_name InteractableHotspot
extends Area2D

signal activated(hotspot: InteractableHotspot)

@export var title: String = "Object"
@export_multiline var description: String = ""
@export var highlight_modulate: Color = Color(1.15, 1.15, 0.85, 1.0)
@export var prompt_text: String = "互动"
## Extra clearance above the visual top before the prompt Label (px).
@export var prompt_clearance_px: float = 16.0
## When no CharacterBody2D/"player" exists, camera-proxy reach uses this pad around the collision AABB.
@export var camera_reach_pad_px: float = 28.0

var _default_modulate: Color = Color.WHITE
var _visual: CanvasItem
var _hovered := false
var _marker_size := Vector2(24, 24)
var _visual_top_y := -16.0
var _prompt: Label
var _prompt_shown := false
## Physics bodies currently overlapping that count as the player.
var _overlap_players: Array[Node2D] = []


func _ready() -> void:
	input_pickable = true
	monitoring = true
	monitorable = true
	collision_mask = maxi(collision_mask, 1)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	_visual = get_node_or_null("Visual") as CanvasItem
	if _visual:
		_default_modulate = _visual.modulate
	_cache_marker_size()
	_cache_visual_bounds()
	_ensure_prompt()
	queue_redraw()


func _cache_marker_size() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return
	if collision.shape is RectangleShape2D:
		_marker_size = (collision.shape as RectangleShape2D).size * 0.5
	elif collision.shape is CircleShape2D:
		var r := (collision.shape as CircleShape2D).radius
		_marker_size = Vector2(r, r)


func _ensure_prompt() -> void:
	if _prompt != null and is_instance_valid(_prompt):
		return
	_prompt = Label.new()
	_prompt.name = "ProximityPrompt"
	_prompt.text = prompt_text
	_prompt.visible = false
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.z_index = 20
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_color_override("font_color", Color("#fff4c7"))
	_prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.size = Vector2(56, 22)
	add_child(_prompt)
	_layout_prompt()


func _cache_visual_bounds() -> void:
	# Prompt placement must use stable animation bounds, not the currently
	# displayed frame. Otherwise a frame with a different transparent margin
	# makes the prompt jump or overlap the target while the animation plays.
	_visual_top_y = -maxf(_marker_size.y, 16.0)
	var visual_node := get_node_or_null("Visual") as Node2D
	if visual_node == null:
		return
	for child in visual_node.get_children():
		if child is Sprite2D:
			var spr := child as Sprite2D
			if spr.texture == null:
				continue
			var h := float(spr.texture.get_height()) * absf(spr.scale.y)
			var top := spr.position.y + spr.offset.y
			if spr.centered:
				top -= h * 0.5
			_visual_top_y = minf(_visual_top_y, top)
		elif child is AnimatedSprite2D:
			var anim := child as AnimatedSprite2D
			if anim.sprite_frames == null:
				continue
			for animation_name in anim.sprite_frames.get_animation_names():
				var frame_count := anim.sprite_frames.get_frame_count(animation_name)
				for frame_index in range(frame_count):
					var frame_tex := anim.sprite_frames.get_frame_texture(animation_name, frame_index)
					if frame_tex == null:
						continue
					var h := float(frame_tex.get_height()) * absf(anim.scale.y)
					var top := anim.position.y + anim.offset.y
					if anim.centered:
						top -= h * 0.5
					_visual_top_y = minf(_visual_top_y, top)


func _layout_prompt() -> void:
	if _prompt == null:
		return
	_prompt.position = Vector2(-28.0, _visual_top_y - prompt_clearance_px - 20.0)
	_prompt.size = Vector2(56, 22)
	_prompt.text = prompt_text


func set_proximity_prompt_shown(shown: bool) -> void:
	_ensure_prompt()
	if shown:
		_cache_marker_size()
		_cache_visual_bounds()
		_layout_prompt()
	if _prompt_shown == shown and _prompt.visible == shown:
		return
	_prompt_shown = shown
	_prompt.visible = shown


func has_player_overlap() -> bool:
	_prune_overlap_players()
	return not _overlap_players.is_empty()


func is_mouse_hovered() -> bool:
	return _hovered


## Camera / future player proxy: true when `world_pos` is inside the collision AABB + pad.
func is_point_in_reach(world_pos: Vector2) -> bool:
	_cache_marker_size()
	var local := to_local(world_pos)
	var half := Vector2(maxf(_marker_size.x, 12.0), maxf(_marker_size.y, 12.0)) + Vector2(camera_reach_pad_px, camera_reach_pad_px)
	return absf(local.x) <= half.x and absf(local.y) <= half.y


func _prune_overlap_players() -> void:
	for i in range(_overlap_players.size() - 1, -1, -1):
		if not is_instance_valid(_overlap_players[i]):
			_overlap_players.remove_at(i)


func _is_player_body(body: Node2D) -> bool:
	if body == null:
		return false
	if body.is_in_group("player"):
		return true
	return body is CharacterBody2D


func _on_body_entered(body: Node2D) -> void:
	if not _is_player_body(body):
		return
	if _overlap_players.has(body):
		return
	_overlap_players.append(body)


func _on_body_exited(body: Node2D) -> void:
	_overlap_players.erase(body)


func _on_mouse_entered() -> void:
	_hovered = true
	if _visual == null:
		_visual = get_node_or_null("Visual") as CanvasItem
		if _visual:
			_default_modulate = _visual.modulate
	if _visual:
		_visual.modulate = highlight_modulate
	_ensure_focus_corners()
	queue_redraw()


func _on_mouse_exited() -> void:
	_hovered = false
	if _visual:
		_visual.modulate = _default_modulate
	_set_focus_corners_visible(false)
	queue_redraw()


func _ensure_focus_corners() -> void:
	## Prefer pixel corner marks; _draw() lines remain as fallback.
	if get_node_or_null("FocusCorners") != null:
		_set_focus_corners_visible(true)
		return
	var path := "res://assets/sprites/fx/focus_corners_00.png"
	var tex := WorldSpawnUtil.load_prop_texture(path)
	if tex == null:
		return
	var root := Node2D.new()
	root.name = "FocusCorners"
	root.z_index = 15
	var half := Vector2(maxf(_marker_size.x, 18.0), maxf(_marker_size.y, 16.0))
	var pad := 6.0
	var positions := [
		Vector2(-half.x - pad, -half.y - pad),
		Vector2(half.x + pad, -half.y - pad),
		Vector2(-half.x - pad, half.y + pad),
		Vector2(half.x + pad, half.y + pad),
	]
	var flips := [
		Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1),
	]
	for i in range(4):
		var spr := Sprite2D.new()
		spr.texture = tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = positions[i]
		spr.scale = flips[i]
		spr.z_index = 15
		root.add_child(spr)
	add_child(root)


func _set_focus_corners_visible(shown: bool) -> void:
	var root := get_node_or_null("FocusCorners") as CanvasItem
	if root:
		root.visible = shown


func _draw() -> void:
	if not _hovered:
		return
	# Skip procedural lines when pixel focus corners are present.
	if get_node_or_null("FocusCorners") != null:
		return
	var half := Vector2(maxf(_marker_size.x, 18.0), maxf(_marker_size.y, 16.0))
	var pad := 5.0
	var left := -half.x - pad
	var right := half.x + pad
	var top := -half.y - pad
	var bottom := half.y + pad
	# A stable focus frame is easier to read than an always-pulsing frame and
	# cannot be mistaken for a broken animation or duplicated sprite.
	var c := Color(1.0, 0.87, 0.4, 0.88)
	var arm := 12.0
	draw_line(Vector2(left, top), Vector2(left + arm, top), c, 2.0)
	draw_line(Vector2(left, top), Vector2(left, top + arm), c, 2.0)
	draw_line(Vector2(right - arm, top), Vector2(right, top), c, 2.0)
	draw_line(Vector2(right, top), Vector2(right, top + arm), c, 2.0)
	draw_line(Vector2(left, bottom - arm), Vector2(left, bottom), c, 2.0)
	draw_line(Vector2(left, bottom), Vector2(left + arm, bottom), c, 2.0)
	draw_line(Vector2(right - arm, bottom), Vector2(right, bottom), c, 2.0)
	draw_line(Vector2(right, bottom - arm), Vector2(right, bottom), c, 2.0)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			activated.emit(self)
