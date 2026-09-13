class_name WindSway
extends RefCounted

## Visible foliage wind: vertex lean (trees) + light rotation pulse (flowers/reeds).
## Shader: https://godotshaders.com/shader/2d-wind-sway/ (amplitude in pixels).

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
	var mat := _make_material(kind, phase, node)
	if mat != null:
		node.material = mat
	# Small plants: extra rotation reads clearly even if vertex lean is subtle.
	match kind:
		"flower", "herb", "weed", "reed", "crop":
			_attach_rotation_pulse(node, kind, phase)


static func kind_for_path(path: String) -> String:
	var p := path.to_lower()
	if "tree" in p:
		return "tree"
	if "reed" in p or "cattail" in p:
		return "reed"
	if "flower" in p or "herb" in p or "fern" in p:
		return "flower"
	if "weed" in p or "bush" in p or "shrub" in p:
		return "weed"
	if "furrow" in p or "hay" in p or "grain" in p or "crop" in p:
		return "crop"
	return ""


static func _make_material(kind: String, phase: float, node: CanvasItem) -> ShaderMaterial:
	if _shader == null:
		_shader = load(SHADER_PATH) as Shader
	if _shader == null:
		push_error("WindSway: failed to load %s" % SHADER_PATH)
		return null
	var mat := ShaderMaterial.new()
	mat.shader = _shader
	var start := phase if phase >= 0.0 else float(absi(node.get_instance_id()) % 997) * 0.031
	mat.set_shader_parameter("phase_offset", start)
	match kind:
		"tree":
			mat.set_shader_parameter("speed", 1.15)
			mat.set_shader_parameter("amplitude_px", 10.0)
			mat.set_shader_parameter("detail", 1.1)
			mat.set_shader_parameter("height_offset", 0.18)
			mat.set_shader_parameter("gust_interval", 3.8)
			mat.set_shader_parameter("gust_boost", 0.4)
		"reed":
			mat.set_shader_parameter("speed", 1.7)
			mat.set_shader_parameter("amplitude_px", 9.0)
			mat.set_shader_parameter("detail", 1.6)
			mat.set_shader_parameter("height_offset", 0.04)
			mat.set_shader_parameter("gust_interval", 2.4)
			mat.set_shader_parameter("gust_boost", 0.5)
		"flower", "herb", "weed":
			mat.set_shader_parameter("speed", 1.85)
			mat.set_shader_parameter("amplitude_px", 6.0)
			mat.set_shader_parameter("detail", 1.8)
			mat.set_shader_parameter("height_offset", 0.02)
			mat.set_shader_parameter("gust_interval", 2.2)
			mat.set_shader_parameter("gust_boost", 0.45)
		"crop":
			mat.set_shader_parameter("speed", 1.35)
			mat.set_shader_parameter("amplitude_px", 5.0)
			mat.set_shader_parameter("detail", 1.35)
			mat.set_shader_parameter("height_offset", 0.06)
			mat.set_shader_parameter("gust_interval", 2.8)
			mat.set_shader_parameter("gust_boost", 0.35)
		_:
			mat.set_shader_parameter("speed", 1.2)
			mat.set_shader_parameter("amplitude_px", 7.0)
			mat.set_shader_parameter("height_offset", 0.1)
	return mat


static func _attach_rotation_pulse(node: CanvasItem, kind: String, phase: float) -> void:
	if node.has_meta("_wind_rot"):
		return
	if not (node is Node2D):
		return
	var n := node as Node2D
	node.set_meta("_wind_rot", true)
	var amp := 0.07
	var period_a := 0.85
	var period_b := 1.05
	match kind:
		"reed":
			amp = 0.11
			period_a = 0.7
			period_b = 0.95
		"crop":
			amp = 0.045
			period_a = 1.0
			period_b = 1.2
		_:
			amp = 0.08
	var delay := maxf(0.0, phase) * 0.15 if phase >= 0.0 else float(absi(n.get_instance_id()) % 50) * 0.02
	var tw := n.create_tween().set_loops()
	tw.tween_interval(delay)
	tw.tween_property(n, "rotation", amp, period_a).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(n, "rotation", -amp, period_b).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
