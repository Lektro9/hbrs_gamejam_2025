extends Node
class_name ChipInstance

@export var ChipResource: Chip:
	set(value):
		ChipResource = value
		if sprite_2d and ChipResource:
			sprite_2d.texture = ChipResource.icon
@export var player_id: Chip.Ownership
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var color: Color

func _ready():
	if ChipResource:
		sprite_2d.texture = ChipResource.icon
	sprite_2d.modulate = color
	
