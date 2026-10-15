@tool
extends Node2D

const Spring = preload("res://src/spring.gd")
const Atlas = preload("res://src/atlas.gd")
@export_enum("Coral", "Gold", "Mint") var species := 0
@export var cap_width := 64.0
@export var stalk_height := 30.0
@export var phase := 0.0
var spring = Spring.new()
var sway := 0.0
var sway_speed := 0.0
var glow := 0.0
var pulse_count := 0
var _shape_key := ""
var cap_mask: Image
var cap_joint := Vector2.ZERO

func _ready() -> void:
	refresh()

func refresh() -> void:
	if not is_node_ready():
		return
	$Cap.texture = Atlas.sprite(species, Vector2i(int(cap_width), int(cap_width * 0.52)))
	cap_mask = $Cap.texture.get_image() if $Cap.texture else null
	# Find the actual underside, then bury the stem tip inside the cap.
	# Both pieces share this joint even when the cap is compressed or leaning.
	if cap_mask:
		var center_x := cap_mask.get_width() / 2
		for y in range(cap_mask.get_height() - 1, -1, -1):
			if cap_mask.get_pixel(center_x, y).a > 0.8:
				cap_joint = Vector2(center_x + 0.5, maxf(0.5, y - 2.5)) - Vector2(cap_mask.get_size()) * 0.5
				break
	$Stalk.texture = Atlas.sprite(3, Vector2i(int(cap_width * 0.32), int(stalk_height + 10)))
	$Stalk.offset = Vector2(0, -$Stalk.texture.get_height() / 2.0) if $Stalk.texture else Vector2.ZERO
	$SupportArea/Shape.shape.radius = cap_width * 0.41
	_shape_key = str(species) + str(cap_width) + str(stalk_height)
	var material_factor := 1.17 if species == 2 else (0.9 if species == 0 else 1.0)
	spring.stiffness = clampf(92.0 * pow(48.0 / cap_width, 0.6) * material_factor, 55, 160)
	spring.damping = sqrt(spring.stiffness) * 0.79

func _process(_dt: float) -> void:
	z_index = roundi(position.y)
	if Engine.is_editor_hint() and _shape_key != str(species) + str(cap_width) + str(stalk_height):
		refresh()
	var q: float = spring.displacement
	$Cap.transform = cap_transform()
	if $Stalk.texture:
		var joint: Vector2 = $Cap.transform * cap_joint
		var tip_distance: float = $Stalk.texture.get_height() - 0.5
		# The base stays at the ground origin. Stretch and shear up to the joint.
		$Stalk.transform = Transform2D(Vector2(1.0 + q * 0.16, 0), -joint / tip_distance, Vector2.ZERO)
	$Cap.self_modulate = Color(1.0, 1.0 + glow * 0.14, 1.0 + glow * 0.10)
	queue_redraw()

func advance(dt: float, load_force: float) -> void:
	spring.step(dt, load_force)
	sway_speed += (-35.0 * sway - 5.0 * sway_speed) * dt
	sway += sway_speed * dt
	glow = maxf(0.0, glow - dt * 1.8)

func surface_height() -> float:
	return stalk_height * (1.0 - spring.displacement * 0.5)

func bounce_rise(standing_load: float) -> float:
	# Extra compression stores energy; a broad cap gives a stronger launch.
	var stored := clampf((spring.displacement - standing_load) / (0.58 - standing_load), 0.0, 1.0)
	return lerpf(40.0, 80.0, stored) * clampf(cap_width / 48.0, 0.5, 1.5)

func supports(point: Vector2) -> bool:
	if cap_mask == null:
		return false
	var foot := point - global_position - Vector2(0, roundf(surface_height()))
	var uv := cap_transform().affine_inverse() * foot + Vector2(cap_mask.get_size()) * 0.5
	if uv.x < 0 or uv.y < 0 or uv.x >= cap_mask.get_width() or uv.y >= cap_mask.get_height():
		return false
	return cap_mask.get_pixelv(Vector2i(uv)).a >= 0.80

func cap_transform() -> Transform2D:
	var q: float = spring.displacement
	var transform_2d := Transform2D(sway * 0.045, Vector2(roundf(sway * 3), -roundf(surface_height())))
	transform_2d.x *= 1.0 + q * 0.35
	transform_2d.y *= 1.0 - q * 0.58
	return transform_2d

func pulse(strength: float, direction: float = 1.0) -> void:
	spring.kick(strength * clampf(48.0 / cap_width, 0.65, 1.4))
	sway_speed += direction * strength * 0.65
	glow = 1.0
	pulse_count += 1

func reset() -> void:
	spring.displacement = 0.0
	spring.velocity = 0.0
	sway = 0.0
	sway_speed = 0.0
	glow = 0.0
	pulse_count = 0

func _draw() -> void:
	var r := int(cap_width * 0.4)
	for y in range(-5, 6):
		var half := int(r * sqrt(maxf(0.0, 1.0 - pow(y / 6.0, 2))))
		draw_rect(Rect2(-half, y, half * 2, 1), Color(0.05, 0.17, 0.15, 0.25))
