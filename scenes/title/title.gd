extends Node

@onready var highest_score: Label = $HighestScore
@onready var btn_play: Button = $VBoxContainer/Play
@onready var btn_continue: Button = $VBoxContainer/Continue
@onready var btn_abandon_run: Button = $VBoxContainer/AbandonRun
@onready var btn_exit: Button = $VBoxContainer/Exit
@onready var abandon_confirm_dialog: AcceptDialog = $AbandonConfirmDialog



func _ready() -> void:
	highest_score.text = 'Highest score: %d' % Global.highest_score
	if Global.save_data.has_save:
		btn_play.hide()
		btn_continue.show()
		btn_continue.grab_focus()
		btn_abandon_run.show()
	else:
		btn_play.show()
		btn_play.grab_focus()
		btn_continue.hide()
		btn_abandon_run.hide()

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
	abandon_confirm_dialog.popup_centered_clamped()


func _on_abandon_confirm_dialog_confirmed() -> void:
	Global.abandon_run()
	get_tree().paused = false
	get_tree().reload_current_scene()
