class_name Player
extends Node2D

enum PlayerId {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
@export var player_id : PlayerId = PlayerId.NEUTRAL
@export var score: int = 0
var chip_scene: PackedScene = preload("res://scenes/chip.tscn")
var current_chip: Chip

func _init(p_player_id: int):
	player_id = PlayerId.get(p_player_id)
	
	spawn_new_chip()

func spawn_new_chip():
	current_chip = chip_scene.instantiate()
	current_chip.initialize(player_id)
	add_child(current_chip)
	
func get_current_chip() -> Chip:
	return current_chip
	
func remove_chip():
	remove_child(current_chip)
	
func set_player_nr(nr: int):
	player_id = PlayerId.get(nr);
	

func drop_chip(chip: ChipStats, col: int):
	GameManager.game_board.drop_chip(chip, col)
