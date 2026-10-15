@tool
extends Node2D

var clock := 0.0
var demo_clock := 0.0
var demo_enabled := false
var audio_enabled := true
var waves: Array[Dictionary] = []
var bounces: Array[Dictionary] = []
var mushrooms: Array[Node] = []
var previous_charge := false
var charge_target: Node
var last_splash := 0.0
var resets := 0
var wave_events := 0
var _jump_requested := false
var _demo_jump_mark := -1
@onready var traveler = $World/Props/Traveler
@onready var effects = $World/Effects
@onready var sound = $Sound

func _ready() -> void:
	for child in $World/Props.get_children():
		if child.has_method("supports"):
			mushrooms.append(child)
	if Engine.is_editor_hint():
		return
	effects.water_query = Callable(self, "is_water")
	for action in {"left":[KEY_A, KEY_LEFT], "right":[KEY_D, KEY_RIGHT], "up":[KEY_W, KEY_UP], "down":[KEY_S, KEY_DOWN], "charge":[KEY_E], "run":[KEY_SHIFT]}:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var bindings: Dictionary = {"left":[KEY_A, KEY_LEFT], "right":[KEY_D, KEY_RIGHT], "up":[KEY_W, KEY_UP], "down":[KEY_S, KEY_DOWN], "charge":[KEY_E], "run":[KEY_SHIFT]}
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	reset_scene()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_R:
		reset_scene()
	elif event.physical_keycode == KEY_TAB:
		demo_enabled = not demo_enabled
		demo_clock = 0.0
		_demo_jump_mark = -1
	elif event.physical_keycode == KEY_M:
		audio_enabled = not audio_enabled
		sound.muted = not audio_enabled
		if not audio_enabled:
			sound.reset()
	elif event.physical_keycode == KEY_SPACE:
		_jump_requested = true
		demo_enabled = false
	elif event.physical_keycode in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_E]:
		demo_enabled = false

func _physics_process(dt: float) -> void:
	if Engine.is_editor_hint():
		return
	clock += dt
	if demo_enabled:
		demo_clock += dt
	var direction := Input.get_vector("left", "right", "up", "down")
	var charging := Input.is_action_pressed("charge")
	var running := Input.is_action_pressed("run")
	if demo_enabled:
		var c := demo_controls()
		direction = c.direction
		charging = c.charge
		running = c.run
		_jump_requested = _jump_requested or c.jump
	traveler.move_plane(dt,direction,running,is_water(traveler.position) and not traveler.airborne and traveler.height < 1.0)
	var support = support_at(traveler.position)
	var surface: float = support.surface_height() if support else 0.0
	var impact: float = traveler.move_vertical(dt, surface)
	var on_surface: bool = support != null and not traveler.airborne and not traveler.climbing
	if impact > 0.0 and support and absf(traveler.height-surface) < 1.0:
		support.pulse(minf(5.0, impact / 33.0), traveler.facing.x)
		effects.burst(support.position - Vector2(0, surface), impact / 150.0, support.species)
		sound.pop(support.species, impact / 150.0)
		if impact > 115:
			bounces.append({"due":clock + 0.12, "node":support, "speed":minf(105, impact * 0.48)})
		spread(support, minf(1.2, impact / 140.0))
	if _jump_requested and not traveler.airborne:
		if on_surface:
			traveler.launch_bounce(support.bounce_rise(traveler.foot_load))
			spread(support, 0.65)
		else:
			traveler.launch(110.0)
	_jump_requested = false
	if previous_charge and not charging and charge_target and support == charge_target and on_surface and not traveler.airborne:
		var stored: float = maxf(0.0, support.spring.displacement)
		traveler.launch_bounce(support.bounce_rise(traveler.foot_load))
		support.pulse(-1.4, 1)
		spread(support, 0.8 + stored)
		effects.burst(support.position - Vector2(0, surface), 1.2, support.species)
		sound.pop(support.species, 1.2)
	if charging and on_surface and not traveler.airborne:
		charge_target = support
	else:
		charge_target = null
	previous_charge = charging
	traveler.charge = clampf(support.spring.displacement / 0.58, 0, 1) if charging and on_surface and not traveler.airborne else 0.0
	for mushroom in mushrooms:
		var load_force: float = 0.0
		if mushroom == support and on_surface and not traveler.airborne:
			load_force = 0.58 if charging else traveler.foot_load
		mushroom.advance(dt, load_force)
	for wave in waves:
		if clock >= wave.due:
			wave.node.pulse(wave.force, wave.direction)
			effects.burst(wave.node.position - Vector2(0, wave.node.surface_height()), wave.force * 0.14, wave.node.species)
	waves = waves.filter(func(w): return w.due > clock)
	for bounce in bounces:
		if clock >= bounce.due and support == bounce.node and not traveler.airborne:
			traveler.launch(bounce.speed)
	bounces = bounces.filter(func(b): return b.due > clock)
	if traveler.airborne:
		traveler.charge = 0.0
		charge_target = null
	traveler.update_depth(support)
	if is_water(traveler.position) and not traveler.airborne and traveler.height < 1.0 and traveler.velocity.length() > 8 and clock-last_splash > 0.16:
		effects.splash(traveler.position)
		last_splash = clock
	effects.advance(dt)
	for prop in $World/Props.get_children():
		if prop.has_method("wind"):
			prop.wind(clock)
	$HUD.update_state(self, support)

