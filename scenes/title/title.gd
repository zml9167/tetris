extends Node


func _ready() -> void:
	$HighestScore.text = 'Highest score: %d' % Global.highest_score
	if Global.save_data.has_save:
		$VBoxContainer2/VBoxContainer/Play.hide()
		$VBoxContainer2/VBoxContainer/Continue.show()
		$VBoxContainer2/VBoxContainer/AbandonRun.show()
	else:
		$VBoxContainer2/VBoxContainer/Play.show()
		$VBoxContainer2/VBoxContainer/Continue.hide()
		$VBoxContainer2/VBoxContainer/AbandonRun.hide()

func _change_to_game():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_play_pressed() -> void:
	Global.game_mode = Global.GameMode.NEW_GAME
	_change_to_game()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	Global.game_mode = Global.GameMode.CONTINUE
	_change_to_game()


func _on_abandon_run_pressed() -> void:
	$AbandonConfirmDialog.popup_centered_clamped()


func _on_abandon_confirm_dialog_confirmed() -> void:
	Global.abandon_run()
	get_tree().paused = false
	get_tree().reload_current_scene()
