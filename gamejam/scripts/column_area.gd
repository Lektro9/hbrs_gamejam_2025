extends Area2D
class_name ColumnArea

signal column_clicked(column_index: int)

@export var column_index: int
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var column_size: Vector2 = Vector2(500, 600) # default fallback
@onready var hover_effect: Sprite2D = $CollisionShape2D/HoverEffect

func _ready():
	input_pickable = true
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("input_event", _on_input_event)
	_resize_collision_shape()

func _resize_collision_shape():
	var shape = collision_shape_2d.shape
	if shape is RectangleShape2D:
		shape.size = column_size
	else:
		push_warning("CollisionShape2D does not have a RectangleShape2D assigned!")

func _on_mouse_entered():
	# e.g. change color or show highlight
	hover_effect.show()

func _on_mouse_exited():
	hover_effect.hide()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Clicked column:", column_index)
		column_clicked.emit(column_index)
