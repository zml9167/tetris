class_name Controller extends Node2D

var blocks: Array = []
var degrees_list = []

var degrees_index: int
var prefab_index: int


func add_remote_transform(pos: Vector2, instance):
	var remote_transform = RemoteTransform2D.new()
	add_child(remote_transform)
	remote_transform.remote_path = remote_transform.get_path_to(instance)
	remote_transform.position = pos
	blocks.append(instance)


func free_remote_transform():
	for i in get_children():
		i.free()


func random_rotate():
	var degrees_list_len = len(degrees_list)
	degrees_index = range(len(degrees_list)).pick_random()
	rotation_degrees = degrees_list[degrees_index % degrees_list_len]


func clear_blocks_free_remote_transform():
	blocks.clear()
	free_remote_transform()


func rotate_point_around_center(point: Vector2, center: Vector2, angle_deg: float) -> Vector2:
	# 1. 转换为相对于中心点的偏移坐标
	var offset = point - center
	
	# 2. 将角度转换为弧度（Godot 数学函数使用弧度）
	var angle_rad = deg_to_rad(angle_deg)
	
	# 3. 应用旋转矩阵计算新偏移
	# 旋转矩阵公式：
	# x' = x*cosθ - y*sinθ
	# y' = x*sinθ + y*cosθ
	var new_x = offset.x * cos(angle_rad) - offset.y * sin(angle_rad)
	var new_y = offset.x * sin(angle_rad) + offset.y * cos(angle_rad)
	
	# 4. 转换回世界坐标（加回中心点）
	return Vector2(new_x, new_y) + center


func place(pos: Vector2):
	position = pos
	degrees_list = Global.prefab_arr[prefab_index].rotation_list
	var degrees_list_len = len(degrees_list)
	rotation_degrees = degrees_list[degrees_index % degrees_list_len]
