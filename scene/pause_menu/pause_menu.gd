extends CanvasLayer

signal save

@export var title_packed := preload("res://scene/title/title.tscn")


func _on_back_pressed() -> void:
	hide()
	get_tree().paused = false
	get_viewport().set_input_as_handled()


func _on_save_quit_pressed() -> void:
	save.emit()
	get_tree().paused = false
	get_tree().change_scene_to_packed(title_packed)


func _on_save_pressed() -> void:
	save.emit()
