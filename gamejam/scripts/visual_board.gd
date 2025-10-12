extends Node2D
class_name VisualBoard

@export var empty_texture: Texture2D

var grid_size: Vector2i
@export var cell_size: Vector2 = Vector2(128, 128)
@onready var grid_container: Node2D = $GridContainer
@onready var empty_grid_container: Node2D = $GridContainer/EmptyGridContainer
@onready var filled_grid_container: Node2D = $GridContainer/FilledGridContainer
const COLUMN_AREA = preload("uid://xtv2ebfyw4bp")
@onready var column_container: Node2D = $GridContainer/ColumnContainer

# 2D array to store the state (0 = empty, 1 = red, 2 = yellow)
var filled_board := []
# for visual debugging
var empty_board := []

func _init_board():
	filled_board.resize(grid_size.x)
	empty_board.resize(grid_size.x)
	for x in range(grid_size.x):
		empty_board[x] = []
		filled_board[x] = []
		for y in range(grid_size.y):
			empty_board[x].append(0) # all empty at start
			filled_board[x].append(0) # all empty at start

func _ready():
	GameManager.init_visual_board.connect(init_visual_board)

func _draw_empty_board():
	# Clear old sprites if needed
	for child in empty_grid_container.get_children():
		child.queue_free()

	var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin = - total_size * 0.5 # center the grid

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var sprite = Sprite2D.new()
			sprite.texture = empty_texture
			sprite.position = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			sprite.modulate = Color(0.004, 0.245, 0.266, 1.0)
			empty_grid_container.add_child(sprite)


func _draw_board():
	# Clear old sprites if needed
	for child in filled_grid_container.get_children():
		filled_grid_container.remove_child(child)

	var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin = - total_size * 0.5 # center the grid

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell: BoardCell = GameManager.game_board.board_cells.get(Vector2i(x, y))
			var chip: ChipInstance = cell.chip
			if chip == null:
				continue
				
			chip.is_in_cluster = cell.is_in_cluster
			
			# Only add chip to container if it's not already parented
			if chip.get_parent() != filled_grid_container:
				filled_grid_container.add_child(chip)

			# Ensure chip's sprite is updated to the correct color
			if chip.sprite_2d:
				if chip.player_id == 1:
					chip.sprite_2d.modulate = GameManager.player_1.color
				elif chip.player_id == 2:
					chip.sprite_2d.modulate = GameManager.player_2.color
				else:
					chip.sprite_2d.modulate = Color.WHITE

			# Update chip position
			chip.position = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			chip.start_falling(grid_size.y * cell_size.y)

func drop_chip(column: int):
	GameManager.drop_chip(column)
	GameManager.game_board.debug_print()
	_draw_board()

func init_visual_board():
	grid_size = Vector2i(GameManager.game_board.BOARD_WIDTH, GameManager.game_board.BOARD_HEIGHT)
	spawn_column_areas()
	for column in column_container.get_children():
		if column.has_signal("column_clicked"):
			column.connect("column_clicked", drop_chip)
		
	_init_board()
	_draw_empty_board()
	# Auto-redraw when board updates (effects like recolor, destroy, shift)
	if not GameManager.game_board.board_updated.is_connected(_draw_board):
		GameManager.game_board.board_updated.connect(_draw_board)
	_draw_board()

func spawn_column_areas():
	for x in grid_size.x:
		var col_area: ColumnArea = COLUMN_AREA.instantiate()
		col_area.column_index = x
		#TODO refactor
		var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
		var origin = - total_size * 0.5 # center the grid
		#TODO end
		col_area.position = origin + Vector2(x, grid_size.y / 2.0 - 0.5) * cell_size
		col_area.column_size = Vector2(cell_size.x, cell_size.y * grid_size.y)
		column_container.add_child(col_area)
		
func get_cell_world_position(x: int, y: int) -> Vector2:
	var total_size = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin = - total_size * 0.5 # center the grid
	var local_pos = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
	return empty_grid_container.to_global(local_pos)
