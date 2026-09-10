class_name InteractableHotspot
extends Area2D

signal activated(hotspot: InteractableHotspot)

@export var title: String = "Object"
@export_multiline var description: String = ""
@export var highlight_modulate: Color = Color(1.15, 1.15, 0.85, 1.0)

var _default_modulate: Color = Color.WHITE
var _visual: CanvasItem


func _ready() -> void:
	input_pickable = true
	monitoring = true
	monitorable = true
	if not body_entered.is_connected(_on_overlap):
		pass
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	_visual = get_node_or_null("Visual") as CanvasItem
	if _visual:
		_default_modulate = _visual.modulate


func _on_mouse_entered() -> void:
	if _visual:
		_visual.modulate = highlight_modulate


func _on_mouse_exited() -> void:
	if _visual:
		_visual.modulate = _default_modulate


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			activated.emit(self)


func _on_overlap(_body: Node2D) -> void:
	pass
