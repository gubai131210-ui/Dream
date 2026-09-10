class_name InfoPanel
extends CanvasLayer

@onready var _title: Label = $Root/Panel/Margin/VBox/Title
@onready var _body: Label = $Root/Panel/Margin/VBox/Body
@onready var _close: Button = $Root/Panel/Margin/VBox/Close


func _ready() -> void:
	visible = false
	_close.pressed.connect(hide_info)


func show_info(title: String, body: String) -> void:
	_title.text = title
	_body.text = body
	visible = true


func hide_info() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_info()
		get_viewport().set_input_as_handled()
