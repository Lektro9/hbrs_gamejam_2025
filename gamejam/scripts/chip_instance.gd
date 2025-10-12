extends Node
class_name ChipInstance

@export var ChipResource: Chip:
	set(value):
		ChipResource = value
		if sprite_2d and ChipResource:
			sprite_2d.texture = ChipResource.icon
@export var player_id: Chip.Ownership
@export var color: Color
@export var timer_countdown: int = -1
var already_animated = false
@onready var sprite_2d: Sprite2D = $Container/Sprite2D
@onready var tween_custom: TweenCustom = $Container/TweenCustom
@onready var letter: Sprite2D = %Letter
@onready var cluster_tween: TweenCustom = %ClusterTween
var is_in_cluster = false

func _ready():
	if ChipResource:
		sprite_2d.texture = ChipResource.icon
		letter.texture = ChipResource.letter
	sprite_2d.modulate = color

func start_falling(start_position: float):
	if is_in_cluster:
		cluster_tween.start_tween()
	else:
		if cluster_tween.tween != null:
			cluster_tween.tween.stop()
	if not already_animated:
		tween_custom.initial_value = -start_position
		tween_custom.start_tween()
		already_animated = true
