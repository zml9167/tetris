extends CanvasLayer

signal quit

func _on_back_pressed() -> void:
	hide()
	get_tree().paused = false
	get_viewport().set_input_as_handled()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")
