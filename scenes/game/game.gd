extends Node2D

const SOFT_DROP_INTERVAL: float = 0.05
const FALL_WAIT_TIME_MIN: float = 0.02
const ROTATION_STEP_DEGREES = PI / 2
const HARD_DROP_INTERVAL: float = 0.01

signal show_pause_menu

@export var init_fall_wait_time := 0.5
@export var score_level := [0, 1, 3, 5, 7]
@export var pieces: Array[Piece]
@export var active_color := Color(1.0, 1.0, 1.0)
@export var locked_color := Color(0.45, 0.5, 0.65) 


@onready var piece_controller: Node2D = $PieceController
@onready var piece_preview: Node2D = $PiecePreview
@onready var boundary: Line2D = $Boundary
@onready var fall_timer: Timer = $FallTimer
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var block_pool: BlockPool = $BlockPool

var _piece_dict: Dictionary
var _score: int = 0
var _grid := GameGrid.new()
var _stack_top: float
var _piece: Array[String] = ['', '']
var _piece_rotation_step: Array[int] = [0, 0]
var _start_position: Vector2
var _horizontal_repeat := InputRepeater.new()
var _is_hard_drop := false
var _fall_wait_time: float


func _load_save_data():
	for i in range(Global.save_data.grid.size()):
		if Global.save_data.grid[i] == true:
			var node = block_pool.acquire_node()
			node.position = _grid.index2position(i)
			block_pool.register_node(i, node)
			node.modulate = locked_color
	if Global.save_data.score != 0:
		_set_score(Global.save_data.score)
		_update_fall_wait_time(Global.save_data.score)
	_set_fall_interval(_fall_wait_time)
	_stack_top = Global.save_data.stack_top
	_piece = Global.save_data.piece
	_piece_rotation_step = Global.save_data.piece_rotation_step
	piece_preview.rotation = _piece_rotation_step[1] * ROTATION_STEP_DEGREES
	_generate_block(_piece_dict[_piece[1]].cells, piece_preview, active_color)
	piece_controller.rotation = _piece_rotation_step[0] * ROTATION_STEP_DEGREES
	piece_controller.position = Global.save_data.current_piece_position
	_generate_block(_piece_dict[_piece[0]].cells, piece_controller, active_color)


func _set_start_point():
	_start_position = Vector2(
		floori(_grid.shape.x / 2.0) * _grid.cell_size + _grid.cell_size / 2.0,
		-_grid.cell_size * 1.5
	)


func _init_piece_dict():
	for piece in pieces:
		_piece_dict[piece.piece_id] = piece


func _init() -> void:
	_horizontal_repeat.input_repeated.connect(_try_move_horizontal)


func _ready() -> void:
	_init_piece_dict()
	_fall_wait_time = init_fall_wait_time
	_grid.cell_size = Global.config.cell_size
	_grid.shape.x = Global.config.colums
	_grid.shape.y = Global.config.rows
	_grid.size = _grid.shape * _grid.cell_size
	_grid.cell_count = _grid.shape.x * _grid.shape.y
	block_pool.initialize(_grid.cell_count)
	_stack_top = _grid.size.y
	_set_start_point()
	_draw_boundary()
	if Global.game_mode == Global.GameMode.CONTINUE:
		_load_save_data()
	else:
		_generate_next_piece()
		_promote_next_piece()
		_set_fall_interval(_fall_wait_time)


func _process(delta: float) -> void:
	if _is_hard_drop == false:
		_horizontal_repeat.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("soft_drop"):
		_set_fall_interval(SOFT_DROP_INTERVAL)
	elif event.is_action_released("soft_drop"):
		_set_fall_interval(_fall_wait_time)
	elif event.is_action_pressed("rotate_cw"):
		_control_rotate(1)
	elif event.is_action_pressed("rotate_ccw"):
		_control_rotate(-1)
	elif event.is_action_pressed("pause"):
		show_pause_menu.emit()
	elif event.is_action_pressed("hard_drop"):
		_hard_drop()
	else:
		return
	get_viewport().set_input_as_handled()


func _set_fall_interval(interval: float):
	fall_timer.wait_time = interval
	fall_timer.start()


func _hard_drop():
	if _is_hard_drop:
		return
	_is_hard_drop = true
	_set_fall_interval(HARD_DROP_INTERVAL)

func _draw_boundary():
	boundary.add_point(Vector2.ZERO)
	boundary.add_point(Vector2(_grid.size.x, 0))
	boundary.add_point(_grid.size)
	boundary.add_point(Vector2(0, _grid.size.y))


func _generate_block(cells: Array[Vector2], parent, color):
	for i in cells:
		var node = block_pool.acquire_node()
		node.reparent(parent, false)
		node.position = i * _grid.cell_size
		node.modulate = color
		node.rotation = 0


func _generate_next_piece():
	var piece = pieces[Global.rng.randi_range(0, pieces.size() - 1)]
	_piece[1] = piece.piece_id
	_piece_rotation_step[1] = Global.rng.randi_range(0, piece.rotation_steps_count - 1)
	piece_preview.rotation = _piece_rotation_step[1] * ROTATION_STEP_DEGREES
	var cells: Array[Vector2]
	_generate_block(piece.cells, piece_preview, active_color)


