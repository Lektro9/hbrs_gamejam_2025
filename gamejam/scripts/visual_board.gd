extends Node2D

@export var empty_texture: Texture2D
@export var red_texture: Texture2D
@export var blue_texture: Texture2D

var grid_size: Vector2i
@export var cell_size: Vector2 = Vector2(128, 128)
@onready var grid_container: Node2D = $GridContainer
@onready var empty_grid_container: Node2D = $GridContainer/EmptyGridContainer
@onready var filled_grid_container: Node2D = $GridContainer/FilledGridContainer
const DEFAULT_PLAYER_1_CHIP = preload("uid://by11wc80p4n7w")
const COLUMN_AREA = preload("uid://xtv2ebfyw4bp")
@onready var column_container: Node2D = $GridContainer/ColumnContainer

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
	pass

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
			var chip: Chip = GameManager.game_board.board_cells.get(Vector2i(x, y)).chip
			if chip != null:
				sprite.texture = _get_texture_for_cell(chip.player_id)
			else:
				sprite.texture = _get_texture_for_cell(0)
				
				
			sprite.position = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			filled_grid_container.add_child(sprite)

func _get_texture_for_cell(value: int) -> Texture2D:
	match value:
		1:
			return red_texture
		2:
			return blue_texture
		_:
			return empty_texture

func drop_chip(column: int):
	GameManager.drop_chip(DEFAULT_PLAYER_1_CHIP, column)
	GameManager.game_board.debug_print()
	_draw_board()

func start_game():
	GameManager.start_game()
	grid_size = Vector2i(GameManager.game_board.BOARD_WIDTH, GameManager.game_board.BOARD_HEIGHT)
	spawn_column_areas()
	for column in column_container.get_children():
		if column.has_signal("column_clicked"):
			column.connect("column_clicked", drop_chip)
		
	_init_board()
	_draw_empty_board()
	_draw_board()

func spawn_column_areas():
	for x in grid_size.x:
		var col_area: ColumnArea = COLUMN_AREA.instantiate()
		col_area.column_index = x
		#TODO refactor
		var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
		var origin = -total_size * 0.5  # center the grid
		#TODO end
		col_area.position = origin + Vector2(x, grid_size.y/2.0 - 0.5) * cell_size
		col_area.column_size = Vector2(cell_size.x, cell_size.y * grid_size.y)
		column_container.add_child(col_area)
