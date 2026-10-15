extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		printerr("FAIL: " + message)

func key(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func run() -> void:
	var packed := load("res://scenes/meadow.tscn") as PackedScene
	if packed == null:
		printerr("FAIL: main scene missing")
		quit(1)
		return
	var world = packed.instantiate()
	root.add_child(world)
	await process_frame
	check(world.mushrooms.size() == 14, "14 mushrooms must load")
	for layer in ["Grass", "Footpath", "Water"]:
		check(world.get_node("World/Ground/" + layer) is TileMapLayer, "editable terrain: " + layer)
	var mushroom = world.get_node("World/Props/Coral1")
	check(mushroom.get_node("Cap").texture != null, "mushroom pixels load")
	check(world.traveler.get_node("Sprite").texture != null, "CC0 character loads")
	check(ResourceLoader.exists("res://assets/fonts/NotoSansSC.ttf"), "runtime font included")
	world.traveler.reset(mushroom.position)
	world.traveler.height = mushroom.surface_height()
	key(KEY_E, true)
	for frame in range(180):
		await physics_frame
	check(mushroom.spring.displacement > 0.5, "E compresses the cap")
	check(world.traveler.charge > 0.8, "standing charge reaches full strength")
	var start_height: float = world.traveler.height
	key(KEY_E, false)
	var peak: float = start_height
	for frame in range(210):
		await physics_frame
		peak = maxf(peak, world.traveler.height)
		var cap = mushroom.get_node("Cap")
		var stalk = mushroom.get_node("Stalk")
		var expected_tip: Vector2 = cap.transform * mushroom.cap_joint
		var actual_tip: Vector2 = stalk.transform * Vector2(0, -(stalk.texture.get_height() - 0.5))
		check(expected_tip.distance_to(actual_tip) < 0.01, "cap and stalk remain joined")
		check(stalk.transform.origin.length() < 0.01, "stalk base stays on ground")
	check(world.traveler.launch_count > 0, "release launches the traveler")
	check(peak > start_height + 60, "large mushroom produces a visible high launch")
	check(world.wave_events > 0, "release sends a neighbor wave")
	var neighbor_pulses := 0
	for neighbor in world.mushrooms:
		if neighbor != mushroom:
			neighbor_pulses += neighbor.pulse_count
	check(neighbor_pulses > 0, "neighbor pulses execute after their delay")
	key(KEY_R, true)
	key(KEY_R, false)
	await physics_frame
	await physics_frame
	check(world.waves.is_empty() and world.bounces.is_empty(), "reset clears pending events")
	check(world.effects.spores.is_empty(), "reset clears spores")
	check(world.traveler.launch_count == 0, "reset clears launch state")
	print(JSON.stringify({"ok":failures.is_empty(), "failures":failures, "mushrooms":world.mushrooms.size(), "peak_height":peak, "rise_above_support":peak-start_height, "neighbor_pulses":neighbor_pulses}))
	quit(0 if failures.is_empty() else 1)
