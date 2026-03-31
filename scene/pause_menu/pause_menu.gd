extends CanvasLayer

signal save

@export var title_scene_path :String


func _on_back_pressed() -> void:
	hide()
	get_tree().paused = false
	get_viewport().set_input_as_handled()


func _on_save_quit_pressed() -> void:
	save.emit()
	get_tree().paused = false
	get_tree().change_scene_to_file(title_scene_path)


func _on_save_pressed() -> void:
	save.emit()
