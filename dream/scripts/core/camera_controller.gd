class_name CameraController
extends Camera2D

@export var pan_speed: float = 600.0
@export var zoom_step: float = 1.0
@export var min_zoom: float = 0.35
@export var max_zoom: float = 3.0
@export var bounds: Rect2 = Rect2(-2000, -2000, 4000, 4000)
@export var drag_button: MouseButton = MOUSE_BUTTON_MIDDLE
@export var follow_smoothing: float = 10.0
## When set, camera tracks the protagonist and disables keyboard pan.
@export var follow_enabled: bool = false

var _dragging: bool = false
var _drag_last: Vector2 = Vector2.ZERO
var _follow_target: Node2D = null


func _ready() -> void:
	make_current()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == drag_button:
			_dragging = mb.pressed
			_drag_last = get_viewport().get_mouse_position()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_apply_zoom(zoom_step)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_apply_zoom(-zoom_step)
	elif event is InputEventMouseMotion and _dragging:
		var mp := get_viewport().get_mouse_position()
		var delta := (_drag_last - mp) / zoom
		global_position += delta
		_drag_last = mp
		_clamp_to_bounds()


func set_follow_target(target: Node2D) -> void:
	_follow_target = target
	follow_enabled = target != null and is_instance_valid(target)


func _process(delta: float) -> void:
	if follow_enabled and _follow_target != null and is_instance_valid(_follow_target):
		var target_pos := _follow_target.global_position
		global_position = global_position.lerp(
			target_pos,
			minf(1.0, follow_smoothing * delta)
		)
		_clamp_to_bounds()
		return

	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0
	if dir != Vector2.ZERO:
		global_position += dir.normalized() * pan_speed * delta / zoom.x
		_clamp_to_bounds()


func _apply_zoom(amount: float) -> void:
	# Use integer zoom levels for tile scenes. The old 0.1 + round combination
	# made a wheel tick from 1.0 round back to 1.0, so zooming appeared broken.
	var target := clampf(zoom.x + amount * zoom_step, min_zoom, max_zoom)
	var z := clampf(round(target), min_zoom, max_zoom)
	zoom = Vector2(z, z)
	_clamp_to_bounds()


func _clamp_to_bounds() -> void:
	global_position.x = clampf(global_position.x, bounds.position.x, bounds.end.x)
	global_position.y = clampf(global_position.y, bounds.position.y, bounds.end.y)
