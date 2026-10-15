extends SceneTree

# Authored route spans. No randomized map or flattened terrain image.
const PATH_ROWS := [[18,20],[18,20],[18,20],[18,20],[18,20],[19,21],[20,22],[21,24],[23,26],[25,27],[26,28],[26,28],[27,29],[27,29],[28,30],[29,31],[30,32],[31,33],[32,34],[33,35],[34,36],[35,37],[36,38]]
var pond := PackedVector2Array([Vector2(640,92),Vector2(601,104),Vector2(563,116),Vector2(550,141),Vector2(535,155),Vector2(540,191),Vector2(566,209),Vector2(603,216),Vector2(640,222)])

func _initialize() -> void:
	call_deferred("run")

func add_layer(parent: Node2D,label: String,tileset: TileSet) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = label
	layer.tile_set = tileset
	parent.add_child(layer)
	layer.owner = parent
	return layer

func run() -> void:
	var terrain := Node2D.new()
	terrain.name = "Ground"
	terrain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	terrain.set_script(load("res://src/ground.gd"))
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16,16)
	tileset.add_terrain_set()
	tileset.set_terrain_set_mode(0,TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	for label in ["Meadow","Worn path"]:
		tileset.add_terrain(0)
		tileset.set_terrain_name(0,tileset.get_terrains_count(0)-1,label)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/cc0/ninja-adventure/floor.png")
	source.texture_region_size = Vector2i(16,16)
	tileset.add_source(source,0)
	var definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cc0/ninja-adventure/floor-terrains.json"))["cells"]
	var neighbors := {"right_side":TileSet.CELL_NEIGHBOR_RIGHT_SIDE,"bottom_right_corner":TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,"bottom_side":TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,"bottom_left_corner":TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,"left_side":TileSet.CELL_NEIGHBOR_LEFT_SIDE,"top_left_corner":TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,"top_side":TileSet.CELL_NEIGHBOR_TOP_SIDE,"top_right_corner":TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER}
	for key in definitions:
		var xy: PackedStringArray = key.split(",")
		var coord := Vector2i(int(xy[0]),int(xy[1]))
		source.create_tile(coord)
		var data := source.get_tile_data(coord,0)
		data.terrain_set = 0
		var def: Dictionary = definitions[key]
		data.terrain = int(def.get("terrain",0))
		for property in def:
			if property.begins_with("terrains_peering_bit/"):
				data.set_terrain_peering_bit(neighbors[property.get_slice("/",1)],int(def[property]))
	ResourceSaver.save(tileset,"res://assets/cc0/meadow-tileset.tres")
	var grass := add_layer(terrain,"Grass",tileset)
	var all: Array[Vector2i] = []
	var path: Array[Vector2i] = []
	for y in range(23):
		for x in range(40):
			all.append(Vector2i(x,y))
			if x >= PATH_ROWS[y][0] and x <= PATH_ROWS[y][1]:
				path.append(Vector2i(x,y))
	grass.set_cells_terrain_connect(all,0,0,false)
	grass.set_cells_terrain_connect(path,0,1,false)
	# Sparse authored texture variation: mostly quiet turf, occasional grass marks.
	for coord in grass.get_used_cells():
		if grass.get_cell_tile_data(coord).terrain == 0:
			var choice := posmod(coord.x*31+coord.y*47+coord.x*coord.y*7,19)
			grass.set_cell(coord,0,Vector2i(4,12) if choice < 12 else [Vector2i(2,11),Vector2i(3,11),Vector2i(0,12),Vector2i(1,12),Vector2i(2,12),Vector2i(3,12)][choice%6])
	var footpath := add_layer(terrain,"Footpath",tileset)
	for coord in grass.get_used_cells():
		var data := grass.get_cell_tile_data(coord)
		if data and data.terrain == 1:
			footpath.set_cell(coord,0,grass.get_cell_atlas_coords(coord))
			grass.erase_cell(coord)
	# Hand-placed pond outline on an 8px grid, with shore-aware tile variants.
	var water_set := TileSet.new()
	water_set.tile_size = Vector2i(8,8)
	var pixels := Image.create(128,8,false,Image.FORMAT_RGBA8)
	for mask in range(16):
		for y in range(8):
			for x in range(8):
				var shore: bool = ((mask & 1) != 0 and x < 2) or ((mask & 2) != 0 and x > 5) or ((mask & 4) != 0 and y < 2) or ((mask & 8) != 0 and y > 5)
				var color := Color("407e70") if shore else Color("286661")
				if shore and (x+y)%3 == 0:
					color = Color("73a184")
				pixels.set_pixel(mask*8+x,y,color)
	var water_source := TileSetAtlasSource.new()
	water_source.texture = ImageTexture.create_from_image(pixels)
	water_source.texture_region_size = Vector2i(8,8)
	water_set.add_source(water_source,0)
	for mask in range(16):
		water_source.create_tile(Vector2i(mask,0))
	var water := add_layer(terrain,"Water",water_set)
	var pond_cells: Dictionary = {}
	for y in range(10,29):
		for x in range(65,80):
			if Geometry2D.is_point_in_polygon(Vector2(x*8+4,y*8+4),pond):
				pond_cells[Vector2i(x,y)] = true
	for coord: Vector2i in pond_cells:
		var mask := 0
		for i in range(4):
			if not pond_cells.has(coord + [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN][i]):
				mask |= 1 << i
		water.set_cell(coord,0,Vector2i(mask,0))
	ResourceSaver.save(water_set,"res://assets/cc0/pond-tileset.tres")
	var scene := PackedScene.new()
	var result := scene.pack(terrain)
	if result == OK:
		result = ResourceSaver.save(scene,"res://scenes/terrain.tscn")
	print("TERRAIN authored grass=",grass.get_used_cells().size()," path=",footpath.get_used_cells().size()," water=",water.get_used_cells().size()," result=",result)
	terrain.free()
	quit(0 if result == OK else 1)
