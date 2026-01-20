extends Node


func _ready() -> void:
	$HighestScore.text = 'Highest score: %d' % Global.score


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
