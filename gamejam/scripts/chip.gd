class_name Chip
extends Node2D

@export var target_y : float
@export var stats: ChipStats
@export var img_blue: Texture2D = preload("res://images/blue_chip.png")
@export var img_red: Texture2D = preload("res://images/red_chip.png")

@onready var sprite_2d: Sprite2D = $Sprite2D

func initialize(player_id: int) -> void:
	_ready()
	stats = ChipStats.new(false, player_id)
	
	if player_id == 1:
		sprite_2d.texture = img_blue
	elif player_id == 2:
		sprite_2d.texture = img_red


func _ready():
	pass
