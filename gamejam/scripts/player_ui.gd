extends CanvasLayer
@onready var player_1_score: RichTextLabel = %Player1Score
@onready var player_2_score: RichTextLabel = %Player2Score
@onready var score_board: HBoxContainer = %ScoreBoard
@onready var score_input: LineEdit = %ScoreInput
@onready var grid_x_input: LineEdit = %GridXInput
@onready var grid_y_input: LineEdit = %GridYInput
@onready var next_chip: Label = %NextChip
@onready var next_chip_container: VBoxContainer = %NextChipContainer
@onready var area_2d: Area2D = %Area2D
@onready var hover_panel: Panel = %HoverPanel
@onready var chip_desc: RichTextLabel = %ChipDesc

func _ready() -> void:
	GameManager.update_player_score.connect(update_score_labels)
	GameManager.game_over.connect(set_up_game_over)
	GameManager.show_score_board.connect(func(should_show): %ScoreBoard.visible = should_show)
	GameManager.show_main_menu.connect(func(should_show): %MainMenu.visible = should_show)
	GameManager.show_chip_value.connect(show_chip_label)
	GameManager.update_curr_chip.connect(update_chip_label)
	
func update_score_labels(scores):
	var p1_score = scores.get(Chip.Ownership.PLAYER_ONE)
	var p2_score = scores.get(Chip.Ownership.PLAYER_TWO)
	player_1_score.set_final_value(p1_score)
	player_2_score.set_final_value(p2_score)

func set_up_game_over(player_id: int, shouldShow: bool):
	if shouldShow:
		%GameOver.show()
	else:
		%GameOver.hide()
	%ResultText.text = "[wave amp=50.0 freq=5.0 connected=1]Player " + str(player_id) + " has won![/wave]"

func start_game():
	GameManager.score_needed = int(score_input.text)
	GameManager.BOARD_WIDTH = int(grid_x_input.text)
	GameManager.BOARD_HEIGHT = int(grid_y_input.text)
	GameManager.start_game()

func restart_game():
	GameManager.state_chart.send_event("restart_game")

func _on_score_sub_pressed() -> void:
	score_input.text = str(int(score_input.text) - 1)

func _on_score_add_pressed() -> void:
	score_input.text = str(int(score_input.text) + 1)

func update_chip_label(chip: ChipInstance) -> void:
	var double = chip.duplicate()
	for child in %SpawnMarker.get_children():
		child.queue_free()
	%SpawnMarker.add_child(double)
	chip_desc.text = double.ChipResource.description
	pass
	
func show_chip_label(show):
	next_chip.visible = show

func _on_area_2d_mouse_entered() -> void:
	hover_panel.visible = true

func _on_area_2d_mouse_exited() -> void:
	hover_panel.visible = false
