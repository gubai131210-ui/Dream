class_name WindSway
extends RefCounted

## Pixel-friendly wind via Maujoe-style 2D wind sway shader (GodotShaders).
## https://godotshaders.com/shader/2d-wind-sway/
## Crown moves more than feet (UV.y falloff); values tuned for 32–64px foliage.

const GROUP := "wind_sway"
const SHADER_PATH := "res://shaders/wind_sway_2d.gdshader"

static var _shader: Shader


static func attach(node: CanvasItem, kind: String = "tree", phase: float = -1.0) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.has_meta("_wind_sway"):
		return
	if not node.is_inside_tree():
		node.ready.connect(
			func() -> void:
				attach(node, kind, phase),
			CONNECT_ONE_SHOT
		)
		return
	node.set_meta("_wind_sway", kind)
	node.add_to_group(GROUP)
	node.material = _make_material(kind, phase, node)


static func kind_for_path(path: String) -> String:
	var p := path.to_lower()
	if "tree" in p:
		return "tree"
	if "flower" in p or "herb" in p:
		return "flower"
	if "reed" in p:
		return "reed"
	if "weed" in p:
		return "weed"
	if "furrow" in p or "hay" in p or "grain" in p:
		return "crop"
	return ""


static func _make_material(kind: String, phase: float, node: CanvasItem) -> ShaderMaterial:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	var start := phase if phase >= 0.0 else float(absi(node.get_instance_id()) % 997) * 0.031
	mat.set_shader_parameter("phase_offset", start)
	mat.set_shader_parameter("pixel_snap", true)
	match kind:
		"tree":
			# Gentle canopy sway — trunk base stays put via height_offset.
			mat.set_shader_parameter("speed", 0.85)
			mat.set_shader_parameter("min_strength", 0.015)
			mat.set_shader_parameter("max_strength", 0.04)
			mat.set_shader_parameter("strength_scale", 8.0)
			mat.set_shader_parameter("interval", 4.0)
			mat.set_shader_parameter("detail", 1.05)
			mat.set_shader_parameter("height_offset", 0.2)
		"reed":
			mat.set_shader_parameter("speed", 1.35)
			mat.set_shader_parameter("min_strength", 0.03)
			mat.set_shader_parameter("max_strength", 0.08)
			mat.set_shader_parameter("strength_scale", 10.0)
			mat.set_shader_parameter("interval", 2.6)
			mat.set_shader_parameter("detail", 1.5)
			mat.set_shader_parameter("height_offset", 0.05)
		"flower", "herb", "weed":
			mat.set_shader_parameter("speed", 1.45)
			mat.set_shader_parameter("min_strength", 0.025)
			mat.set_shader_parameter("max_strength", 0.07)
			mat.set_shader_parameter("strength_scale", 9.5)
			mat.set_shader_parameter("interval", 2.4)
			mat.set_shader_parameter("detail", 1.7)
			mat.set_shader_parameter("height_offset", 0.03)
		"crop":
			mat.set_shader_parameter("speed", 1.05)
			mat.set_shader_parameter("min_strength", 0.015)
			mat.set_shader_parameter("max_strength", 0.04)
			mat.set_shader_parameter("strength_scale", 7.0)
			mat.set_shader_parameter("interval", 3.2)
			mat.set_shader_parameter("detail", 1.3)
			mat.set_shader_parameter("height_offset", 0.1)
		_:
			mat.set_shader_parameter("speed", 1.0)
			mat.set_shader_parameter("min_strength", 0.02)
			mat.set_shader_parameter("max_strength", 0.05)
			mat.set_shader_parameter("strength_scale", 8.0)
			mat.set_shader_parameter("height_offset", 0.12)
	return mat
