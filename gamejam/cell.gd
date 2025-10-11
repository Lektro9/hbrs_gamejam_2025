# Holds the properties of cells in the game board
class_name BoardCell
extends Node2D

# x coord
var x: int
# y coord
var y: int

var coords: Vector2i:
	get:
		return Vector2i(x, y)
	set(value):
		x = value.x
		y = value.y

func _init(x_coord: int, y_coord: int) -> void:
	self.x = x_coord
	self.y = y_coord

func equals(other_cell: BoardCell) -> bool:
	return self.coords == other_cell.coords
