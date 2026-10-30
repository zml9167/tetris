extends Resource

class_name Piece

@export var piece_id: String
@export var cells: PackedVector2Array
@export_range(1, 4, 1) var rotation_steps_count: int = 4
