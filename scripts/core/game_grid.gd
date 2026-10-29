class_name GameGrid

var shape: Vector2i
var size: Vector2
var cell_size: float
var cell_count: int


func position2index(pos: Vector2) -> int:
	var cols = floori(pos.x / cell_size)
	var rows = floori(pos.y / cell_size)

	# boundary check
	if (
		cols < 0
		or cols >= shape.x
		or rows < 0
		or rows >= shape.y
	):
		return -1
	return cols + shape.x * rows


func index2position(index: int) -> Vector2:
	@warning_ignore("integer_division")
	var rows = floori(index / shape.x)
	var cols = index % shape.x
	return Vector2(cols + 0.5, rows + 0.5) * cell_size


func is_occupied(index: int, occupied_cells: Array[Node2D]) -> bool:
	return index >= 0 and index < occupied_cells.size() and occupied_cells[index] != null


func is_row_full(row: int, occupied_cells: Array[Node2D]) -> bool:
	if row < 0 or row >= shape.y:
		return false
	for col in range(shape.x):
		if not is_occupied(col + shape.x * row, occupied_cells):
			return false
	return true
