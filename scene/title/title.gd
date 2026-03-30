extends Node


func _ready() -> void:
	$HighestScore.text = 'Highest score: %d' % Global.highest_score


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main/main.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
