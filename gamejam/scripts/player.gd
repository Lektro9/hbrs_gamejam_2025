class_name Player
extends Node2D

enum PlayerId {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
@export var player_id : PlayerId = PlayerId.NEUTRAL
@export var score: int = 0
var chip_scene: PackedScene = preload("res://scenes/chip.tscn")
var current_chip: Chip

func _init():
	#player_id = PlayerId.get(p_player_id)
	pass
	#current_chip.stats = spawn_new_chip()

func init(p_player_id: int):
	player_id = p_player_id as PlayerId

func spawn_new_chip() -> ChipStats:
	var chip = chip_scene.instantiate()
	chip.initialize(player_id)
	return chip.stats
	
func get_current_chip() -> Chip:
	return current_chip
	
func remove_chip():
	remove_child(current_chip)
	
func set_player_nr(nr: int):
	player_id = PlayerId.get(nr);
	

func drop_chip(chip: ChipStats, col: int):
	GameManager.drop_chip(chip, col)
