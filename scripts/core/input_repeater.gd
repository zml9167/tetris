class_name InputRepeater

signal input_repeated(direction: int)

const DELAY = 0.2
const INTERVAL = 0.05

var _direction := 0
var _timer := 0.0


func _reset() -> void:
	_direction = 0
	_timer = 0.0


func update(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		direction = 1.0
	elif direction < 0:
		direction = -1.0
	else:
		_reset()
		return
	if direction != _direction:
		_direction = direction
		_timer = DELAY
		input_repeated.emit(_direction)

	_timer -= delta
	if _timer > 0.0:
		return
	_timer += INTERVAL
	input_repeated.emit(_direction)
