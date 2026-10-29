extends Node2D

const HARD_DROP_SPEED: float = 0.05
const FALL_WAIT_TIME_MAX: float = 0.1
const ROTATIONS = [0, PI / 2, PI, PI * 1.5]
const HALF_PI = PI / 2

@export var fall_wait_time := 0.5
@export var score_level := [0, 1, 3, 5, 7]
@export var pieces: Array[Piece]
@export var active_color := Color(1.0, 1.0, 1.0)
@export var locked_color := Color(0.45, 0.5, 0.65) 


@onready var piece_controller: Node2D = $PieceController
@onready var piece_preview: Node2D = $PiecePreview
@onready var pause_menu = $PauseMenu
@onready var boundary: Line2D = $Boundary
@onready var fall_timer: Timer = $FallTimer
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var block_pool: BlockPool = $BlockPool

var score = 0
var grid: GameGrid
var hard_drop: bool
var stack_top: float
var next_piece_index: int
var next_piece_rotation: float
var current_piece_can_rotate: bool
var start_position: Vector2


func _load_save_data():
	for i in range(Global.save_data.grid.size()):
		if Global.save_data.grid[i] == true:
			var node = block_pool.acquire_node()
			node.position = grid.index2position(i)
			block_pool.register_node(i, node)
			node.modulate = locked_color
	_update_fall_wait_time(Global.save_data.score)
	hard_drop = Global.save_data.hard_drop
	if hard_drop:
		fall_timer.wait_time = HARD_DROP_SPEED
	stack_top = Global.save_data.stack_top
	next_piece_index = Global.save_data.next_piece_index
	next_piece_rotation = Global.save_data.next_piece_rotation
	piece_controller.position = Global.save_data.current_piece_position
	piece_controller.rotation = Global.save_data.current_piece_rotation
	_generate_block(Global.save_data.current_piece_cells, piece_controller, active_color)
	piece_preview.rotation = next_piece_rotation
	var cells: Array[Vector2]
	for i in pieces[next_piece_index].cells:
		cells.append(i * grid.cell_size)
	_generate_block(cells, piece_preview, active_color)
	current_piece_can_rotate = Global.save_data.current_piece_can_rotate


func _ready() -> void:
	grid = GameGrid.new()
	grid.cell_size = Global.config.cell_size
	grid.shape.x = Global.config.colums
	grid.shape.y = Global.config.rows
	grid.size = grid.shape * grid.cell_size
	grid.cell_count = grid.shape.x * grid.shape.y
	block_pool.initialize(grid.cell_count)
	stack_top = grid.size.y
	var center_col = floori(grid.shape.x / 2.0)
	start_position = Vector2(
		center_col * grid.cell_size + grid.cell_size / 2.0,
		-grid.cell_size * 1.5
	)

	_draw_boundary()
	
	if Global.game_mode == Global.GameMode.CONTINUE:
		_load_save_data()
	else:
		_generate_next_piece()
		_promote_next_piece()
		fall_timer.wait_time = fall_wait_time
		fall_timer.start()
	score_label.text = str(score)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("hard_drop"):
		hard_drop = true
		fall_timer.wait_time = HARD_DROP_SPEED
		fall_timer.start()
	elif event.is_action_pressed("rotate_clockwise"):
		_control_rotate(1)
	elif event.is_action_pressed("rotate_counterclockwise"):
		_control_rotate(-1)
	elif event.is_action_pressed("move_left", true):
		_try_move_horizontal(-1)
	elif event.is_action_pressed("move_right", true):
		_try_move_horizontal(1)
	elif event.is_action_pressed("ui_cancel"):
		get_tree().paused = true
		pause_menu.show()


func _draw_boundary():
	boundary.add_point(Vector2.ZERO)
	boundary.add_point(Vector2(grid.size.x, 0))
	boundary.add_point(grid.size)
	boundary.add_point(Vector2(0, grid.size.y))


func _generate_block(cells: Array[Vector2], parent, color):
	for i in cells:
		var node = block_pool.acquire_node()
		node.reparent(parent, false)
		node.position = i
		node.modulate = color
		node.rotation = 0


func _generate_next_piece():
	next_piece_index = Global.rng.randi_range(0, pieces.size() - 1)
	var piece = pieces[next_piece_index]
	if piece.can_rotate:
		next_piece_rotation = ROTATIONS[Global.rng.randi_range(0, ROTATIONS.size() - 1)]
	else:
		next_piece_rotation = 0
	piece_preview.rotation = next_piece_rotation
	var cells: Array[Vector2]
	for i in piece.cells:
		cells.append(i * grid.cell_size)
	_generate_block(cells, piece_preview, active_color)


func _on_fall_timer_timeout() -> void:
	for i in piece_controller.get_children():
		var next_position = i.global_position + Vector2(0, grid.cell_size)
		var next_index = grid.position2index(next_position)
		if (
			next_position.y > grid.size.y
			or grid.is_occupied(next_index, block_pool.blocks)
		):
			_fall_done()
			return
	piece_controller.position.y += grid.cell_size


