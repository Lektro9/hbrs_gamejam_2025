extends CanvasLayer
@onready var make_turn_btn: Button = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MakeTurnBtn
@onready var win_btn: Button = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/WinBtn
@onready var start_btn: Button = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/StartBtn
@onready var restart_btn: Button = $HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/RestartBtn

func _ready() -> void:
	var cs = ChipStats.new(false, 0)
	start_btn.pressed.connect(func(): GameManager.start_game())
	make_turn_btn.pressed.connect(func(): GameManager.drop_chip(cs, 0))
	win_btn.pressed.connect(func(): GameManager.set_is_game_won_expression(true))
	restart_btn.pressed.connect(func(): GameManager.restart_game())
