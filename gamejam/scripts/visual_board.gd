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
var _chip_positions: Dictionary = {}

func _init_board():
	filled_board.resize(grid_size.x)
	empty_board.resize(grid_size.x)
	for x in range(grid_size.x):
		empty_board[x] = []
		filled_board[x] = []
		for y in range(grid_size.y):
			empty_board[x].append(0) # all empty at start
			filled_board[x].append(0) # all empty at start
	_chip_positions.clear()

func _ready():
	GameManager.init_visual_board.connect(init_visual_board)
	GameManager.clean_up_visuals.connect(clean_up)
	GameManager.update_visual_board.connect(_draw_board)

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
	var nodes_to_cleanup: Dictionary = {}
	for child in filled_grid_container.get_children():
		if child is ChipInstance:
			nodes_to_cleanup[child.get_instance_id()] = child

	var total_size: Vector2 = Vector2(grid_size.x - 1, grid_size.y - 1) * cell_size
	var origin: Vector2 = - total_size * 0.5 # center the grid
	var updated_positions: Dictionary = {}

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var cell: BoardCell = GameManager.game_board.get_board_cell_by_coords(x, y)
			if cell == null:
				continue
			var chip: ChipInstance = cell.chip
			if chip == null:
				continue
			chip.stop_in_cluster_tween()
			if cell.is_in_cluster and chip.in_cluster_tween:
				chip.in_cluster_tween.start_tween()
			var target_position: Vector2 = origin + Vector2(x, grid_size.y - 1 - y) * cell_size
			var key: int = chip.get_instance_id()

			if chip.get_parent() != filled_grid_container:
				filled_grid_container.add_child(chip)

			var target_color: Color = Color.WHITE
			match chip.player_id:
				Chip.Ownership.PLAYER_ONE:
					target_color = GameManager.player_1.color
				Chip.Ownership.PLAYER_TWO:
					target_color = GameManager.player_2.color
				_:
					target_color = Color.WHITE

			if not chip.color.is_equal_approx(target_color):
				chip.apply_player_color(target_color)

			if not _chip_positions.has(key):
				chip.position = target_position
				chip.start_falling(grid_size.y * cell_size.y)
			else:
				var travel: Vector2 = target_position - chip.position
				if travel.length() > 0.5:
					chip.animate_to_position(target_position, travel, cell_size)
				else:
					chip.position = target_position

			updated_positions[key] = target_position
			nodes_to_cleanup.erase(key)

	for leftover_key in nodes_to_cleanup.keys():
		var orphan: ChipInstance = nodes_to_cleanup[leftover_key]
		if orphan is ChipInstance:
			orphan.queue_free()
		_chip_positions.erase(leftover_key)

	_chip_positions = updated_positions

func drop_chip(column: int):
	GameManager.drop_chip(column)
	GameManager.game_board.debug_print()

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

func play_recolor_effect(pos: Vector2i, owner_after: int) -> void:
	if GameManager.game_board == null:
		return
	var cell := GameManager.game_board.get_board_cell(pos)
	if cell == null or not cell.has_chip():
		return
	var chip: ChipInstance = cell.chip
	if chip == null:
		return
	var target_color := Color.WHITE
	match owner_after:
		Chip.Ownership.PLAYER_ONE:
			target_color = GameManager.player_1.color
		Chip.Ownership.PLAYER_TWO:
			target_color = GameManager.player_2.color
		_:
			target_color = Color.WHITE
	chip.play_recolor_flash(target_color)

func clean_up():
	for child in filled_grid_container.get_children():
		child.queue_free()
	for child in empty_grid_container.get_children():
		child.queue_free()
	for child in column_container.get_children():
		child.queue_free()
