extends Node

@export var block_scene: PackedScene = preload("res://scene/block/block.tscn")
@export var pause_menu_scene: PackedScene
@export var block_width: float = 40
@export var grid_size: Vector2i = Vector2i(15, 20)
@export var fall_wait_time := 0.5
@export var score_level := [0, 1, 3, 5, 7]

var score = 0
var block_width_half = roundi(block_width / 2)
var wall = {'left': 0, 'right': grid_size.x * block_width, 'bottom': block_width * grid_size.y}
var spawn_position_x: float = roundi(wall['right'] / 2)
var control_node: Controller
var prefab_node: Controller
var blocks: Array
var fast_down: bool
var max_fall_wait_time := 0.05

@onready var prefab_position: Vector2 = $PreFabPoint.position
@onready var pause_menu = $PauseMenu
@onready var stack_top = wall['bottom']


func parse_save_data():
	for i in range(len(Global.save_data.grid)):
		if Global.save_data.grid[i] == 1:
			var block = block_scene.instantiate()
			block.position = index2position(i)
			blocks[i] = block
			add_child(block)
	update_fall_wait_time(Global.save_data.score)
	stack_top = Global.save_data.stack_top
	control_node.place(Global.save_data.control_node)
	Global.save_data.prefab_node.position = prefab_position
	prefab_node.place(Global.save_data.prefab_node)


func _ready() -> void:
	blocks.resize(roundi(grid_size.x * grid_size.y))
	blocks.fill(null)
	var controller_scene = preload("res://scene/controller/controller.tscn")
	control_node = controller_scene.instantiate()
	prefab_node = controller_scene.instantiate()
	add_child(control_node)
	add_child(prefab_node)
	$Line2D.width = 1
	$Line2D.default_color = Color()
	$Line2D.add_point(Vector2(wall['right'], 0))
	$Line2D.add_point(Vector2(wall['right'], wall['bottom']))
	if Global.game_mode == Global.GameMode.CONTINUE:
		parse_save_data()
	else:
		prefab_random_spawn()
		prefab2control()
	$Fall.start()
	$Score.text = str(score)


func position2index(pos: Vector2):
	var x = int(pos.x / block_width)
	var y = int(pos.y / block_width)
	# boundary check
	if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y:
		return -1
	return x + grid_size.x * y


func index2position(index: int):
	var row = int(index / grid_size.x)
	var col = index % grid_size.x
	return Vector2((col + 0.5) * block_width, (row + 0.5) * block_width)


func get_block_by_position(value: Vector2):
	var index = position2index(value)
	if index < 0 or index >= len(blocks):
		return null
	return blocks[index]


func _process(_delta: float) -> void:
	if $Fall.is_stopped():
		return
	if Input.is_action_pressed('move_down'):
		$Fall.wait_time = max_fall_wait_time if fast_down == true else fall_wait_time
	else:
		$Fall.wait_time = fall_wait_time


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('move_down'):
		fast_down = true
	elif event.is_action_pressed('clockwise_rotation'):
		control_rotate(1)
	elif event.is_action_pressed('counterclockwise_rotation'):
		control_rotate(-1)
	elif event.is_action_pressed('move_left'):
		$MoveXTigger.start()
		move_x(-1)
	elif event.is_action_pressed('move_right'):
		$MoveXTigger.start()
		move_x(1)
	elif event.is_action_released('move_left') or event.is_action_released('move_right'):
		$MoveXTigger.stop()
		$MoveX.stop()
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = true
		pause_menu.show()


func _on_fall_timeout() -> void:
	for i in control_node.get_children():
		var next_pos = i.global_position + Vector2(0, block_width)
		if next_pos.y < 0:
			continue
		if next_pos.y > wall['bottom']:
			fall_done()
			return
		var next_index = position2index(next_pos)
		if blocks[next_index] != null:
			fall_done()
			return
	control_node.position.y += block_width


func _on_move_x_timeout() -> void:
	var input_x = Input.get_axis('move_left', 'move_right')
	if not input_x:
		return
	move_x(input_x)


