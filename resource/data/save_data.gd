extends Resource
class_name SaveData

@export var has_save: bool = false
@export var stack_top: float 
@export var grid: Array[bool]
@export var current_piece_position: Vector2
@export var piece_index: Array[int]
@export var piece_rotation_step: Array[int]
@export var highest_score: int
@export var score: int
@export var random_seed: int
@export var random_state: int
