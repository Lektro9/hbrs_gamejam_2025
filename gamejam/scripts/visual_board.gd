extends Node2D

@export var empty_texture: Texture2D
@export var red_texture: Texture2D
@export var blue_texture: Texture2D

@export var grid_size: Vector2i = Vector2i(GameBoard.BOARD_WIDTH,GameBoard.BOARD_HEIGHT)  # 7 columns × 6 rows
@export var cell_size: Vector2 = Vector2(128, 128)
@onready var grid_container: Node2D = $GridContainer
@onready var empty_grid_container: Node2D = $GridContainer/EmptyGridContainer
@onready var filled_grid_container: Node2D = $GridContainer/FilledGridContainer

# 2D array to store the state (0 = empty, 1 = red, 2 = yellow)
var filled_board := []
var empty_board := []

func _init_board():
	filled_board.resize(grid_size.x)
	empty_board.resize(grid_size.x)
	for x in range(grid_size.x):
		empty_board[x] = []
		filled_board[x] = []
		for y in range(grid_size.y):
			empty_board[x].append(0)  # all empty at start
			filled_board[x].append(0)  # all empty at start

func _ready():
	_init_board()
	_draw_empty_board()
	_draw_board()

func _draw_empty_board():
	# Clear old sprites if needed
	for child in empty_grid_container.get_children():
		child.queue_free()

	var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin = -total_size * 0.5  # center the grid

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var sprite = Sprite2D.new()
			sprite.texture = empty_texture
			sprite.position = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			empty_grid_container.add_child(sprite)


func _draw_board():
	# Clear old sprites if needed
	for child in filled_grid_container.get_children():
		child.queue_free()

	var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin = -total_size * 0.5  # center the grid

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var sprite = Sprite2D.new()
			sprite.texture = _get_texture_for_cell(filled_board[x][y])
			sprite.position = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			grid_container.add_child(sprite)

func _get_texture_for_cell(value: int) -> Texture2D:
	match value:
		1:
			return red_texture
		2:
			return blue_texture
		_:
			return empty_texture

# Example: drop a disc in a column
func drop_disc(column: int, player: int):
	for y in range(grid_size.y):
		if filled_board[column][y] == 0:
			filled_board[column][y] = player
			_draw_board()
			return


func _on_drop_chip_btn_pressed() -> void:
	drop_disc(1, 1)
