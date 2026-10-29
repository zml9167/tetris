extends SceneTree

const GameGridScript = preload("res://scripts/core/game_grid.gd")
const PieceRotationScript = preload("res://scripts/core/piece_rotation.gd")

var failures := 0


func _initialize() -> void:
	_test_grid_position_conversion()
	_test_grid_occupancy_and_full_rows()
	_test_piece_rotation()
	if failures == 0:
		print("Core tests passed.")
		quit(0)
	else:
		push_error("%d core test(s) failed." % failures)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _make_grid():
	var grid = GameGridScript.new()
	grid.shape = Vector2i(4, 3)
	grid.cell_size = 10.0
	grid.size = Vector2(grid.shape) * grid.cell_size
	grid.cell_count = grid.shape.x * grid.shape.y
	return grid


func _test_grid_position_conversion() -> void:
	var grid = _make_grid()
	for index in range(grid.cell_count):
		var center = grid.index2position(index)
		_check(grid.position2index(center) == index, "Grid index %d did not round-trip." % index)

	_check(grid.position2index(Vector2(0, 0)) == 0, "Top-left grid boundary should be included.")
	_check(grid.position2index(Vector2(-0.01, 0)) == -1, "Negative X should be out of bounds.")
	_check(grid.position2index(Vector2(0, -0.01)) == -1, "Negative Y should be out of bounds.")
	_check(grid.position2index(Vector2(grid.size.x, 0)) == -1, "Right grid boundary should be excluded.")
	_check(grid.position2index(Vector2(0, grid.size.y)) == -1, "Bottom grid boundary should be excluded.")


func _test_grid_occupancy_and_full_rows() -> void:
	var grid = _make_grid()
	var occupied_cells: Array[Node2D] = []
	occupied_cells.resize(grid.cell_count)
	occupied_cells.fill(null)
	for index in [0, 1, 2, 3, 8, 9, 10, 11]:
		occupied_cells[index] = Node2D.new()

	_check(grid.is_occupied(0, occupied_cells), "Occupied cell was not detected.")
	_check(not grid.is_occupied(4, occupied_cells), "Empty cell was reported occupied.")
	_check(not grid.is_occupied(-1, occupied_cells), "Out-of-bounds index should not be occupied.")
	_check(not grid.is_occupied(grid.cell_count, occupied_cells), "Past-end index should not be occupied.")
	_check(grid.is_row_full(0, occupied_cells), "Full row 0 was not detected.")
	_check(not grid.is_row_full(1, occupied_cells), "Incomplete row 1 was reported full.")
	_check(grid.is_row_full(2, occupied_cells), "Full row 2 was not detected.")
	_check(not grid.is_row_full(-1, occupied_cells), "Negative row should not be full.")
	_check(not grid.is_row_full(grid.shape.y, occupied_cells), "Past-end row should not be full.")
	for cell in occupied_cells:
		if cell != null:
			cell.free()


func _test_piece_rotation() -> void:
	var quarter_turn = PieceRotationScript.rotate_point_around_center(Vector2(2, 0), PI / 2)
	var half_turn = PieceRotationScript.rotate_point_around_center(Vector2(2, 0), PI)
	var three_quarter_turn = PieceRotationScript.rotate_point_around_center(Vector2(2, 0), PI * 1.5)

	_check(quarter_turn.is_equal_approx(Vector2(0, 2)), "Quarter-turn rotation was incorrect.")
	_check(half_turn.is_equal_approx(Vector2(-2, 0)), "Half-turn rotation was incorrect.")
	_check(three_quarter_turn.is_equal_approx(Vector2(0, -2)), "Three-quarter-turn rotation was incorrect.")
