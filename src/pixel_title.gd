extends Node2D
const LETTERS = {
"A":[14,17,17,31,17,17,17],"B":[30,17,17,30,17,17,30],"C":[15,16,16,16,16,16,15],"D":[30,17,17,17,17,17,30],"E":[31,16,16,30,16,16,31],
"F":[31,16,16,30,16,16,16],"G":[14,17,16,23,17,17,15],"I":[31,4,4,4,4,4,31],"J":[7,2,2,2,18,18,12],"K":[17,18,20,24,20,18,17],"L":[16,16,16,16,16,16,31],"N":[17,25,25,21,19,19,17],"P":[30,17,17,30,16,16,16],"Q":[14,17,17,17,21,18,13],"T":[31,4,4,4,4,4,4],"V":[17,17,17,17,17,10,4],"X":[17,17,10,4,10,17,17],"Y":[17,17,10,4,4,4,4],"Z":[31,1,2,4,8,16,31],
"H":[17,17,17,31,17,17,17],"M":[17,27,21,21,17,17,17],"O":[14,17,17,17,17,17,14],
"R":[30,17,17,30,20,18,17],"S":[15,16,16,14,1,1,30],"U":[17,17,17,17,17,17,14],
"W":[17,17,17,21,21,21,10],"/":[1,1,2,4,8,16,16],".":[0,0,0,0,0,6,6],"-":[0,0,0,31,0,0,0]}
var text := "MUSHROOM MEADOW"
var pixel_size := 2
func change(value: String) -> void:
	if value != text:
		text = value
		queue_redraw()
func _draw() -> void:
	var x := 0
	for letter in text:
		if letter == " ":
			x += 4 * pixel_size
			continue
		var rows: Array = LETTERS.get(letter, [0,0,0,0,0,0,0])
		for y in range(7):
			for bit in range(5):
				if rows[y] & (1 << (4 - bit)):
					draw_rect(Rect2(x + bit * pixel_size + 1, y * pixel_size + 1, pixel_size, pixel_size), Color("123027"))
					draw_rect(Rect2(x + bit * pixel_size, y * pixel_size, pixel_size, pixel_size), Color("ffe6a5"))
		x += 6 * pixel_size
