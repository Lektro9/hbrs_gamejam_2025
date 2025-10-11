class_name Chip
extends Node2D

@export var target_y : float
@export var stats: ChipStats
@export var img_blue: Texture2D = preload("res://images/blue_chip.png")
@export var img_red: Texture2D = preload("res://images/red_chip.png")

@onready var sprite_2d: Sprite2D = $Sprite2D

func initialize(is_player_one: bool) -> void:
	_ready() 
	
	if is_player_one:
		sprite_2d.texture = img_blue
	else:
		sprite_2d.texture = img_red


func _ready():
	pass
