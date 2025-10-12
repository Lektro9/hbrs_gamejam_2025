extends Node2D

@onready var state_chart: StateChart = $StateChart
@onready var debug_ui: CanvasLayer = $DebugUi
@onready var state_chart_debugger: MarginContainer = $DebugUi/StateChartDebugger
const CHIP_INSTANCE = preload("uid://dcmnbaonn5a5p")
const DEFAULT_CHIP = preload("uid://by11wc80p4n7w")

var player_1: Player
var player_2: Player
var game_board: GameBoardData
var does_player_one_play = true # true for player 1, false for player 2
var chosen_column: int

func _ready() -> void:
	if not OS.is_debug_build():
		debug_ui.hide()
		state_chart_debugger.hide()
		
	# Initialising players
	player_1 = Player.new(1, Color(0.72, 0.162, 0.185, 1.0))
	player_2 = Player.new(2, Color(0.158, 0.353, 0.849, 1.0))
	
	
func get_player() -> Player:
	if does_player_one_play:
		return player_1
	else:
		return player_2

func switch_player(): 
	does_player_one_play = !does_player_one_play

func start_game():
	state_chart.send_event("start_game")

func drop_chip(col: int):
	chosen_column = col
	state_chart.send_event("dropping_chip")

func restart_game():
	state_chart.set_expression_property("is_game_won", false)
	state_chart.send_event("restart_game")
	
func set_is_game_won_expression(is_game_won: bool):
	state_chart.set_expression_property("is_game_won", is_game_won)

func _on_init_state_entered() -> void:
	game_board = GameBoardData.new(4, 8)
	does_player_one_play = true
	print("new game")
	

func _on_drop_chip_state_entered() -> void:
	game_board.drop_chip(get_player().current_chip, chosen_column)


func _on_check_win_state_entered() -> void:
	var scores := game_board.get_team_scores()
	print(scores)
	
func _on_switch_player_state_entered() -> void:
		switch_player()


func _on_player_turn_state_entered() -> void:
	var current_player = get_player()
	var current_chip:ChipInstance = CHIP_INSTANCE.instantiate()
	current_chip.ChipResource = DEFAULT_CHIP
	current_chip.player_id = current_player.player_id
	current_chip.color = current_player.color
	current_player.current_chip = current_chip
