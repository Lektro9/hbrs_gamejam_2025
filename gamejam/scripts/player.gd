class_name Player
extends Node2D

@export var is_player_one: bool = true
@export var score: int = 0

@export var chip_stack: Array = []
@export var chip_scene: PackedScene = preload("res://scenes/chip.tscn")

const STACK_SIZE = 20

func get_chip():
	var chip = chip_scene.instantiate()
	chip.initialize(is_player_one)
	add_child(chip)

func drop_chip(col, currChip):
	pass
