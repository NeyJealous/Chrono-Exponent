extends SceneTree

func _init() -> void:
	var state := GameState.new()

	_check(state.wave == 1, "new game starts at Wave 1")
	_check(state.enemies.size() == 1, "Wave 1 spawns one enemy")
	_check(state.get_enemy(0) != null, "slot 0 contains a target")
	_check(
		not Balance.unit_is_unlocked(0, state.highest_wave),
		"Pulse Drone is milestone-locked at a fresh start"
	)

	state.energy = 1.0e12

	_check(
		state.buy_weapon_amount(10) == 10,
		"bulk weapon purchase buys ten levels"
	)

	state.highest_wave = 50

	for unit_index in state.unit_levels.size():
		_check(
			Balance.unit_is_unlocked(unit_index, state.highest_wave),
			"all prototype units unlock by Wave 50"
		)
		_check(
			state.buy_unit_amount(unit_index, 8) == 8,
			"bulk unit purchase succeeds"
		)

	var starting_wave := state.wave

	for _step in 4000:
		state.tick(0.05)
		if state.wave > starting_wave:
			break

	_check(state.wave > starting_wave, "automatic units clear a wave")
	_check(state.total_damage > 0.0, "combat records damage")
	_check(state.total_kills > 0, "combat records kills")

	state.wave = 21
	state.highest_wave = 50
	state.start_wave()
	_check(state.enemies.size() == 3, "Wave 21 spawns three targets")

	var manual_target := state.first_alive_enemy()
	_check(manual_target != null, "manual target exists")
	if manual_target != null:
		_check(
			state.fire_at(manual_target.slot_index),
			"manual shot can target a slot"
		)

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
