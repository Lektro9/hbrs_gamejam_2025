extends Node2D

signal initialize_game_board

@onready var state_chart_debugger: MarginContainer = $StateChartDebugger
@onready var state_chart: StateChart = $StateChart
@onready var debug_ui: CanvasLayer = $DebugUi

var player_1
var player_2

var game_board: GameBoardData

var player_one_plays = true # true for player 1, false for player 2
var testColor = Color(0.955, 0.1, 0.35, 1.0)

func _ready() -> void:
	if not OS.is_debug_build():
		debug_ui.hide()
		state_chart_debugger.hide()
		
	# Initialising players
	var player_scene = preload("res://scenes/player.tscn")
	player_1 = player_scene.instantiate()
	player_2 = player_scene.instantiate()
	
	game_board = GameBoardData.new(8, 8)

func togglePlayer(): player_one_plays != player_one_plays

func start_game():
	state_chart.send_event("start_game")
	
	game_board = GameBoardData.new(8, 8)

func drop_chip():
	state_chart.send_event("dropping_chip")

func restart_game():
	state_chart.set_expression_property("is_game_won", false)
	state_chart.send_event("restart_game")
	
	game_board = GameBoardData.new(8, 8)

func set_is_game_won_expression(is_game_won: bool):
	state_chart.set_expression_property("is_game_won", is_game_won)

func _on_init_state_entered() -> void:
	initialize_game_board.emit()
