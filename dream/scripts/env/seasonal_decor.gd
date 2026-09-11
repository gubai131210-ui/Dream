class_name SeasonalDecor
extends Node

## C55 — plaza seasonal decoration layer (reuse A09 skeleton). Wave F WorldSys enriches.

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

signal season_changed(season: int)

var _season: int = Season.SPRING
var _host: Node2D
var _layer: Node2D


static func attach_to(host: Node2D, top_bar: Control = null) -> SeasonalDecor:
	var node := SeasonalDecor.new()
	host.add_child(node)
	node.setup(host, top_bar)
	return node


func setup(host: Node2D, top_bar: Control = null) -> void:
	_host = host
	_layer = Node2D.new()
	_layer.name = "SeasonalDecorLayer"
	_layer.z_index = 3
	host.add_child(_layer)
	_rebuild()
	if top_bar:
		var btn := Button.new()
		btn.text = "季节"
		btn.pressed.connect(cycle_season)
		top_bar.add_child(btn)


func cycle_season() -> void:
	_season = (_season + 1) % 4
	_rebuild()
	season_changed.emit(_season)


func _rebuild() -> void:
	for c in _layer.get_children():
		c.queue_free()
	## Stub markers — WorldSys replaces with real props / modulate veils.
	var label := Label.new()
	label.text = ["春花", "夏海", "秋收", "冬雪"][_season] + "装饰（占位）"
	label.position = Vector2(40, 80)
	_layer.add_child(label)
