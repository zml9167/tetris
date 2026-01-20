extends Node

@export var block_scene: PackedScene
@export var grid_size: Vector2
@export var block_width: float

var blocks: Array[MeshInstance2D]
var wall: Array
var block_width_half: float
var score = 0
var score_level = [0, 1, 3, 5, 7]
var spawn_position_x: float
var prefab_position: Vector2
var control_node: Controller
var prefab_node: Controller
var prefab_arr: Array
var block_top: int
var fall_wait_time = 0.5


func _ready() -> void:
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(0, -block_width), Vector2(-block_width, 0), Vector2.ZERO, Vector2(block_width, 0)])))
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(-block_width, -block_width), Vector2(0, -block_width), Vector2(-block_width, 0), Vector2.ZERO]), false))
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(0, -block_width*2), Vector2(0, -block_width), Vector2.ZERO, Vector2(0, block_width)])))
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(block_width, -block_width), Vector2(-block_width, 0), Vector2.ZERO, Vector2(block_width, 0)])))
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(-block_width, -block_width), Vector2(0, -block_width), Vector2.ZERO, Vector2(block_width, 0)])))
	prefab_arr.append(Prefab.new(PackedVector2Array([Vector2(block_width, -block_width), Vector2(0, -block_width), Vector2.ZERO, Vector2(-block_width, 0)])))
	control_node = Controller.new()
	add_child(control_node)
	prefab_node = Controller.new()
	add_child(prefab_node)
	prefab_position = $PreFabPoint.position
	block_width_half = block_width / 2
	wall = [0, grid_size.x * block_width, block_width * grid_size.y]
	block_top = wall[2]
	spawn_position_x = wall[1] / 2
	control_node.position = Vector2(spawn_position_x, block_width_half)
	prefab_node.position = prefab_position
	blocks.resize(grid_size.x * grid_size.y)
	blocks.fill(null)
	$Line2D.width = 1
	$Line2D.default_color = Color()
	$Line2D.add_point(Vector2(wall[1], 0))
	$Line2D.add_point(Vector2(wall[1], wall[2]))
	$HUD/Message.hide()
	spawn_prefab()


func _process(delta: float) -> void:
	if Input.is_action_pressed('move_down'):
		$Fall.wait_time = 0.05
	elif Input.is_action_just_released('move_down'):
		$Fall.wait_time = fall_wait_time


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		$Fall.timeout.emit()
		$Fall.wait_time = 0.05
	elif event.is_action_pressed('clockwise_rotation'):
		control_rotate(-PI / 2)
	elif event.is_action_pressed('counterclockwise_rotation'):
		control_rotate(PI / 2)


func _on_fall_timeout() -> void:
	var next_position = []
	for i in control_node.blocks:
		var next_pos = i.position + Vector2(0, block_width)
		if next_pos.y > wall[2]:
			fall_done()
			return
		if next_pos.y < 0:
			continue
		var next_index = position2index(next_pos)
		if blocks[next_index] != null:
			fall_done()
			return
		next_position.append(next_pos)
	control_node.position.y += block_width


func _on_move_x_timeout() -> void:
	var input_x = Input.get_axis('move_left', 'move_right')
	if not input_x:
		return
	var next_position = []
	for i in control_node.blocks:
		var next_pos = i.position + Vector2(block_width * input_x, 0)
		if next_pos.x < wall[0] or next_pos.x > wall[1]:
			return
		var next_index = position2index(next_pos)
		if blocks[next_index] != null:
			return
		next_position.append(next_pos)
	control_node.position.x += input_x * block_width


func control_rotate(radians: float):
	control_node.custom_rotate(radians)
	await get_tree().physics_frame
	for i in control_node.blocks:
		if i.position.x < wall[0]:
			control_node.position.x += wall[0] - i.position.x + block_width_half
		elif  i.position.x > wall[1]:
			control_node.position.x += wall[1] - i.position.x - block_width_half


func fall_done():
	for i in control_node.blocks:
		if i.position.y < 0:
			game_over()
			return
		if i.position.y < block_top:
			block_top = i.position.y
	var res = 0 
	var level = 0
	for i in control2bolck():
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
		var reverse_i = range(int(block_top / block_width), i)
		reverse_i.reverse()
		for j in reverse_i:
			for k in range(grid_size.x):
				res = j * grid_size.x + k
				if blocks[res] != null:
					blocks[res].position.y += block_width
					blocks[res + grid_size.x] = blocks[res]
					blocks[res] = null
	score += score_level[level]
	fall_wait_time = max(fall_wait_time - score_level[level] * 0.01, 0.05)
	$HUD/Score.text = str(score)
	prefab2control()


func game_over():
	$Fall.stop()
	$MoveX.stop()
	$HUD/Message.show()
	await get_tree().create_timer(3).timeout
	$HUD/Message.hide()
	$HUD/Title.show()
	$HUD/StartButton.show()
	control_node.free_blocks()
	control_node.free_remote_transform()
	prefab_node.free_blocks()
	prefab_node.free_remote_transform()
	for i in blocks:
		if i != null:
			i.free()
	spawn_prefab()


func control2bolck() -> Array:
	var rows = []
	for i in control_node.blocks:
		blocks[position2index(i.position)] = i
		var row = int(i.position.y / block_width)
		if row not in rows:
			rows.append(int(i.position.y / block_width))
	control_node.clear_blocks_free_remote_transform()
	rows.sort()
	return rows


func position2index(pos: Vector2):
	return int(pos.x / block_width) +  grid_size.x * int(pos.y / block_width)


func _on_start_button_pressed() -> void:
	$HUD/StartButton.hide()
	$HUD/Title.hide()
	prefab2control()
	$Fall.start()
	$MoveX.start()


func prefab2control():
	var switch_node = prefab_node
	prefab_node = control_node
	control_node = switch_node
	control_node.position = Vector2(spawn_position_x, control_node.blocks[-1].position.y - prefab_position.y - 20)
	prefab_node.blocks.clear()
	spawn_prefab()


func spawn_prefab():
	prefab_node.position = prefab_position
	var prefab_random = prefab_arr.pick_random()
	for i in prefab_random.position_list:
		var block_instance = block_scene.instantiate()
		block_instance.position = i
		add_child(block_instance)
		prefab_node.add_remote_transform(i, block_instance)
	prefab_node.rotate_able = prefab_random.rotate_able
	prefab_node.custom_rotate(randi_range(0, 4) * PI/2)
