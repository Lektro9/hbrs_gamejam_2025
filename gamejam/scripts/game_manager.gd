extends Node2D

signal game_over(winner: int, show_win_screen: bool)
signal update_player_score(scores)
signal show_score_board(should_show: bool)
signal show_main_menu(should_show: bool)
signal init_visual_board

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
var score_needed: int = 4

func _ready() -> void:
	if not OS.is_debug_build():
		debug_ui.hide()
		state_chart_debugger.hide()
	
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
	# Initialising players
	player_1 = Player.new(1, Color(0.72, 0.162, 0.185, 1.0))
	player_2 = Player.new(2, Color(0.158, 0.353, 0.849, 1.0))
	set_is_game_won_expression(false)
	show_main_menu.emit(true)
	show_score_board.emit(false)
	game_over.emit(get_player().player_id, false)
	does_player_one_play = true
	game_board = GameBoardData.new(6, 7)
	var scores := game_board.get_team_scores()
	update_player_score.emit(scores)
	init_visual_board.emit()
	print("new game")
	

func _on_drop_chip_state_entered() -> void:
	game_board.drop_chip(get_player().current_chip, chosen_column)
	var scores := game_board.get_team_scores()
	player_1.score = scores.get(player_1.player_id)
	player_2.score = scores.get(player_2.player_id)
	update_player_score.emit(scores)
	print("Player 1 has: " + str(player_1.score))
	print("Player 2 has: " + str(player_2.score))
	

func _on_check_win_state_entered() -> void:
	if player_1.score >= score_needed:
		set_is_game_won_expression(true)
	if player_2.score >= score_needed:
		set_is_game_won_expression(true)
	
func _on_switch_player_state_entered() -> void:
		switch_player()


func _on_player_turn_state_entered() -> void:
	show_score_board.emit(true)
	show_main_menu.emit(false)
	var current_player = get_player()
	var current_chip:ChipInstance = CHIP_INSTANCE.instantiate()
	current_chip.ChipResource = DEFAULT_CHIP
	current_chip.player_id = current_player.player_id
	current_chip.color = current_player.color
	current_player.current_chip = current_chip


func _on_win_state_entered() -> void:
	game_over.emit(get_player().player_id, true)
