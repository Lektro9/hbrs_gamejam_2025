extends Node2D

@export var BOARD_WIDTH: int
@export var BOARD_HEIGHT: int

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

var board_cells: Dictionary[Vector2i, BoardCell]

func _ready() -> void:
	GameManager.initialize_game_board.connect(_init_game_board)
			
func _init_game_board():
	board_cells = {}

	for i in BOARD_WIDTH:
		for j in BOARD_HEIGHT:	
			# Set cell properties
			var cell = BoardCell.new(i, j)
			
			board_cells[Vector2i(i, j)] = cell
			
	for board_cell in board_cells:
		board_cells[board_cell].neighbours = get_board_cell_neighbours(board_cell).filter(func(bc: BoardCell): return bc != null)
		print(board_cells[board_cell])
		for cell_neighbour in board_cells[board_cell].neighbours:
			print("\t -> %s" % cell_neighbour)

# TODO
func update():
	pass

func get_board_cell(coords: Vector2i) -> BoardCell:
	if board_cells.has(coords):
		return board_cells[coords]
		
	return null
	
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
		cells.append(get_board_cell_neighbour(coords, CellDirection[direction]))
	
	return cells
	
func get_cells_below_board_cell(cell: BoardCell) -> Array[BoardCell]:
	var cells_below: Array[BoardCell] = []
	
	for c in range(cell.y, 0, -1):
		cells_below.append(c)
		
	return cells_below
	
# TODO
func get_board_cell_neighbours_in_radius(coords: Vector2i, radius: int = 1) -> Array[BoardCell]:
	var cells: Dictionary[Vector2i, BoardCell] = {}
	var cells_array: Array[BoardCell]
	
	var neighbours = get_board_cell_neighbours(coords)
	
	for neighbour in neighbours:
		cells[neighbour.coords] = neighbour
	
	for cell in cells:
		cells_array.append(cells[cell])
		
	return cells_array

func get_column(col_num: int) -> Array[BoardCell]:
	assert(col_num < BOARD_WIDTH, 
	"Position of column must be smaller than board width, which is %s" % BOARD_WIDTH)
	
	var col_cells: Array[BoardCell] = []
	
	for i in BOARD_HEIGHT:
		col_cells.append(get_board_cell_by_coords(col_num, i))
	
	return col_cells

# TODO
func get_column_free_spot(col_num: int):
	assert(col_num < BOARD_WIDTH, 
	"Position of column must be smaller than board width, which is %s" % BOARD_WIDTH)
	
	pass
	
func chip_gravity(cell: BoardCell):
	if cell.has_chip():
		var cell_below = get_board_cell_neighbour(cell.coords, CellDirection.CELL_DOWN)
		
		if not cell_below.has_chip():
			cell_below.chip = cell.chip
			cell.chip = null
	
	pass

func all_chips_in_play() -> Array[BoardCell]:
	return board_cells.values().filter(func(c: BoardCell): return c.has_chip())
	
	
func drop_chip():
	pass
