extends Resource
class_name Prefab

@export var position_list: Array[Vector2]
@export var rotation_list: Array[int] = [0, 90, 180, 270]
@export_range(0, 100, 0.5) var block_width: float
