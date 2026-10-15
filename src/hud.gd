extends CanvasLayer
var font := FontVariation.new()
var pixel_status: Node2D

func _ready() -> void:
	font.base_font = preload("res://assets/fonts/NotoSansSC.ttf")
	font.variation_opentype = {"wght":650.0}
	$Title.add_theme_font_override("font", font)
	$Status.add_theme_font_override("font", font)
	$Title.text = "蘑菇草坪"
	$Title.visible = false
	var title_plate := ColorRect.new()
	title_plate.position = Vector2(13, 10)
	title_plate.size = Vector2(190, 29)
	title_plate.color = Color(0.02, 0.105, 0.09, 0.90)
	title_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_plate)
	var pixel_title := Node2D.new()
	pixel_title.set_script(load("res://src/pixel_title.gd"))
	pixel_title.position = Vector2(21, 16)
	add_child(pixel_title)
	var status_plate := ColorRect.new()
	status_plate.position = Vector2(386, 11)
	status_plate.size = Vector2(240, 24)
	status_plate.color = Color(0.025, 0.10, 0.085, 0.87)
	status_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status_plate)
	move_child($Status, get_child_count() - 1)
	$Status.visible = false
	pixel_status = Node2D.new()
	pixel_status.set_script(load("res://src/pixel_title.gd"))
	pixel_status.pixel_size = 1
	pixel_status.position = Vector2(396, 20)
	add_child(pixel_status)

func update_state(scene: Node, support: Node) -> void:
	var text := "EXPLORE THE MUSHROOMS"
	if scene.traveler.airborne:
		text = "BOUNCE / SPORES"
	elif support:
		text = "HOLD E / RELEASE TO BOUNCE"
	if scene.demo_enabled:
		text = "DEMO / MOVE TO TAKE CONTROL"
	$Status.text = text
	pixel_status.change(text)
	$Charge.value = scene.traveler.charge * 100
	$Charge.visible = scene.traveler.charge > 0.02
