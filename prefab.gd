class_name Prefab

var position_list: Array
var rotate_able: bool


func _init(pos_list: Array, rotate: bool=true) -> void:
	position_list = pos_list
	rotate_able = rotate
