@tool
extends Node2D
@export_enum("Sign", "Fence") var kind := 0

func _ready() -> void:
	queue_redraw()

func _process(_dt: float) -> void:
	z_index = roundi(position.y)

func _draw() -> void:
	var dark := Color("4a3028")
	var wood := Color("91603c")
	var light := Color("bd8750")
	if kind == 0:
		draw_rect(Rect2(-1, -21, 4, 24), dark)
		draw_rect(Rect2(0, -21, 1, 22), light)
		draw_rect(Rect2(-15, -34, 29, 14), dark)
		draw_rect(Rect2(-13, -32, 25, 10), wood)
		draw_rect(Rect2(-11, -31, 20, 1), light)
		for y in range(5):
			var w := 2 + mini(y, 4 - y)
			draw_rect(Rect2(2, -29 + y, w, 1), Color("ffe3a0"))
		draw_rect(Rect2(-8, -28, 6, 2), Color("d56654"))
		draw_rect(Rect2(-6, -26, 2, 3), Color("f1d2a2"))
	else:
		for x in [0, 16, 34, 49]:
			draw_rect(Rect2(x - 3, -20, 6, 23), dark)
			draw_rect(Rect2(x - 1, -18, 3, 20), wood)
			draw_rect(Rect2(x - 1, -18, 1, 19), light)
		for y in [-13, -5]:
			draw_rect(Rect2(-1, y, 51, 4), dark)
			draw_rect(Rect2(0, y, 48, 2), wood)
			draw_rect(Rect2(2, y, 43, 1), light)