func _on_fall_timer_timeout() -> void:
	for i in piece_controller.get_children():
		var next_position = i.global_position + Vector2(0, _grid.cell_size)
		var next_index = _grid.position2index(next_position)
		if (
			next_position.y > _grid.size.y
			or _grid.is_occupied(next_index, block_pool.blocks)
		):
			_fall_done()
			return
	piece_controller.position.y += _grid.cell_size


func _try_move_horizontal(input_x: int) -> void:
	for i in piece_controller.get_children():
		var next_position = i.global_position + Vector2(_grid.cell_size * input_x, 0)
		if next_position.x < 0 or next_position.x > _grid.size.x:
			return
		var next_index = _grid.position2index(next_position)
		if _grid.is_occupied(next_index, block_pool.blocks):
			return
	piece_controller.position.x += input_x * _grid.cell_size


func _set_score(score: int) -> void:
	_score = score
	score_label.text = str(score)


func _update_fall_wait_time(score: int) -> void:
	_fall_wait_time = max(_fall_wait_time - score * 0.008, FALL_WAIT_TIME_MIN)


func _fall_done() -> void:
	for i in piece_controller.get_children():
		if i.global_position.y < 0:
			_end_game()
			return
		if i.global_position.y < _stack_top:
			_stack_top = i.global_position.y
	var level = 0
	var rows = _lock_current_piece()
	
	# 从上到下遍历
	rows.sort()
	for i in rows:
		if not _grid.is_row_full(i, block_pool.blocks):
			continue
		level += 1
		
		# 消除行
		for j in range(_grid.shape.x):
			var index = i * _grid.shape.x + j
			block_pool.release_node(index)
		
		# 上方所有方块下移一行
		var reverse_i = range(int(_stack_top / _grid.cell_size), i)
		reverse_i.reverse()
		for j in reverse_i:
			for k in range(_grid.shape.x):
				var index = j * _grid.shape.x + k
				if block_pool.blocks[index] != null:
					block_pool.blocks[index].global_position.y += _grid.cell_size
					block_pool.blocks[index + _grid.shape.x] = block_pool.blocks[index]
					block_pool.blocks[index] = null
	level = clampi(level, 0, len(score_level) - 1)
	_promote_next_piece()
	if score_level[level] != 0:
		_set_score(_score + score_level[level])
		_update_fall_wait_time(score_level[level])
	if is_equal_approx(fall_timer.wait_time, _fall_wait_time) == false:
		_set_fall_interval(_fall_wait_time)
	_save_game()
	if _is_hard_drop:
		_is_hard_drop = false


func _end_game() -> void:
	fall_timer.stop()
	Global.abandon_run()
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")


func _lock_current_piece() -> Array[int]:
	var rows: Array[int] = []
	for block: Node2D in piece_controller.get_children():
		block_pool.register_node(_grid.position2index(block.global_position), block)
		var row = int(block.global_position.y / _grid.cell_size)
		if row not in rows:
			rows.append(row)
		block.reparent(block_pool)
		block.modulate = locked_color
	return rows


func _promote_next_piece():
	piece_controller.position = _start_position
	piece_controller.rotation = piece_preview.rotation
	for i in piece_preview.get_children():
		i.reparent(piece_controller, false)
	_piece[0] = _piece[1]
	_piece_rotation_step[0] = _piece_rotation_step[1]
	_generate_next_piece()


func get_rotation_step(step: int) -> int:
	var rotation_step: int
	var rotation_steps_count = _piece_dict[_piece[0]].rotation_steps_count
	if step < 0:
		rotation_step = step + rotation_steps_count
	else:
		rotation_step = step
	return rotation_step % rotation_steps_count


func _control_rotate(direction: int) -> void:
	var rotated_cells: Array
	var rotation_step = get_rotation_step(_piece_rotation_step[0] + direction)
	var rotation_rad = rotation_step * ROTATION_STEP_DEGREES
	for i in piece_controller.get_children():
		rotated_cells.append(PieceRotation.rotate_point_around_center(i.position, rotation_rad) + piece_controller.position)
	var rotation_offset: Vector2
	for i in rotated_cells:
		# 下方超出边界直接返回（不旋转）
		if i.y > _grid.size.y:
			return
		if i.x < 0:
			var offset = -i.x + _grid.cell_size / 2.0
			if offset > rotation_offset.x:
				rotation_offset.x = offset
		elif i.x > _grid.size.x:
			var offset = _grid.size.x - i.x - _grid.cell_size / 2.0
			if offset < rotation_offset.x:
				rotation_offset.x = offset

	var final_positions = []
	for i in rotated_cells:
		var final_pos = i + rotation_offset
		# 边界检查
		if final_pos.x < 0 or final_pos.x > _grid.size.x:
			return
		final_positions.append(final_pos)
	
	# 统一进行碰撞检测
	for pos in final_positions:
		if _grid.is_occupied(_grid.position2index(pos), block_pool.blocks):
			return
	
	# 所有检查通过后更新状态
	piece_controller.position.x += rotation_offset.x
	_piece_rotation_step[0] = rotation_step
	piece_controller.rotation = rotation_rad


func _save_game() -> void:
	var data = {
		'stack_top': _stack_top,
		'score': _score,
		'blocks': block_pool.blocks,
		'current_piece_position': piece_controller.position,
		'piece': _piece,
		'piece_rotation_step': _piece_rotation_step
	}
	Global.save_game(data)
