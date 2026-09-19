extends SceneTree

const STEP := 0.05
const TAP_INTERVAL := 0.25
const BUY_INTERVAL := 0.25
const MAX_RUN_SECONDS := 7200.0
const RUN_COUNT := 3

const MILESTONES := [10, 25, 50, 75, 100]

func _init() -> void:
	seed(1337)
	var state := GameState.new()
	var results: Array = []

	print("=== Chrono Exponent balance baseline ===")
	print("Strategy: 4 taps/sec + buy cheapest available upgrade")

	for run_index in RUN_COUNT:
		var result := _simulate_to_fracture(state)
		results.append(result)
		_print_run_result(run_index + 1, result)

		if int(result["reward"]) <= 0:
			push_error(
				"Balance baseline failed to reach Fracture within simulation cap."
			)
			quit(1)
			return

		state.fracture()
		_spend_fragments(state)

	_print_acceleration(results)
	_validate_guardrails(results)

	print("=== End baseline ===")
	quit(0)

func _simulate_to_fracture(state: GameState) -> Dictionary:
	var elapsed := 0.0
	var tap_timer := 0.0
	var buy_timer := 0.0

	var milestone_times: Dictionary = {}
	var unlock_times: Dictionary = {}
	var boss_failures := 0
	var last_purchase_time := 0.0
	var longest_purchase_drought := 0.0

	var previous_wave := state.wave

	_record_milestones(state, 0.0, milestone_times)
	_record_unit_unlocks(state, 0.0, unlock_times)

	while elapsed < MAX_RUN_SECONDS and state.fracture_reward() <= 0:
		state.tick(STEP)
		elapsed += STEP

		if state.wave < previous_wave:
			boss_failures += 1
		previous_wave = state.wave

		_record_milestones(
			state,
			elapsed,
			milestone_times
		)
		_record_unit_unlocks(
			state,
			elapsed,
			unlock_times
		)

		tap_timer += STEP
		while tap_timer >= TAP_INTERVAL:
			tap_timer -= TAP_INTERVAL
			var target := state.first_alive_enemy()
			if target != null:
				state.fire_at(target.slot_index)

		buy_timer += STEP
		if buy_timer >= BUY_INTERVAL:
			buy_timer = 0.0

			if _spend_energy(state):
				longest_purchase_drought = max(
					longest_purchase_drought,
					elapsed - last_purchase_time
				)
				last_purchase_time = elapsed

	longest_purchase_drought = max(
		longest_purchase_drought,
		elapsed - last_purchase_time
	)

	return {
		"seconds": elapsed,
		"wave": state.run_highest_wave,
		"reward": state.fracture_reward(),
		"gun_level": state.weapon_level,
		"unit_levels": state.unit_levels.duplicate(),
		"milestone_times": milestone_times,
		"unlock_times": unlock_times,
		"boss_failures": boss_failures,
		"longest_purchase_drought": longest_purchase_drought
	}

func _record_milestones(
	state: GameState,
	elapsed: float,
	times: Dictionary
) -> void:
	for milestone in MILESTONES:
		var key := str(milestone)
		if times.has(key):
			continue
		if state.run_highest_wave >= milestone:
			times[key] = elapsed

func _record_unit_unlocks(
	state: GameState,
	elapsed: float,
	times: Dictionary
) -> void:
	for unit_index in Balance.UNIT_DATA.size():
		var unit_id := String(Balance.UNIT_DATA[unit_index]["id"])
		if times.has(unit_id):
			continue

		if Balance.unit_is_unlocked(
			unit_index,
			state.highest_wave
		):
			times[unit_id] = elapsed

func _spend_energy(state: GameState) -> bool:
	var bought_anything := false

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
			return bought_anything

		if best_kind == "weapon":
			if not state.buy_weapon():
				return bought_anything
		else:
			if not state.buy_unit(best_index):
				return bought_anything

		bought_anything = true

	return bought_anything

func _spend_fragments(state: GameState) -> void:
	for _attempt in 128:
		var best_node_id := ""
		var best_cost := 2147483647

		for node in FractureTree.NODES:
			var node_id := String(node["id"])
			if FractureTree.is_maxed(
				state.fracture_upgrades,
				node_id
			):
				continue

			var cost := FractureTree.cost(
				state.fracture_upgrades,
				node_id
			)
			if cost > 0 and cost < best_cost:
				best_cost = cost
				best_node_id = node_id

		if best_node_id.is_empty() or state.fragments < best_cost:
			return

		if not state.buy_fracture_upgrade(best_node_id):
			return

func _print_run_result(run_number: int, result: Dictionary) -> void:
	print(
		"Run %d | time %s | wave %d | fragments +%d | gun %d | units %s" % [
			run_number,
			_format_time(float(result["seconds"])),
			int(result["wave"]),
			int(result["reward"]),
			int(result["gun_level"]),
			str(result["unit_levels"])
		]
	)

	var milestones: Dictionary = result["milestone_times"]
	var milestone_parts := PackedStringArray()
	for milestone in MILESTONES:
		var key := str(milestone)
		if milestones.has(key):
			milestone_parts.append(
				"W%d=%s" % [
					milestone,
					_format_time(float(milestones[key]))
				]
			)

	print("  milestones: " + ", ".join(milestone_parts))

	var unlocks: Dictionary = result["unlock_times"]
	var unlock_parts := PackedStringArray()
	for unit in Balance.UNIT_DATA:
		var unit_id := String(unit["id"])
		if unlocks.has(unit_id):
			unlock_parts.append(
				"%s=%s" % [
					String(unit["name"]),
					_format_time(float(unlocks[unit_id]))
				]
			)

	print("  unlocks: " + ", ".join(unlock_parts))
	print(
		"  boss failures: %d | longest purchase drought: %s" % [
			int(result["boss_failures"]),
			_format_time(float(result["longest_purchase_drought"]))
		]
	)

func _print_acceleration(results: Array) -> void:
	if results.size() < 2:
		return

	print("=== Run acceleration ===")

	for i in range(1, results.size()):
		var previous := float(results[i - 1]["seconds"])
		var current := float(results[i]["seconds"])

		if previous <= 0.0:
			continue

		var speedup := previous / max(current, 0.001)
		var reduction := (1.0 - current / previous) * 100.0

		print(
			"Run %d → %d | %.2fx speed | %.1f%% less time" % [
				i,
				i + 1,
				speedup,
				reduction
			]
		)

func _validate_guardrails(results: Array) -> void:
	if results.is_empty():
		return

	var first_seconds := float(results[0]["seconds"])

	if first_seconds < 1200.0 or first_seconds > 4800.0:
		push_warning(
			"First Fracture is outside the broad 20–80 minute guardrail: %s" %
			_format_time(first_seconds)
		)

	if first_seconds < 1800.0 or first_seconds > 3600.0:
		push_warning(
			"First Fracture is outside the preferred 30–60 minute target."
		)

	for i in range(1, results.size()):
		var previous := float(results[i - 1]["seconds"])
		var current := float(results[i]["seconds"])

		if current > previous:
			push_warning(
				"Run %d is slower than Run %d; prestige upgrades need review." % [
					i + 1,
					i
				]
			)

func _format_time(seconds: float) -> String:
	var total := int(round(seconds))
	var hours := int(total / 3600)
	var minutes := int((total % 3600) / 60)
	var remaining := total % 60

	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, remaining]
	return "%02d:%02d" % [minutes, remaining]
