@tool
extends RefCounted

static var textures: Dictionary = {}
const PixelMushroom = preload("res://src/pixel_mushroom.gd")
const ROOT := "res://assets/cc0/ninja-adventure/"

static func sprite(cell: int, limit: Vector2i) -> Texture2D:
	var key := str(cell) + ":" + str(limit)
	if textures.has(key):
		return textures[key]
	var part: Image
	if cell < 3:
		part = PixelMushroom.image(cell)
	elif cell == 3:
		part = PixelMushroom.stalk()
	else:
		var file := "props.png"
		var region := Rect2i(0,96,64,48)
		if cell == 5:
			region = Rect2i(112,80,32,16)
		elif cell == 6:
			file = "grass.png"
			region = Rect2i(0,0,16,16)
		elif cell == 7:
			file = "water.png"
			region = Rect2i(0,0,16,16)
		elif cell == 16:
			region = Rect2i(64,96,32,48)
		elif cell >= 8 and cell < 16:
			file = "traveler.png"
			var column: int = [0,1,3,2][(cell-8)%4]
			region = Rect2i(column*16,16 if cell >= 12 else 0,16,16)
		if not ResourceLoader.exists(ROOT+file):
			return null
		var source: Image = load(ROOT+file).get_image()
		if source.is_compressed():
			source.decompress()
		part = source.get_region(region)
	var bounds := part.get_used_rect()
	if bounds.size.x < 2 or bounds.size.y < 2:
		return null
	part = part.get_region(bounds)
	if cell < 3:
		part.resize(limit.x, limit.y, Image.INTERPOLATE_NEAREST)
	else:
		# Preserve square source-art pixels at an integer scale.
		var fit := maxi(1,int(minf(float(limit.x)/part.get_width(),float(limit.y)/part.get_height())))
		part.resize(part.get_width()*fit,part.get_height()*fit,Image.INTERPOLATE_NEAREST)
	var texture := ImageTexture.create_from_image(part)
	textures[key] = texture
	return texture
