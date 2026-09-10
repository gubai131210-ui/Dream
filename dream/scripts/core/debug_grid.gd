class_name DebugGrid
extends Node2D

@export var cell_size: int = 32
@export var grid_size: Vector2i = Vector2i(40, 30)
@export var color: Color = Color(1, 1, 1, 0.12)


func _draw() -> void:
	for x in range(grid_size.x + 1):
		var px := x * cell_size
		draw_line(Vector2(px, 0), Vector2(px, grid_size.y * cell_size), color)
	for y in range(grid_size.y + 1):
		var py := y * cell_size
		draw_line(Vector2(0, py), Vector2(grid_size.x * cell_size, py), color)
