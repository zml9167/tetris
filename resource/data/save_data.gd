extends Resource
class_name SaveData

@export var has_save: bool = false
@export var hard_drop: bool = false
@export var stack_top: float 
@export var grid: Array[bool]
@export var current_piece_position: Vector2
@export var current_piece_rotation: float
@export var current_piece_cells: Array[Vector2]
@export var next_piece_index: int
@export var next_piece_rotation: float
@export var highest_score: int
@export var score: int
@export var random_seed: int
@export var random_state: int
@export var current_piece_can_rotate: bool = true
