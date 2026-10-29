extends CanvasLayer

signal quit

@onready var btn_back: Button = $VBoxContainer/Back


func _on_back_pressed() -> void:
	hide()
	get_tree().paused = false
	get_viewport().set_input_as_handled()


func _on_quit_pressed() -> void:
	quit.emit()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title/title.tscn")


func _on_game_show_pause_menu() -> void:
	get_tree().paused = true
	show()
	btn_back.grab_focus()
