@tool
extends Node2D

func is_water(point: Vector2) -> bool:
	var water: TileMapLayer = $Water
	return water.get_cell_source_id(water.local_to_map(point)) >= 0
