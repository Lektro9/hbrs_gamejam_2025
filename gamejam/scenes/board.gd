extends TileMapLayer

@export var coords_x = 16
@export var coords_y = 16

func _ready() -> void:
	for i in coords_x:
		for j in coords_y:
			set_cell(Vector2i(i, j), 0, Vector2i(0, 0))
