@tool
extends CharacterBody2D
const Atlas = preload("res://src/atlas.gd")
const GRAVITY := 300.0
var height := 0.0
var vertical_speed := 0.0
var airborne := false
var facing := Vector2.DOWN
var stride := 0.0
var charge := 0.0
var landings := 0
var launch_count := 0
var foot_load := 0.32
var climbing := false
var _frame := -1

func _ready() -> void:
	set_frame(8)

func set_frame(frame: int) -> void:
	if frame == _frame:
		return
	_frame = frame
	$Sprite.texture = Atlas.sprite(frame, Vector2i(32, 36))
	if $Sprite.texture:
		$Sprite.offset = Vector2(0, -$Sprite.texture.get_height() / 2.0 + 1)

func move_plane(dt: float, direction: Vector2, running: bool, wading: bool) -> void:
	var speed := 142.0 if running else 87.0
	if wading:
		speed *= 0.6
	velocity = direction.limit_length() * speed
	move_and_slide()
	position = position.clamp(Vector2(85, 90), Vector2(595, 326))
	if direction.length() > 0.1:
		facing = direction.normalized()
		stride += dt * (10.5 if running else 7.3)
	var frame := 8
	if absf(facing.x) > absf(facing.y):
		frame = 10 if facing.x > 0 else 11
	elif facing.y < 0:
		frame = 9
	if direction.length() > 0.1 and int(stride) % 2 == 1 and not airborne:
		frame += 4
	set_frame(frame)

func move_vertical(dt: float, surface: float) -> float:
	var impact := 0.0
	climbing = false
	if not airborne and height > surface + 2.0:
		airborne = true
		vertical_speed = 0.0
	if airborne:
		var previous_height := height
		vertical_speed -= GRAVITY * dt
		height += vertical_speed * dt
		# A cap is landable only when crossed from above. Otherwise land on grass.
		var landing_surface := surface if previous_height >= surface-1.0 else 0.0
		if height <= landing_surface and vertical_speed <= 0.0:
			impact = -vertical_speed
			height = landing_surface
			vertical_speed = 0.0
			airborne = false
			landings += 1
	else:
		height = move_toward(height, surface, dt * 160.0)
	climbing = not airborne and height < surface - 1.0
	return impact

func launch(speed: float) -> void:
	vertical_speed = speed
	airborne = true
	launch_count += 1

func launch_bounce(rise: float) -> void:
	# Leave the whole character visible below the HUD on northern mushrooms.
	var ceiling_height: float = position.y - $Sprite.texture.get_height() + 1.0 - 44.0
	var available_rise := maxf(4.0, ceiling_height - height)
	launch(sqrt(2.0 * GRAVITY * minf(rise, available_rise)))

func _process(_dt: float) -> void:
	z_index = roundi(position.y)
	$Sprite.position = Vector2(0, -roundf(height))
	$Sprite.scale = Vector2(1.0 + charge * 0.08, 1.0 - charge * 0.1)
	$Sprite.rotation = clampf(velocity.x / 142.0, -1, 1) * 0.035 if not airborne else 0.0
	queue_redraw()

func update_depth(support: Node) -> void:
	z_index = roundi(position.y)
	$Sprite.z_index = 0
	if support and height >= support.surface_height()-1.0:
		# Body draws just after its supporting cap; shadow stays at ground depth.
		# Foreground trunks/foliage still retain their own ground-based depth.
		$Sprite.z_index = maxi(0,roundi(support.position.y)+1-z_index)

func reset(point: Vector2) -> void:
	position = point
	height = 0.0
	vertical_speed = 0.0
	airborne = false
	velocity = Vector2.ZERO
	facing = Vector2.DOWN
	stride = 0.0
	charge = 0.0
	climbing = false
	landings = 0
	launch_count = 0
	z_index = roundi(position.y)
	$Sprite.z_index = 0
	set_frame(8)

func _draw() -> void:
	var altitude := clampf(height / 145.0, 0.0, 1.0)
	var size := roundi(lerpf(9.0, 4.0, altitude))
	var opacity := lerpf(0.36, 0.16, altitude)
	for y in range(-3, 4):
		var w := int(size * sqrt(maxf(0.0, 1.0 - pow(y / 4.0, 2))))
		draw_rect(Rect2(-w, y, w * 2, 1), Color(0.05, 0.13, 0.12, opacity))
