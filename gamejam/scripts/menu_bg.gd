extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bottles_anim: AnimationPlayer = $Bottles_anim


func _ready() -> void:
	GameManager.scroll_background.connect(scroll_background)

func scroll_background(is_going_up):
	if is_going_up:
		bottles_anim.play("clash_bottles")
	else:
		bottles_anim.play("bottle_idle")
		animation_player.play_backwards("menu_goes_up", -1)

func play_menu_scroll():
	animation_player.play("menu_goes_up")
	bottles_anim.play("RESET")
	
