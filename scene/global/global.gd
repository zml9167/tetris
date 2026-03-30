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


class SaveData extends Resource:
	var fall_wait_time: int
	var stack_top: int 
	var grid: Array = []


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


func save_highest_score(score: int):
	if score <= highest_score:
		return
	highest_score = score
