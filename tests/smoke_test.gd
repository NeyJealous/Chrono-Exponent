extends SceneTree

func _init() -> void:
	var state := GameState.new()

	_check(state.wave == 1, "new game starts at Wave 1")
	_check(state.enemies.size() == 1, "Wave 1 spawns one enemy")
	_check(state.get_enemy(0) != null, "slot 0 contains a target")

	state.energy = 1.0e12

	for _i in 12:
		_check(state.buy_weapon(), "weapon purchase succeeds")

	for unit_index in state.unit_levels.size():
		for _level in 8:
			_check(state.buy_unit(unit_index), "unit purchase succeeds")

	var starting_wave := state.wave

	for _step in 4000:
		state.tick(0.05)
		if state.wave > starting_wave:
			break

	_check(state.wave > starting_wave, "automatic units clear a wave")
	_check(state.total_damage > 0.0, "combat records damage")
	_check(state.total_kills > 0, "combat records kills")

	state.wave = 21
	state.highest_wave = 21
	state.start_wave()
	_check(state.enemies.size() == 3, "Wave 21 spawns three targets")

	state.highest_wave = 100
	var fragments_before := state.fragments
	_check(state.fracture(), "Fracture is available at Wave 100")
	_check(state.wave == 1, "Fracture resets current wave")
	_check(state.fragments > fragments_before, "Fracture awards Fragments")

	print("Chrono Exponent smoke test passed.")
	quit(0)

func _check(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("SMOKE TEST FAILED: " + message)
	quit(1)
