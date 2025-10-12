extends Node2D

const CUSTOM_CURSOR := preload("uid://csr68uogg8epd")

func _ready() -> void:
	# Set mouse cursor
	Input.set_custom_mouse_cursor(CUSTOM_CURSOR)

func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()