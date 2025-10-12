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
@export var timer_countdown: int = -1
@onready var tween_custom: TweenCustom = $Sprite2D/TweenCustom
var already_animated = false

func _ready():
	if ChipResource:
		sprite_2d.texture = ChipResource.icon
	sprite_2d.modulate = color

func start_falling(start_position: float):
	if not already_animated:
		tween_custom.initial_value = -start_position
		tween_custom.start_tween()
		already_animated = true
