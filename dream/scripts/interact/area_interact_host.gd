class_name AreaInteractHost
extends Node

## Outdoor proximity 「互动」parity with InteriorRoomController.
## Attach last in outdoor area `_ready` so kits mounted that frame are included via group.

const NODE_NAME := "AreaInteractHost"

var _host: Node2D
var _camera: Node2D
var _search_root: Node
var _director: InteractProximityDirector = InteractProximityDirector.new()


static func attach_to(host: Node2D, search_root: Node = null, camera: Node2D = null) -> AreaInteractHost:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as AreaInteractHost
	if existing:
		return existing
	var n := AreaInteractHost.new()
	n.name = NODE_NAME
	n._host = host
	n._camera = camera
	n._search_root = search_root if search_root != null else WorldSpawnUtil.resolve_ysort(host)
	host.add_child(n)
	return n


func _process(_delta: float) -> void:
	if _host == null or not is_instance_valid(_host):
		return
	_wire_new_hotspots()
	_director.update(_host, _camera, _search_root)


func _wire_new_hotspots() -> void:
	if _host == null or _host.get_tree() == null:
		return
	for n in _host.get_tree().get_nodes_in_group(InteractProximityDirector.GROUP_HOTSPOTS):
		if not (n is InteractableHotspot):
			continue
		var hs := n as InteractableHotspot
		if not is_instance_valid(hs):
			continue
		if hs != _host and not _host.is_ancestor_of(hs):
			continue
		if hs.has_meta("_area_interact_host_wired"):
			continue
		hs.set_meta("_area_interact_host_wired", true)
		hs.activated.connect(func(h: InteractableHotspot) -> void:
			sync_click(h)
		)


func sync_click(hotspot: InteractableHotspot) -> void:
	_director.sync_click(hotspot)


func get_executable_interact_target() -> InteractableHotspot:
	return _director.get_executable()
