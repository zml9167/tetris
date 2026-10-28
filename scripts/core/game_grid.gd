class_name GameGrid

var shape: Vector2i
var size: Vector2
var cell_size: float
var cell_count: int


func position2index(pos: Vector2):
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


func index2position(index: int):
	@warning_ignore("integer_division")
	var rows = floori(index / shape.x)
	var cols = index % shape.x
	return Vector2(cols + 0.5, rows + 0.5) * cell_size
