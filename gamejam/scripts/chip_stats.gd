class_name ChipStats
extends Resource

enum Specials {NORMAL = 0, BONUS}

@export var chip_value: int = 1
@export var special_type: Specials = Specials.NORMAL

func _init(is_special: bool):
	if is_special:
		special_type = randi_range(1, Specials.BONUS)
