extends RichTextLabel

@export var player_id: int
@onready var count_up_tween: TweenCustom

func _ready() -> void:
	count_up_tween = get_child(0)
	
func count_up(val: float):
	text = """ %s /%s """ % [str(snappedi(val, 1)), str(GameManager.score_needed)]

func set_final_value(final_val):
	count_up_tween.final_value = final_val
	count_up_tween.start_tween()