func _try_move_horizontal(input_x):
	for i in piece_controller.get_children():
		var next_position = i.global_position + Vector2(grid.cell_size * input_x, 0)
		if next_position.x < 0 or next_position.x > grid.size.x:
			return
		var next_index = grid.position2index(next_position)
		if grid.is_occupied(next_index, block_pool.blocks):
			return
	piece_controller.position.x += input_x * grid.cell_size


func _update_fall_wait_time(score_value: int):
	hard_drop = false
	score += score_value
	Global.update_highest_score(score)
	fall_wait_time = max(fall_wait_time - score_value*0.01, FALL_WAIT_TIME_MAX)
	fall_timer.wait_time = fall_wait_time
	fall_timer.start()


func _fall_done():
	for i in piece_controller.get_children():
		if i.global_position.y < 0:
			_end_game('end')
			return
		if i.global_position.y < stack_top:
			stack_top = i.global_position.y
	var level = 0
	var rows = _lock_current_piece()
	
	# 从上到下遍历
	rows.sort()
	for i in rows:
		if not grid.is_row_full(i, block_pool.blocks):
			continue
		level += 1
		
		# 消除行
		for j in range(grid.shape.x):
			var index = i * grid.shape.x + j
			block_pool.release_node(index)
		
		# 上方所有方块下移一行
		var reverse_i = range(int(stack_top / grid.cell_size), i)
		reverse_i.reverse()
		for j in reverse_i:
			for k in range(grid.shape.x):
				var index = j * grid.shape.x + k
				if block_pool.blocks[index] != null:
					block_pool.blocks[index].global_position.y += grid.cell_size
					block_pool.blocks[index + grid.shape.x] = block_pool.blocks[index]
					block_pool.blocks[index] = null
	level = clampi(level, 0, len(score_level) - 1)
	_update_fall_wait_time(score_level[level])
	score_label.text = str(score)
	_promote_next_piece()
	_save_game()


func _end_game(text: String):
	print(text)
	fall_timer.stop()
	Global.abandon_run()
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")


func _lock_current_piece():
	var rows = []
	for block: Node2D in piece_controller.get_children():
		block_pool.register_node(grid.position2index(block.global_position), block)
		var row = int(block.global_position.y / grid.cell_size)
		if row not in rows:
			rows.append(row)
		block.reparent(block_pool)
		block.modulate = locked_color
	return rows


func _promote_next_piece():
	piece_controller.position = start_position
	for i in piece_preview.get_children():
		i.reparent(piece_controller, false)
	piece_controller.rotation = piece_preview.rotation
	current_piece_can_rotate = pieces[next_piece_index].can_rotate
	_generate_next_piece()


func _control_rotate(direction: int) -> void:
	if not current_piece_can_rotate:
		return
	var rotated_cells: Array
	var rotation_rad = piece_controller.rotation + direction * HALF_PI
	for i in piece_controller.get_children():
		var res = PieceRotation.rotate_point_around_center(i.position, rotation_rad)
		rotated_cells.append(res + piece_controller.position)
	var rotation_offset: Vector2
	for i in rotated_cells:
		# 下方超出边界直接返回（不旋转）
		if i.y > grid.size.y:
			return
		if i.x < 0:
			var offset = -i.x + grid.cell_size / 2.0
			if offset > rotation_offset.x:
				rotation_offset.x = offset
		elif i.x > grid.size.x:
			var offset = grid.size.x - i.x - grid.cell_size / 2.0
			if offset < rotation_offset.x:
				rotation_offset.x = offset

	var final_positions = []
	for i in rotated_cells:
		var final_pos = i + rotation_offset
		# 边界检查
		if final_pos.x < 0 or final_pos.x > grid.size.x:
			return
		final_positions.append(final_pos)
	
	# 第二步：统一进行碰撞检测
	for pos in final_positions:
		if grid.is_occupied(grid.position2index(pos), block_pool.blocks):
			return
	
	# 所有检查通过后更新状态
	piece_controller.position.x += rotation_offset.x
	piece_controller.rotation = rotation_rad


func _save_game() -> void:
	var current_piece_cells: Array[Vector2]
	for i in piece_controller.get_children():
		current_piece_cells.append(i.position)
	var data = {
		'hard_drop': hard_drop,
		'stack_top': stack_top,
		'score': score,
		'blocks': block_pool.blocks,
		'current_piece_position': piece_controller.position,
		'current_piece_rotation': piece_controller.rotation,
		'current_piece_cells': current_piece_cells,
		'next_piece_index': next_piece_index,
		'next_piece_rotation': next_piece_rotation,
		'current_piece_can_rotate': current_piece_can_rotate
	}
	Global.save_game(data)
