extends Node2D

signal initialize_game_board

@onready var state_chart_debugger: MarginContainer = $StateChartDebugger
@onready var state_chart: StateChart = $StateChart
@onready var debug_ui: CanvasLayer = $DebugUi

var player_1: Player
var player_2: Player
var game_board: GameBoardData
var player_one_plays = true # true for player 1, false for player 2
var testColor = Color(0.955, 0.1, 0.35, 1.0)

func _ready() -> void:
	if not OS.is_debug_build():
		debug_ui.hide()
		state_chart_debugger.hide()
		
	# Initialising players
	var player_scene = preload("res://scenes/player.tscn")
	player_1 = player_scene.instantiate() as Player
	player_2 = player_scene.instantiate() as Player
	
	player_1.init(1)
	player_2.init(2)
	
	game_board = GameBoardData.new(8, 8)

func togglePlayer(): player_one_plays != player_one_plays

func start_game():
	state_chart.send_event("start_game")

	#player_1.spawn_new_chip()
	#game_board.drop_chip(player_1.get_current_chip().stats, 0)

	game_board = GameBoardData.new(8, 8)
	player_one_plays = true
	print("new game")

func drop_chip(curr_chip: ChipStats, col: int):
	state_chart.send_event("dropping_chip")
	
	game_board.drop_chip(curr_chip.stats, col)
	game_board.update()
	var scores := game_board.get_team_scores()
	print(scores)
	togglePlayer()

func restart_game():
	state_chart.set_expression_property("is_game_won", false)
	state_chart.send_event("restart_game")
	
	game_board = GameBoardData.new(8, 8)

func set_is_game_won_expression(is_game_won: bool):
	state_chart.set_expression_property("is_game_won", is_game_won)

func _on_init_state_entered() -> void:
	initialize_game_board.emit()
