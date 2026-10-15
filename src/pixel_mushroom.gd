@tool
extends RefCounted

# Fixed, code-native pixel art: stepped silhouette and deliberately placed spots.
static func image(species: int) -> Image:
	var im := Image.create(32,16,false,Image.FORMAT_RGBA8)
	var outline := Color("4b3b32")
	var dark: Color = [Color("934338"),Color("a77939"),Color("467a60")][species]
	var body: Color = [Color("c95848"),Color("dfa449"),Color("78a77a")][species]
	var light: Color = [Color("e18459"),Color("f2c56d"),Color("a8c995")][species]
	var spans := [Vector2i(13,18),Vector2i(10,21),Vector2i(8,23),Vector2i(6,25),Vector2i(4,27),Vector2i(3,28),Vector2i(2,29),Vector2i(1,30),Vector2i(0,31),Vector2i(0,31),Vector2i(1,30)]
	for y in range(spans.size()):
		for x in range(spans[y].x,spans[y].y+1):
			var c := body if y < 8 else dark
			if x == spans[y].x or x == spans[y].y or y == 0:
				c = outline
			elif y < 5 and x < 16:
				c = light
			im.set_pixel(x,y,c)
	for spot in [Rect2i(12,2,3,2),Rect2i(6,5,4,2),Rect2i(20,4,3,2),Rect2i(14,7,4,2),Rect2i(24,8,3,1),Rect2i(3,8,3,1)]:
		for y in range(spot.position.y,spot.end.y):
			for x in range(spot.position.x,spot.end.x):
				im.set_pixel(x,y,Color("ffe0a1"))
	for y in range(11,14):
		var inset: int = [3,7,11][y-11]
		for x in range(inset,32-inset):
			var c := Color("caa775")
			if x%4 == 0:
				c = Color("e9cb94")
			if x == inset or x == 31-inset or y == 13:
				c = outline
			im.set_pixel(x,y,c)
	return im

static func stalk() -> Image:
	var im := Image.create(8,20,false,Image.FORMAT_RGBA8)
	for y in range(20):
		var left := 2 if y < 15 else (1 if y < 18 else 0)
		var right := 5 if y < 15 else (6 if y < 18 else 7)
		for x in range(left,right+1):
			var c := Color("e9cb94") if x < 4 else Color("caa775")
			if x == left or x == right or y == 19:
				c = Color("806544")
			im.set_pixel(x,y,c)
	return im
