extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	GameManager.scroll_background.connect(scroll_background)

func scroll_background(is_going_up):
	if is_going_up:
		animation_player.play("menu_goes_up")
	else:
		animation_player.play_backwards("menu_goes_up", -1)
