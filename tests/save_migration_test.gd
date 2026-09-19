extends SceneTree

func _init() -> void:
	_test_v1_to_current()
	_test_v2_to_current()
	_test_v3_to_current()
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

func _test_v3_to_current() -> void:
	var legacy := {
		"save_version": 4,
		"wave": 42,
		"highest_wave": 120,
		"fracture_upgrades": {"residual_caliber": 2},
		"unit_levels": [4, 3, 2]
	}

	var migrated := SaveSystem.migrate_data(legacy)

	_check(
		int(migrated.get("save_version", 0)) ==
		SaveSystem.CURRENT_SAVE_VERSION,
		"v3 migrates to current version"
	)
	_check(
		int(migrated.get("run_start_wave", 0)) == 42,
		"v3 migration starts run tracking from current wave"
	)
	_check(
		int(migrated.get("run_highest_wave", 0)) == 42,
		"v3 migration does not grant retroactive Fracture depth"
	)
	_check(
		typeof(migrated.get("last_fracture_summary", null)) ==
		TYPE_DICTIONARY,
		"v3 migration adds last Fracture summary"
	)

func _test_normalization() -> void:
	var malformed := {
		"save_version": 3,
		"wave": -5,
		"highest_wave": -1,
		"energy": -100.0,
		"fragments": -3.0,
		"weapon_level": -4,
		"unit_levels": [5, -2],
		"run_time": -10.0,
		"run_start_wave": -2,
		"run_highest_wave": -5,
		"run_damage": -20.0,
		"run_energy_earned": -30.0,
		"run_kills": -4,
		"last_fracture_summary": "invalid"
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
	_check(float(normalized["run_time"]) == 0.0, "run time is clamped")
	_check(int(normalized["run_start_wave"]) >= 1, "run start wave is clamped")
	_check(
		int(normalized["run_highest_wave"]) >= int(normalized["wave"]),
		"run highest wave cannot be below current wave"
	)
	_check(float(normalized["run_damage"]) == 0.0, "run damage is clamped")
	_check(
		typeof(normalized["last_fracture_summary"]) == TYPE_DICTIONARY,
		"invalid run summary is normalized"
	)

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
