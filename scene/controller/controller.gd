class_name Controller extends Node2D


@export var block_scene: PackedScene = preload("res://scene/block/block.tscn")

var degrees_list = []
var degrees_index: int
var prefab_index: int
var next_degrees_index: int


func random_rotate():
	degrees_index = randi() % len(degrees_list)
	rotation_degrees = degrees_list[degrees_index]


func rotate_point_around_center(point: Vector2, angle_deg: float) -> Vector2:
	# 1. 转换为相对于中心点的偏移坐标
	var offset = point
	
	# 2. 将角度转换为弧度（Godot 数学函数使用弧度）
	var angle_rad = deg_to_rad(angle_deg)
	
	# 3. 应用旋转矩阵计算新偏移
	# 旋转矩阵公式：
	# x' = x*cosθ - y*sinθ
	# y' = x*sinθ + y*cosθ
	var new_x = offset.x * cos(angle_rad) - offset.y * sin(angle_rad)
	var new_y = offset.x * sin(angle_rad) + offset.y * cos(angle_rad)
	
	# 4. 转换回世界坐标（加回中心点）
	return Vector2(new_x, new_y)


func spawn(index: int):
	var prefab: Prefab = Global.prefab_arr[index]
	degrees_list = prefab.rotation_list
	prefab_index = index
	for vec2 in prefab.position_list:
		var block_instance = block_scene.instantiate()
		block_instance.position = vec2 * prefab.block_width
		add_child(block_instance)

func random_spawn():
	var index = randi() % len(Global.prefab_arr)
	spawn(index)
	random_rotate()


func pre_rotate(direction: int) -> Array:
	var degrees_list_len = len(degrees_list)
	next_degrees_index = degrees_index + direction
	var angle_deg = degrees_list[next_degrees_index % degrees_list_len] - degrees_list[degrees_index % degrees_list_len]
	var positions = []
	for i in get_children():
		var position_res = rotate_point_around_center(i.position, angle_deg)
		positions.append(position_res + position)
	return positions


func apply_rotate(move: Vector2):
	degrees_index = next_degrees_index
	position += move
	rotation_degrees = degrees_list[degrees_index % len(degrees_list)]


func place(save_data):
	position = save_data.position
	degrees_index = save_data.degrees_index
	prefab_index = save_data.prefab_index
	degrees_list = Global.prefab_arr[prefab_index].rotation_list
	spawn(prefab_index)
	rotation_degrees = degrees_list[degrees_index % len(degrees_list)]
