extends Node

enum GameMode {
	NEW_GAME,
	CONTINUE
}


@export var PREFAB_DIR := 'res://prefab/'

var highest_score: int
var has_save_data: bool
var prefab_arr: Array
var game_mode: GameMode = GameMode.NEW_GAME
var save_data: SaveData
var save_path = 'user://save.tres'


func load_prefab():
	var dir: DirAccess = DirAccess.open(PREFAB_DIR)
	if dir == null:
		print("Error prefab path %s" % PREFAB_DIR)
		return
	# 2. 遍历目录中的所有条目
	dir.list_dir_begin()  # 开始遍历
	var file_name: String = dir.get_next()  # 获取第一个条目
	while file_name:
		# 拼接完整文件路径
		var full_path: String = PREFAB_DIR + file_name
		var prefab: Resource = load(full_path)
		prefab_arr.append(prefab)
		# 获取下一个条目
		file_name = dir.get_next()
	# 结束遍历
	dir.list_dir_end()


func _init() -> void:
	load_prefab()
	if not FileAccess.file_exists(save_path):
		save_data = SaveData.new()
	else:
		save_data = load(save_path)
	if not save_data:
		save_data = SaveData.new()
	highest_score = save_data.highest_score


func save_highest_score(score: int):
	if score <= highest_score:
		return
	highest_score = score
	save_data.highest_score = highest_score
	ResourceSaver.save(save_data, save_path)


func save_game(blocks, stack_top, control_node, prefab_node, score):
	save_data.has_save = true
	save_data.highest_score = highest_score
	save_data.stack_top = stack_top
	save_data.score = score
	var grid = []
	grid.resize(len(blocks))
	grid.fill(0)
	for i in range(len(blocks)):
		if blocks[i] != null:
			grid[i] = 1
	save_data.grid = grid
	save_data.control_node = {
		'position': control_node.position,
		'degrees_index': control_node.degrees_index,
		'prefab_index': control_node.prefab_index
		}
	save_data.prefab_node = {
		'position': prefab_node.position,
		'degrees_index': prefab_node.degrees_index,
		'prefab_index': prefab_node.prefab_index
		}
	ResourceSaver.save(save_data, save_path)


func abandon_run():
	save_data.has_save = false
	save_data.control_node = {}
	save_data.prefab_node = {}
	save_data.grid = []
	save_data.fall_wait_time = 0
	save_data.stack_top = 0
	ResourceSaver.save(save_data, save_path)
	
