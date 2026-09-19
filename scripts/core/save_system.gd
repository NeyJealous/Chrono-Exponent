class_name SaveSystem
extends RefCounted

const SAVE_PATH := "user://chrono_exponent_save.json"

static func save_game(state: GameState) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state.to_dict()))
	file.close()
	return true

static func load_game(state: GameState) -> float:
	if not FileAccess.file_exists(SAVE_PATH):
		return 0.0

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return 0.0

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return 0.0

	return state.load_dict(parsed)
