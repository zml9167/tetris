extends Node

enum GameMode {
	NEW_GAME,
	CONTINUE
}

const SAVE_PATH = 'user://save.res'

@export var config: GameConfig

var highest_score: int
var game_mode: GameMode = GameMode.NEW_GAME
var save_data: SaveData
var rng: RandomNumberGenerator


func _init() -> void:
	rng = RandomNumberGenerator.new() 
	if not FileAccess.file_exists(SAVE_PATH):
		save_data = SaveData.new()
	else:
		var loaded = ResourceLoader.load(SAVE_PATH)
		save_data = loaded if loaded is SaveData else SaveData.new()
	if save_data.has_save and save_data.current_piece_cells.size() == 0:
		save_data.has_save = false
	highest_score = save_data.highest_score
	if save_data.random_seed and save_data.random_state:
		rng.seed = save_data.random_seed
		rng.state = save_data.random_state
	else:
		rng.randomize()


func update_highest_score(score: int):
	if score <= highest_score:
		return
	highest_score = score


func save_game(data: Dictionary):
	save_data.hard_drop = data.hard_drop
	save_data.highest_score = highest_score
	save_data.stack_top = data.stack_top
	save_data.score = data.score
	save_data.random_seed = rng.seed
	save_data.random_state = rng.state
	save_data.grid.resize(data.blocks.size())
	save_data.grid.fill(false)
	for i in range(data.blocks.size()):
		if data.blocks[i] != null:
			save_data.grid[i] = true
	save_data.current_piece_position = data.current_piece_position
	save_data.current_piece_rotation = data.current_piece_rotation
	save_data.current_piece_cells = data.current_piece_cells
	save_data.next_piece_index = data.next_piece_index
	save_data.next_piece_rotation = data.next_piece_rotation
	save_data.current_piece_can_rotate = data.current_piece_can_rotate
	save_data.has_save = true
	var err = ResourceSaver.save(save_data, SAVE_PATH)
	if err != OK:
		push_error('save faild')
		save_data.has_save = false


func abandon_run():
	var new_data = SaveData.new()
	new_data.highest_score = highest_score
	save_data = new_data
	ResourceSaver.save(new_data, SAVE_PATH)
