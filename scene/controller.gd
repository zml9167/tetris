class_name Controller extends Node2D

var blocks: Array = []
var rotate_able: bool = true


func add_remote_transform(pos: Vector2, instance):
	var remote_transform = RemoteTransform2D.new()
	add_child(remote_transform)
	remote_transform.remote_path = remote_transform.get_path_to(instance)
	remote_transform.position = pos
	blocks.append(instance)


func free_remote_transform():
	for i in get_children():
		i.free()


func custom_rotate(radians: float) -> void:
	if rotate_able:
		rotate(radians)


func clear_blocks_free_remote_transform():
	blocks.clear()
	free_remote_transform()
