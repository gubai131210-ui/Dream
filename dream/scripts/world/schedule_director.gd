extends Node

## Time/weather/season-driven presence for outdoor NPCs and animals (Stardew-like closed loop).
## Roles resolve goals: work outdoors → shelter in rain/snow → home/sleep at night.

signal schedule_applied(scene_path: String, visible_count: int, sheltered_count: int)

const ROLE_FARMER := "farmer"
const ROLE_MERCHANT := "merchant"
const ROLE_ELDER := "elder"
const ROLE_SMITH := "smith"
const ROLE_GENERIC := "villager"
const ROLE_CRITTER := "critter"

## Home / work anchors by outdoor scene (world space-ish; kits nudge toward nearest building).
const SCENE_SHELTER := {
	"village_square": Vector2(640, 420),
	"village_residential": Vector2(720, 480),
	"farm_residential": Vector2(640, 500),
	"farmland": Vector2(900, 520),
	"market_street": Vector2(520, 400),
	"station": Vector2(640, 420),
	"forest_entrance": Vector2(640, 520),
	"forest_deep": Vector2(640, 480),
	"river": Vector2(640, 560),
	"waterfall": Vector2(640, 520),
	"hill_farm": Vector2(700, 480),
	"lake": Vector2(640, 560),
	"lake_house": Vector2(780, 520),
	"lighthouse": Vector2(640, 480),
}


func _ready() -> void:
	var st := get_node_or_null("/root/WorldEnvState")
	if st and not st.state_changed.is_connected(_on_env):
		st.state_changed.connect(_on_env)
	call_deferred("apply_to_current_scene")


func _on_env(_tg: int, _w: int, _s: int) -> void:
	apply_to_current_scene()


func apply_to_current_scene() -> void:
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return
	var host := tree.current_scene
	var scene_key := _scene_key(host.scene_file_path if host.get("scene_file_path") != null else "")
	var st := get_node_or_null("/root/WorldEnvState")
	var night := st != null and bool(st.is_night())
	var precip := st != null and bool(st.is_precipitating())
	var visible_n := 0
	var sheltered_n := 0
	for n in tree.get_nodes_in_group("patrol_actors"):
		if n == null or not is_instance_valid(n):
			continue
		var role := _infer_role(n)
		var mode := _resolve_mode(role, night, precip)
		_apply_actor(n, mode, scene_key)
		if mode == "hidden_home":
			sheltered_n += 1
		else:
			visible_n += 1
	for n in tree.get_nodes_in_group("ambient_critters"):
		if n == null or not is_instance_valid(n):
			continue
		var mode2 := _resolve_mode(ROLE_CRITTER, night, precip)
		_apply_actor(n, mode2, scene_key)
		if mode2 == "hidden_home":
			sheltered_n += 1
		else:
			visible_n += 1
	schedule_applied.emit(str(host.scene_file_path), visible_n, sheltered_n)


func _scene_key(path: String) -> String:
	var p := path.replace("\\", "/")
	var parts := p.split("/")
	if parts.size() >= 2:
		return parts[parts.size() - 2]
	return p.get_file().get_basename()


func _infer_role(n: Node) -> String:
	if n.has_meta("schedule_role"):
		return str(n.get_meta("schedule_role"))
	var title := ""
	if "title" in n:
		title = str(n.title)
	elif n.has_method("get") and n.get("actor_title") != null:
		title = str(n.actor_title)
	var t := title.to_lower()
	if "农" in title or "farm" in t:
		return ROLE_FARMER
	if "商" in title or "摊" in title or "merchant" in t:
		return ROLE_MERCHANT
	if "铁" in title or "smith" in t:
		return ROLE_SMITH
	if "老" in title or "elder" in t:
		return ROLE_ELDER
	if n.is_in_group("ambient_critters"):
		return ROLE_CRITTER
	return ROLE_GENERIC


func _resolve_mode(role: String, night: bool, precip: bool) -> String:
	## Modes: work | shelter | sleep | hidden_home
	if role == ROLE_CRITTER:
		if night or precip:
			return "hidden_home"
		return "work"
	if night:
		return "hidden_home" if role != ROLE_GENERIC else "sleep"
	if precip:
		match role:
			ROLE_FARMER, ROLE_CRITTER:
				return "shelter"
			ROLE_MERCHANT, ROLE_SMITH:
				return "shelter"
			_:
				return "shelter"
	return "work"


func _apply_actor(n: Node, mode: String, scene_key: String) -> void:
	var prev := str(n.get_meta("schedule_mode", ""))
	var mode_changed := prev != mode
	n.set_meta("schedule_mode", mode)
	# Same mode rebroadcast (DayNight + WorldEnv both fire): skip teleport / resume blink.
	if not mode_changed:
		return
	match mode:
		"hidden_home":
			# Indoors / barn / coop — leave outdoor scene empty of this body.
			if n is CanvasItem:
				(n as CanvasItem).visible = false
			if n.has_method("set_process"):
				n.set_process(false)
			if n.has_method("set_physics_process"):
				n.set_physics_process(false)
		"shelter":
			if n is CanvasItem:
				(n as CanvasItem).visible = true
			_nudge_to_shelter(n, scene_key)
			if n.has_method("set_process"):
				n.set_process(true)
			if n.has_method("pause_patrol"):
				n.pause_patrol()
			elif n.has_method("set_physics_process"):
				n.set_physics_process(false)
		"sleep":
			if n is CanvasItem:
				(n as CanvasItem).visible = true
			_nudge_to_shelter(n, scene_key)
			if "modulate" in n:
				n.modulate = Color(0.75, 0.78, 0.9)
			if n.has_method("pause_patrol"):
				n.pause_patrol()
		_:
			if n is CanvasItem:
				(n as CanvasItem).visible = true
			if "modulate" in n:
				n.modulate = Color.WHITE
			if n.has_method("set_process"):
				n.set_process(true)
			if n.has_method("resume_patrol"):
				n.resume_patrol()
			elif n.has_method("set_physics_process"):
				n.set_physics_process(true)
			elif n.has_method("set_physics_process"):
				n.set_physics_process(true)


func _nudge_to_shelter(n: Node, scene_key: String) -> void:
	var target: Vector2 = SCENE_SHELTER.get(scene_key, Vector2(640, 480))
	# Prefer nearest building sprite if WeatherBuildingFx roots exist.
	var host := get_tree().current_scene
	if host:
		var best := target
		var best_d := 1e12
		for spr in _collect_building_sprites(host):
			var d: float = (spr.global_position - (n as Node2D).global_position).length_squared() if n is Node2D else 1e12
			if d < best_d:
				best_d = d
				best = spr.global_position + Vector2(0, 28)
		target = best
	if n is Node2D:
		(n as Node2D).global_position = target


func _collect_building_sprites(host: Node) -> Array[Sprite2D]:
	var out: Array[Sprite2D] = []
	_scan_buildings(host, out)
	return out


func _scan_buildings(node: Node, out: Array[Sprite2D]) -> void:
	if node is Sprite2D and (node as Sprite2D).texture != null:
		var path := str((node as Sprite2D).texture.resource_path).replace("\\", "/").to_lower()
		if "/buildings/" in path:
			out.append(node as Sprite2D)
	for c in node.get_children():
		_scan_buildings(c, out)
