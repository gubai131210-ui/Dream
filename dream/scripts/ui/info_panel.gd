class_name InfoPanel
extends CanvasLayer

@onready var _title: Label = $Root/Panel/Margin/VBox/Title
@onready var _body: Label = $Root/Panel/Margin/VBox/Body
@onready var _close: Button = $Root/Panel/Margin/VBox/Close


func _ready() -> void:
	visible = false
	_close.pressed.connect(hide_info)
	DreamUI.polish_area(get_parent(), _scene_title())
	DreamUI.polish_info_panel(self)


func show_info(title: String, body: String) -> void:
	_title.text = title
	_body.text = body
	visible = true
	var panel := $Root/Panel as Control
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.96, 0.96)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_SINE)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_info() -> void:
	visible = false


func _scene_title() -> String:
	var root := get_parent()
	if root == null:
		return "Dream"
	var titles := {
		"VillageSquare": "村庄广场",
		"VillageResidential": "住宅区",
		"FarmResidential": "农场住宅",
		"Farmland": "农田",
		"MarketStreet": "商业街",
		"ForestEntrance": "森林入口",
		"ForestDeep": "深林",
		"Station": "车站",
		"River": "河流",
		"Waterfall": "瀑布",
		"HillFarm": "山坡农田",
		"Lake": "湖泊",
		"Lighthouse": "灯塔",
		"LakeHouse": "湖畔小屋",
		"C01HomeInterior": "主角住宅",
		"C02ElderInterior": "老人宅",
		"C02FarmerInterior": "农家宅",
		"C02MerchantInterior": "商贾宅",
		"C02BlacksmithHomeInterior": "铁匠宅",
		"C03BarnInterior": "谷仓",
		"C03CoopInterior": "鸡舍",
		"C04GroceryInterior": "杂货店",
		"C04SmithInterior": "铁匠铺",
		"C04TavernInterior": "酒馆",
	}
	return str(titles.get(root.name, root.name))


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_info()
		get_viewport().set_input_as_handled()
