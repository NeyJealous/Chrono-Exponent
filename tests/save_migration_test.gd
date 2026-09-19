extends SceneTree

func _init() -> void:
	_test_v1_to_current()
	_test_v2_to_current()
	_test_normalization()
	_test_future_version_rejected()

	print("Chrono Exponent save migration tests passed.")
	quit(0)

func _test_v1_to_current() -> void:
	var legacy := {
		"save_version": 1,
		"wave": 12,
		"highest_wave": 20,
		"energy": 150.0,
		"fragments": 4.0,
		"weapon_level": 8,
		"unit_levels": [3, 2, 1]
	}

	var migrated := SaveSystem.migrate_data(legacy)

	_check(
		int(migrated.get("save_version", 0)) ==
		SaveSystem.CURRENT_SAVE_VERSION,
		"v1 migrates to current version"
	)
	_check(
		int(migrated.get("total_crits", -1)) == 0,
		"v1 migration adds total_crits"
	)
	_check(
		typeof(migrated.get("fracture_upgrades", null)) ==
		TYPE_DICTIONARY,
		"v1 migration adds Fracture Tree data"
	)

func _test_v2_to_current() -> void:
	var legacy := {
		"save_version": 2,
		"wave": 50,
		"highest_wave": 80,
		"total_crits": 17,
		"unit_levels": [10, 5, 1]
	}

	var migrated := SaveSystem.migrate_data(legacy)

	_check(
		int(migrated.get("save_version", 0)) ==
		SaveSystem.CURRENT_SAVE_VERSION,
		"v2 migrates to current version"
	)
	_check(
		int(migrated.get("total_crits", 0)) == 17,
		"existing statistics survive migration"
	)
	_check(
		migrated.has("fracture_upgrades"),
		"v2 migration creates Fracture Tree dictionary"
	)

func _test_normalization() -> void:
	var malformed := {
		"save_version": 3,
		"wave": -5,
		"highest_wave": -1,
		"energy": -100.0,
		"fragments": -3.0,
		"weapon_level": -4,
		"unit_levels": [5, -2]
	}

	var normalized := SaveSystem.migrate_data(malformed)
	var units: Array = normalized["unit_levels"]

	_check(int(normalized["wave"]) == 1, "wave is clamped")
	_check(
		int(normalized["highest_wave"]) >= int(normalized["wave"]),
		"highest_wave cannot be below current wave"
	)
	_check(float(normalized["energy"]) == 0.0, "energy is clamped")
	_check(float(normalized["fragments"]) == 0.0, "fragments are clamped")
	_check(int(normalized["weapon_level"]) == 0, "weapon level is clamped")
	_check(units.size() == 3, "unit array is normalized to three entries")
	_check(int(units[1]) == 0, "negative unit level is clamped")

func _test_future_version_rejected() -> void:
	var future := {
		"save_version": SaveSystem.CURRENT_SAVE_VERSION + 1,
		"wave": 999
	}

	var result := SaveSystem.migrate_data(future)
	_check(result.is_empty(), "future save versions are rejected safely")

func _check(condition: bool, message: String) -> void:
	if condition:
		return

	push_error("SAVE MIGRATION TEST FAILED: " + message)
	quit(1)