func support_at(point: Vector2) -> Node:
	var best: Node
	for mushroom in mushrooms:
		if mushroom.supports(point) and (best == null or mushroom.surface_height() > best.surface_height()):
			best = mushroom
	return best

func is_water(point: Vector2) -> bool:
	return $World/Ground.is_water(point)

func spread(origin: Node, strength: float) -> void:
	wave_events += 1
	for target in mushrooms:
		var distance: float = origin.position.distance_to(target.position)
		if target != origin and distance < 165:
			waves.append({"due":clock + 0.09 + distance / 220.0, "node":target, "force":strength * (1.0 - distance / 175) * 2.5, "direction":signf(target.position.x - origin.position.x)})

func demo_controls() -> Dictionary:
	var t := fmod(demo_clock, 12.0)
	var target: Vector2 = $World/Props/Coral1.position
	var charge := t >= 1.2 and t < 2.7
	var jump := false
	if t >= 4.0 and t < 7.2:
		target = $World/Props/Gold2.position
		if t > 5.3 and _demo_jump_mark != int(demo_clock / 12.0):
			jump = true
			_demo_jump_mark = int(demo_clock / 12.0)
	elif t >= 9.0:
		target = Vector2(278, 272)
	var direction: Vector2 = (target - traveler.position).normalized() if target.distance_to(traveler.position) > 3 else Vector2.ZERO
	return {"direction":direction, "charge":charge, "run":t > 7.2 and t < 8.8, "jump":jump}

func reset_scene() -> void:
	clock = 0.0
	demo_clock = 0.0
	demo_enabled = false
	waves.clear()
	bounces.clear()
	previous_charge = false
	charge_target = null
	_jump_requested = false
	_demo_jump_mark = -1
	last_splash = 0.0
	wave_events = 0
	for mushroom in mushrooms:
		mushroom.reset()
	traveler.reset(Vector2(279, 254))
	effects.reset()
	sound.reset()
	for prop in $World/Props.get_children():
		if prop.has_method("wind"):
			prop.wind(0.0)
	resets += 1

func snapshot() -> Dictionary:
	var deformation := []
	for m in mushrooms:
		deformation.append({"name":m.name, "q":m.spring.displacement, "v":m.spring.velocity, "pulses":m.pulse_count})
	return {"clock":clock, "position":str(traveler.position), "height":traveler.height, "airborne":traveler.airborne, "landings":traveler.landings, "launches":traveler.launch_count, "waves":waves.size(), "wave_events":wave_events, "spores":effects.spores.size(), "resets":resets, "mushrooms":deformation}
