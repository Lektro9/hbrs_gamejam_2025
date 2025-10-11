extends Node2D

@export var target_y : float
@export var stats: ChipStats
@export var img_blue: Texture2D = preload("res://images/blue_chip.png")
@export var img_red: Texture2D = preload("res://images/red_chip.png")

@onready var sprite_2d: Sprite2D = $Sprite2D

func initialize(is_player_one: bool) -> void:
	if is_player_one:
		print("loading blue")
		#sprite_2d.texture = img_blue
	else:
		print("loading red")
		#sprite_2d.texture = img_red

func _physics_process(delta: float) -> void:
	if position.y < target_y:
		position.y += $RigidBody2D.gravity_scale * 400 * delta
		if position.y > target_y:
			position.y = target_y
