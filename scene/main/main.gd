extends Node

@export var block_scene: PackedScene = preload("res://scene/block/block.tscn")
@export var pause_menu_scene: PackedScene
@export var block_width: float = 40
@export var grid_size: Vector2 = Vector2(15, 20)
@export var fall_wait_time := 0.5
@export var score_level := [0, 1, 3, 5, 7]

var score = 0
var block_width_half = roundi(block_width / 2)
var wall = {'left': 0, 'right': grid_size.x * block_width, 'bottom': block_width * grid_size.y}
var spawn_position_x: float = roundi(wall['right'] / 2)
var control_node: Controller = Controller.new()
var prefab_node: Controller = Controller.new()
var blocks: Array

@onready var prefab_position: Vector2 = $PreFabPoint.position
@onready var pause_menu = $PauseMenu
@onready var stack_top = wall['bottom']


func _init() -> void:
	blocks.resize(roundi(grid_size.x * grid_size.y))
	blocks.fill(null)


func _ready() -> void:
	add_child(control_node)
	add_child(prefab_node)
	control_node.position = Vector2(spawn_position_x, block_width_half)
	prefab_node.position = prefab_position
	$Line2D.width = 1
	$Line2D.default_color = Color()
	$Line2D.add_point(Vector2(wall['right'], 0))
	$Line2D.add_point(Vector2(wall['right'], wall['bottom']))
	start_game()


func position2index(pos: Vector2):
	var x = int(pos.x / block_width)
	var y = int(pos.y / block_width)
	# boundary check
	if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y:
		return -1
	return x + grid_size.x * y


func get_block_by_position(value: Vector2):
	var index = position2index(value)
	if index < 0 or index >= len(blocks):
		return null
	return blocks[index]


func _process(_delta: float) -> void:
	if $Fall.is_stopped():
		return
	if Input.is_action_pressed('move_down'):
		$Fall.wait_time = 0.05
	elif Input.is_action_just_released('move_down'):
		$Fall.wait_time = fall_wait_time


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('move_down'):
		$Fall.timeout.emit()
		$Fall.wait_time = 0.05
	elif event.is_action_pressed('clockwise_rotation'):
		control_node.custom_rotate(1)
	elif event.is_action_pressed('counterclockwise_rotation'):
		control_node.custom_rotate(-1)
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
	for i: Node2D in control_node.blocks:
		var next_pos = i.global_position + Vector2(0, block_width)
		if next_pos.y > wall['bottom']:
			fall_done()
			return
		if next_pos.y < 0:
			continue
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
	for i in control_node.blocks:
		var next_pos = i.position + Vector2(block_width * input_x, 0)
		if next_pos.x < wall['left'] or next_pos.x > wall['right']:
			return
		var next_index = position2index(next_pos)
		if blocks[next_index] != null:
			return
	control_node.position.x += input_x * block_width


func fall_done():
	$MoveX.stop()
	for i in control_node.blocks:
		if i.position.y < 0:
			game_over()
			return
		if i.position.y < stack_top:
			stack_top = i.position.y
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
		var reverse_i = range(int(stack_top / block_width), i)
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
	$Score.text = str(score)
	prefab2control()


func game_over():
	$Fall.stop()
	$MoveX.stop()
	$GameOver.show()
	Global.save_highest_score(score)
	var tween = create_tween()
	tween.tween_property($GameOver/ColorRect, "color", Color.BLACK, 3)
	tween.tween_callback(func (): get_tree().change_scene_to_file("res://scene/title/title.tscn"))


func start_game():
	random_spawn_prefab()
	prefab2control()
	$Fall.start()


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


func _on_move_x_tigger_timeout() -> void:
	$MoveX.start()


func prefab2control():
	var switch_node = prefab_node
	prefab_node = control_node
	control_node = switch_node
	control_node.position = Vector2(spawn_position_x, control_node.blocks[-1].position.y - prefab_position.y - block_width_half)
	prefab_node.blocks.clear()
	random_spawn_prefab()


func spawn_prefab(prefab_index: int):
	prefab_node.position = prefab_position
	var prefab: Prefab = Global.prefab_arr[prefab_index]
	prefab_node.degrees_list = prefab.rotation_list
	prefab_node.prefab_index = prefab_index
	for i in prefab.position_list:
		var block_instance = block_scene.instantiate()
		var pos_val = i * prefab.block_width
		block_instance.position = pos_val
		add_child(block_instance)
		prefab_node.add_remote_transform(pos_val, block_instance)


func random_spawn_prefab():
	var random_index = range(len(Global.prefab_arr)).pick_random()
	spawn_prefab(random_index)
	prefab_node.random_rotate()