func move_x(input_x):
	for i in control_node.get_children():
		var next_pos = i.global_position + Vector2(block_width * input_x, 0)
		if next_pos.x < wall['left'] or next_pos.x > wall['right']:
			return
		var next_index = position2index(next_pos)
		if blocks[next_index] != null:
			return
	control_node.position.x += input_x * block_width


func update_fall_wait_time(score_value: int):
	score += score_value
	fall_wait_time = max(fall_wait_time - score_value*0.01, max_fall_wait_time)
	$Fall.wait_time = fall_wait_time


func fall_done():
	fast_down = false
	$MoveX.stop()
	for i in control_node.get_children():
		if i.global_position.y < 0:
			game_over()
			return
		if i.global_position.y < stack_top:
			stack_top = i.global_position.y
	var res = 0 
	var level = 0
	var rows = prefab2control()
	
	# 从上到下遍历
	rows.sort()
	for i in rows:
		var count = 0
		for j in range(grid_size.x):
			if blocks[i * grid_size.x + j] != null:
				count += 1
		if count != grid_size.x:
			continue
		level += 1
		for j in range(grid_size.x):
			res = i * grid_size.x + j
			blocks[res].free()
			blocks[res] = null
		var reverse_i = range(int(stack_top / block_width), i)
		reverse_i.reverse()
		for j in reverse_i:
			for k in range(grid_size.x):
				res = j * grid_size.x + k
				if blocks[res] != null:
					blocks[res].position.y += block_width
					blocks[res + grid_size.x] = blocks[res]
					blocks[res] = null
	level = clampi(level, 0, len(score_level) - 1)
	update_fall_wait_time(score_level[level])
	$Score.text = str(score)


func game_over():
	$Fall.stop()
	$MoveX.stop()
	$GameOver.show()
	Global.save_highest_score(score)
	Global.clear_save()
	var tween = create_tween()
	tween.tween_property($GameOver/ColorRect, "color", Color.BLACK, 3)
	tween.tween_callback(func (): get_tree().change_scene_to_file("res://scene/title/title.tscn"))


func _on_move_x_tigger_timeout() -> void:
	$MoveX.start()


func prefab2control():
	var rows = []
	var spawn_position_y = 0
	for i in control_node.get_children():
		var block_pos = i.global_position
		blocks[position2index(block_pos)] = i
		var row = int(block_pos.y / block_width)
		if row not in rows:
			rows.append(row)
		i.reparent(self)
		var block_rel_pos = block_pos - control_node.position
		if block_rel_pos.y > spawn_position_y:
			spawn_position_y = block_rel_pos.y
	var switch_node = prefab_node
	prefab_node = control_node
	control_node = switch_node
	control_node.position = Vector2(spawn_position_x, -spawn_position_y-block_width_half)
	prefab_random_spawn()
	return rows


func prefab_random_spawn():
	prefab_node.position = prefab_position
	prefab_node.random_spawn()


func control_rotate(direction: int) -> void:
	var pre_rotate_res = control_node.pre_rotate(direction)
	var final_positions = []
	var total_move = Vector2.ZERO
	for i in pre_rotate_res:
		var move_position = Vector2.ZERO
		
		# 下方超出边界直接返回（不旋转）
		if i.y > wall['bottom']:
			return
		
		if i.x < wall['left']:
			move_position.x = wall['left'] - i.x + block_width_half
		elif i.x > wall['right']:
			move_position.x = wall['right'] - i.x - block_width_half
		
		var final_pos = i + move_position
		# 边界检查
		if final_pos.x < wall['left'] or final_pos.x > wall['right']:
			return
		
		final_positions.append(final_pos)
		total_move += move_position
	
	# 第二步：统一进行碰撞检测
	for pos in final_positions:
		if get_block_by_position(pos) != null:
			return
	
	# 所有检查通过后更新状态
	control_node.apply_rotate(total_move)


func _on_pause_menu_save() -> void:
	Global.save_game(blocks, stack_top, control_node, prefab_node, score)
