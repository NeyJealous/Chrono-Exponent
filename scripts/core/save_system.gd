class_name SaveSystem
extends RefCounted

const SAVE_PATH := "user://chrono_exponent_save.json"
const CURRENT_SAVE_VERSION := 4

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
			3:
				data = _migrate_v3_to_v4(data)
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

static func _migrate_v3_to_v4(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)

	var current_wave := max(1, int(migrated.get("wave", 1)))
	migrated["run_time"] = 0.0
	migrated["run_start_wave"] = current_wave
	migrated["run_highest_wave"] = current_wave
	migrated["run_damage"] = 0.0
	migrated["run_energy_earned"] = 0.0
	migrated["run_kills"] = 0
	migrated["run_crits"] = 0
	migrated["run_bosses"] = 0
	migrated["last_fracture_summary"] = {}
	migrated["save_version"] = 4
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

	data["run_time"] = max(0.0, float(data.get("run_time", 0.0)))
	data["run_start_wave"] = max(
		1,
		int(data.get("run_start_wave", data["wave"]))
	)
	data["run_highest_wave"] = max(
		int(data["run_start_wave"]),
		int(data.get("run_highest_wave", data["wave"]))
	)
	data["run_damage"] = max(0.0, float(data.get("run_damage", 0.0)))
	data["run_energy_earned"] = max(
		0.0,
		float(data.get("run_energy_earned", 0.0))
	)
	data["run_kills"] = max(0, int(data.get("run_kills", 0)))
	data["run_crits"] = max(0, int(data.get("run_crits", 0)))
	data["run_bosses"] = max(0, int(data.get("run_bosses", 0)))

	if typeof(data.get("last_fracture_summary", {})) != TYPE_DICTIONARY:
		data["last_fracture_summary"] = {}
