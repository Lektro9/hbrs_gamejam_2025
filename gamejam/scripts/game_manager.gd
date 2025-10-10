extends Node2D
@onready var state_chart_debugger: MarginContainer = $StateChartDebugger
@onready var state_chart: StateChart = $StateChart
@onready var debug_ui: CanvasLayer = $DebugUi

var currentPlayer = 1 # Player 1 and 2
var testColor = Color(0.955, 0.1, 0.35, 1.0)

func _ready() -> void:
	if not OS.is_debug_build():
		debug_ui.hide()
		state_chart_debugger.hide()

func togglePlayer():
	if currentPlayer == 1:
		currentPlayer = 2
	else:
		currentPlayer = 1

func start_game():
	state_chart.send_event("start_game")

func drop_chip():
	state_chart.send_event("dropping_chip")

func restart_game():
	state_chart.set_expression_property("is_game_won", false)
	state_chart.send_event("restart_game")

func set_is_game_won_expression(is_game_won: bool):
	state_chart.set_expression_property("is_game_won", is_game_won)
