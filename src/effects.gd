extends Node2D
var spores: Array[Dictionary] = []
var ripples: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
var water_query: Callable
var water_clock := 0.0

func _ready() -> void:
	rng.seed = 62014

func burst(point: Vector2, strength: float, species: int) -> void:
	var colors := [Color("ffe5a0"), Color("fff0af"), Color("a6e9ce")]
	var count := clampi(int(10 + strength * 14), 8, 38)
	for i in range(count):
		spores.append({"p":point + Vector2(rng.randf_range(-15, 15), 0), "v":Vector2(rng.randf_range(-24, 24), rng.randf_range(-42, -15)), "age":0.0, "life":rng.randf_range(0.6, 1.8), "size":1 if i % 3 else 2, "color":colors[species]})
	while spores.size() > 240:
		spores.pop_front()

func splash(point: Vector2) -> void:
	ripples.append({"p":point, "age":0.0})

func advance(dt: float) -> void:
	water_clock += dt
	for s in spores:
		s.age += dt
		s.p += s.v * dt
		s.v += Vector2(6, 9) * dt
	spores = spores.filter(func(s): return s.age < s.life)
	for r in ripples:
		r.age += dt
	ripples = ripples.filter(func(r): return r.age < 0.7)
	queue_redraw()

func reset() -> void:
	spores.clear()
	ripples.clear()
	rng.seed = 62014
	water_clock = 0.0

func _draw() -> void:
	for i in range(14):
		var p := Vector2(560+posmod(i*31,77),120+posmod(i*29,88))
		p.x += roundf(sin(water_clock*0.5+i)*2)
		var c := Color(0.42,0.67,0.58,0.12+0.12*sin(water_clock+i))
		for x in range(3+i%4):
			if water_query.is_valid() and water_query.call(p+Vector2(x,0)):
				draw_rect(Rect2(p+Vector2(x,0),Vector2.ONE),c)
	for s in spores:
		var c: Color = s.color
		c.a = clampf((s.life - s.age) * 2.0, 0.0, 0.9)
		draw_rect(Rect2(s.p.round(), Vector2.ONE * s.size), c)
	for r in ripples:
		var radius := 3 + int(r.age * 22)
		var c := Color(0.45, 0.79, 0.73, (1.0 - r.age / 0.7) * 0.6)
		for i in range(28):
			var angle := TAU * i / 28.0
			var p: Vector2 = r.p + Vector2(cos(angle) * radius, sin(angle) * radius * 0.4)
			if water_query.is_valid() and water_query.call(p):
				draw_rect(Rect2(p.round(), Vector2.ONE), c)
