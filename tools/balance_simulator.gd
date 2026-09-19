extends SceneTree

const STEP := 0.05
const TAP_INTERVAL := 0.25
const BUY_INTERVAL := 0.25
const MAX_RUN_SECONDS := 7200.0
const RUN_COUNT := 3

func _init() -> void:
	var state := GameState.new()

	print("=== Chrono Exponent balance baseline ===")
	print("Strategy: 4 taps/sec + buy cheapest available upgrade")

	for run_index in RUN_COUNT:
		var result := _simulate_to_fracture(state)
		print(
			"Run %d | time %s | wave %d | fragments +%d | gun %d | units %s" % [
				run_index + 1,
				_format_time(float(result["seconds"])),
				int(result["wave"]),
				int(result["reward"]),
				state.weapon_level,
				str(state.unit_levels)
			]
		)

		if int(result["reward"]) <= 0:
			push_error(
				"Balance baseline failed to reach Fracture within simulation cap."
			)
			quit(1)
			return

		state.fracture()

	print("=== End baseline ===")
	quit(0)

func _simulate_to_fracture(state: GameState) -> Dictionary:
	var elapsed := 0.0
	var tap_timer := 0.0
	var buy_timer := 0.0

	while elapsed < MAX_RUN_SECONDS and state.fracture_reward() <= 0:
		state.tick(STEP)

		tap_timer += STEP
		while tap_timer >= TAP_INTERVAL:
			tap_timer -= TAP_INTERVAL
			var target := state.first_alive_enemy()
			if target != null:
				state.fire_at(target.slot_index)

		buy_timer += STEP
		if buy_timer >= BUY_INTERVAL:
			buy_timer = 0.0
			_spend_energy(state)

		elapsed += STEP

	return {
		"seconds": elapsed,
		"wave": state.highest_wave,
		"reward": state.fracture_reward()
	}

func _spend_energy(state: GameState) -> void:
	for _attempt in 32:
		var best_kind := "weapon"
		var best_index := -1
		var best_cost := Balance.weapon_cost(state.weapon_level)

		for unit_index in state.unit_levels.size():
			if not Balance.unit_is_unlocked(
				unit_index,
				state.highest_wave
			):
				continue

			var cost := Balance.unit_cost(
				unit_index,
				state.unit_levels[unit_index]
			)
			if cost < best_cost:
				best_cost = cost
				best_kind = "unit"
				best_index = unit_index

		if state.energy < best_cost:
			return

		if best_kind == "weapon":
			if not state.buy_weapon():
				return
		else:
			if not state.buy_unit(best_index):
				return

func _format_time(seconds: float) -> String:
	var total := int(round(seconds))
	var minutes := int(total / 60)
	var remaining := total % 60
	return "%02d:%02d" % [minutes, remaining]
