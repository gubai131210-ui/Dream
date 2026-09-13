class_name WindSway
extends RefCounted

## Foot-anchored wind sway for trees / flowers / reeds / crops.
## Uses Node2D.skew so the transform origin (feet) stays planted.

const GROUP := "wind_sway"


static func attach(node: CanvasItem, kind: String = "tree", phase: float = -1.0) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.has_meta("_wind_sway"):
		return
	if not (node is Node2D):
		return
	var n2 := node as Node2D
	if not n2.is_inside_tree():
		n2.ready.connect(
			func() -> void:
				attach(n2, kind, phase),
			CONNECT_ONE_SHOT
		)
		return
	n2.set_meta("_wind_sway", kind)
	n2.add_to_group(GROUP)
	var amp := _amplitude(kind)
	var period := _period(kind)
	var start := phase if phase >= 0.0 else float(absi(n2.get_instance_id()) % 1000) * 0.01
	var tw := n2.create_tween().set_loops()
	tw.tween_interval(start * 0.15)
	tw.tween_property(n2, "skew", amp, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(n2, "skew", -amp, period).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(n2, "skew", 0.0, period * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Soft flutter for small plants only (trees stay trunk-stable).
	if kind in ["flower", "herb", "reed", "weed"]:
		var bob := 0.55
		var base_y := n2.position.y
		var tw2 := n2.create_tween().set_loops()
		tw2.tween_interval(start * 0.12)
		tw2.tween_property(n2, "position:y", base_y - bob, period * 0.55).set_trans(Tween.TRANS_SINE)
		tw2.tween_property(n2, "position:y", base_y + bob * 0.35, period * 0.55).set_trans(Tween.TRANS_SINE)
		tw2.tween_property(n2, "position:y", base_y, period * 0.35).set_trans(Tween.TRANS_SINE)


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


static func _amplitude(kind: String) -> float:
	match kind:
		"tree":
			return 0.045
		"reed":
			return 0.09
		"flower", "herb":
			return 0.08
		"weed":
			return 0.1
		"crop":
			return 0.035
		_:
			return 0.05


static func _period(kind: String) -> float:
	match kind:
		"tree":
			return 2.8
		"reed":
			return 1.6
		"flower", "herb", "weed":
			return 1.4
		"crop":
			return 2.2
		_:
			return 2.0
