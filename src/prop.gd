@tool
extends Node2D
const Atlas = preload("res://src/atlas.gd")
@export_enum("Tree:4", "Rock:5", "Grass:6", "Flowers:7", "Oak:16") var atlas_cell := 4
@export var sprite_size := Vector2i(128, 160)
@export var tint := Color.WHITE
@export var solid := false
@export var flip_sprite := false
var _key := ""

func _ready() -> void:
	refresh()

func _process(_dt: float) -> void:
	z_index = roundi(position.y)
	if Engine.is_editor_hint() and _key != str(atlas_cell) + str(sprite_size) + str(tint) + str(solid) + str(flip_sprite):
		refresh()

func refresh() -> void:
	$Sprite.texture = Atlas.sprite(atlas_cell, sprite_size)
	if $Sprite.texture:
		$Sprite.offset = Vector2(0, -$Sprite.texture.get_height() / 2.0 + 4)
	$Sprite.self_modulate = tint
	$Sprite.flip_h = flip_sprite
	$Body/Shape.disabled = not solid
	_key = str(atlas_cell) + str(sprite_size) + str(tint) + str(solid) + str(flip_sprite)

func wind(time: float) -> void:
	if atlas_cell in [4,16]:
		$Sprite.rotation = roundf(sin(time * 0.65 + position.x * 0.019) * 3) / 384.0
	elif atlas_cell == 6:
		$Sprite.rotation = roundf(sin(time * 1.6 + position.x * 0.07) * 3) / 96.0
