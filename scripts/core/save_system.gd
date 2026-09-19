class_name SaveSystem
extends RefCounted

const SAVE_PATH := "user://chrono_exponent_save.json"
const CURRENT_SAVE_VERSION := 3

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

	var migrated := migrate_data(parsed)
	if migrated.is_empty() and not parsed.is_empty():
		push_error(
			"Save file is newer than this build or could not be migrated."
		)
		return 0.0

	return state.load_dict(migrated)

static func migrate_data(source: Dictionary) -> Dictionary:
	var data: Dictionary = source.duplicate(true)
	var version := int(data.get("save_version", 1))

	if version < 1:
		version = 1
		data["save_version"] = 1

	if version > CURRENT_SAVE_VERSION:
		return {}

	while version < CURRENT_SAVE_VERSION:
		match version:
			1:
				data = _migrate_v1_to_v2(data)
			2:
				data = _migrate_v2_to_v3(data)
			_:
				return {}

		version = int(data.get("save_version", version + 1))

	_normalize_current(data)
	return data

static func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)

	if not migrated.has("total_crits"):
		migrated["total_crits"] = 0

	migrated["save_version"] = 2
	return migrated

static func _migrate_v2_to_v3(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)

	if not migrated.has("fracture_upgrades"):
		migrated["fracture_upgrades"] = {}

	migrated["save_version"] = 3
	return migrated

static func _normalize_current(data: Dictionary) -> void:
	data["save_version"] = CURRENT_SAVE_VERSION

	if not data.has("fracture_upgrades"):
		data["fracture_upgrades"] = {}

	var units: Array = data.get("unit_levels", [0, 0, 0])
	var normalized_units := [0, 0, 0]

	for i in min(units.size(), normalized_units.size()):
		normalized_units[i] = max(0, int(units[i]))

	data["unit_levels"] = normalized_units

	data["wave"] = max(1, int(data.get("wave", 1)))
	data["highest_wave"] = max(
		int(data["wave"]),
		int(data.get("highest_wave", data["wave"]))
	)
	data["energy"] = max(0.0, float(data.get("energy", 0.0)))
	data["fragments"] = max(0.0, float(data.get("fragments", 0.0)))
	data["weapon_level"] = max(0, int(data.get("weapon_level", 0)))
