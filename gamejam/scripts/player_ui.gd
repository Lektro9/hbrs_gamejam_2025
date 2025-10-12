extends CanvasLayer
@onready var player_1_score: RichTextLabel = %Player1Score
@onready var player_2_score: RichTextLabel = %Player2Score
@onready var score_board: HBoxContainer = %ScoreBoard

func _ready() -> void:
	GameManager.update_player_score.connect(update_score_labels)
	GameManager.game_over.connect(set_up_game_over)
	GameManager.show_score_board.connect(func(should_show): %ScoreBoard.visible = should_show)
	GameManager.show_main_menu.connect(func(should_show): %MainMenu.visible = should_show)
	
func update_score_labels(scores):
	var p1_score = scores.get(Chip.Ownership.PLAYER_ONE)
	var p2_score = scores.get(Chip.Ownership.PLAYER_TWO)
	player_1_score.text = "Player1: " + str(p1_score)
	player_2_score.text = "Player2: " + str(p2_score)

func set_up_game_over(player_id: int, shouldShow: bool):
	if shouldShow: 
		%GameOver.show() 
	else:
		%GameOver.hide()
	%ResultText.text = "[wave amp=50.0 freq=5.0 connected=1]Player " + str(player_id) + " has won![/wave]"

func start_game():
	GameManager.start_game()

func restart_game():
	GameManager.state_chart.send_event("restart_game")
