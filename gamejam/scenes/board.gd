extends TileMapLayer

@export var width: int
@export var height: int

enum CellDirection {
	CELL_UP,
	CELL_UP_RIGHT,
	CELL_RIGHT,
	CELL_DOWN_RIGHT,
	CELL_DOWN,
	CELL_DOWN_LEFT,
	CELL_LEFT,
	CELL_UP_LEFT
}

var board_cells: Dictionary

func _ready() -> void:
	GameManager.initialize_game_board.connect(_init_game_board)
			
func _init_game_board():
	board_cells = {}

	for i in width:
		for j in height:
			# Instantiate tile map cells
			set_cell(Vector2i(i, j), 0, Vector2i(0, 0))
			
			# Set cell properties
			var cell = BoardCell.new(i, j)
			
			board_cells[Vector2i(i, j)] = cell
			
func get_board_cell(coords: Vector2i) -> BoardCell:
	return board_cells[coords]
	
func get_board_cell_by_coords(x: int, y: int) -> BoardCell:
	return get_board_cell(Vector2i(x, y))
	
func get_board_cell_neighbour(coords: Vector2i, direction: CellDirection) -> BoardCell:
	match direction:
		CellDirection.CELL_UP:
			return get_board_cell_by_coords(coords.x, coords.y + 1)
		CellDirection.CELL_UP_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y + 1)
		CellDirection.CELL_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y)
		CellDirection.CELL_DOWN_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y - 1)
		CellDirection.CELL_DOWN:
			return get_board_cell_by_coords(coords.x, coords.y - 1)
		CellDirection.CELL_DOWN_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y - 1)
		CellDirection.CELL_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y)
		CellDirection.CELL_UP_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y + 1)
			
	return null

func get_board_cell_neighbours(coords: Vector2i) -> Array[BoardCell]:
	var cells: Array[BoardCell] = []
	
	for direction in CellDirection:
		cells.append(get_board_cell_neighbour(coords, direction))
	
	return cells
	
func get_board_cell_neighbours_in_radius(coords: Vector2i, radius: int = 1) -> Array[BoardCell]:
	var cells: Array[BoardCell] = []
	
	return cells
