class_name Player
extends Node2D

@export var is_player_one: bool = true
@export var score: int = 0
var chip_scene: PackedScene = preload("res://scenes/chip.tscn")
var current_chip: Chip

func _init():
	spawn_new_chip()

func spawn_new_chip():
	current_chip = chip_scene.instantiate()
	current_chip.initialize(is_player_one)
	add_child(current_chip)
	
func get_current_chip() -> Chip:
	return current_chip
	
func remove_chip():
	remove_child(current_chip)
	
func set_player_nr(nr: int):
	if nr == 1:
		is_player_one = true
	else:
		is_player_one = false
	

func drop_chip(col, currChip):
	pass
