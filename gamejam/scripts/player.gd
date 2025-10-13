class_name Player
extends Node2D

enum PlayerId {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
@export var player_id: PlayerId = PlayerId.NEUTRAL
@export var score: int = 0
var current_chip: ChipInstance
var chip_choices: Array[ChipInstance] = []
var selected_choice_index: int = -1
@export var color: Color

func _init(p_player_id: int, i_color: Color):
	player_id = p_player_id as PlayerId
	color = i_color
	
func remove_chip():
	current_chip = null
