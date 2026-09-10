class_name HubController
extends Node2D

@export var hub_mode: String = "world"

@onready var camera: CameraController = $CameraController
@onready var map_sprite: Sprite2D = $MapSprite
@onready var ui_layer: CanvasLayer = $UI
@onready var status_label: Label = $UI/TopBar/Status
@onready var btn_square: Button = $UI/TopBar/Buttons/EnterSquare
@onready var btn_other: Button = $UI/TopBar/Buttons/SwitchOverview
@onready var hotspot_square: Area2D = $Hotspots/VillageSquare


func _ready() -> void:
	btn_square.pressed.connect(_enter_square)
	btn_other.pressed.connect(_switch_overview)
	if hotspot_square:
		hotspot_square.input_event.connect(_on_square_hotspot)
		hotspot_square.mouse_entered.connect(func(): status_label.text = "村庄广场（可进入）")
		hotspot_square.mouse_exited.connect(func(): status_label.text = _default_status())
	status_label.text = _default_status()
	_fit_camera_to_map()


func _default_status() -> String:
	if hub_mode == "world":
		return "世界总览 — 拖拽/滚轮缩放，点击广场区域进入示例页"
	return "场景连接总览 — 点击广场节点进入示例页"


func _fit_camera_to_map() -> void:
	if map_sprite.texture == null:
		return
	var size := map_sprite.texture.get_size()
	map_sprite.centered = true
	map_sprite.position = Vector2.ZERO
	camera.bounds = Rect2(-size * 0.6, size * 1.2)
	camera.zoom = Vector2(0.55, 0.55)


func _enter_square() -> void:
	get_tree().change_scene_to_file(SceneRouter.SQUARE_PATH)


func _switch_overview() -> void:
	if hub_mode == "world":
		get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH)
	else:
		get_tree().change_scene_to_file(SceneRouter.HUB_PATH)


func _on_square_hotspot(_vp: Node, event: InputEvent, _idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_enter_square()
