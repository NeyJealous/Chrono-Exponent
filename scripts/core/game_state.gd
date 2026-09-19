class_name GameState
extends RefCounted

signal damage_dealt(slot_index: int, amount: float, is_crit: bool, source: String)
signal enemy_destroyed(slot_index: int, kind: String)
signal unit_attack(unit_index: int, slot_index: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal boss_failed(wave_number: int)

var wave := 1
var highest_wave := 1
var energy := 0.0
var fragments := 0.0
var weapon_level := 0
var unit_levels := [0, 0, 0]

var enemies: Array[EnemyState] = []
var boss_time_left := 0.0
var unit_attack_timers := [0.0, 0.0, 0.0]

var total_damage := 0.0
var total_energy := 0.0
var total_kills := 0
var total_crits := 0
var bosses_defeated := 0
var fractures := 0
var play_time := 0.0

func _init() -> void:
	start_wave()

func start_wave() -> void:
	enemies.clear()

	var count := Balance.enemy_count(wave)
	var hp_each := Balance.enemy_hp(wave)

	for slot_index in count:
		var kind := Balance.enemy_kind(wave, slot_index)
		enemies.append(EnemyState.new(
			slot_index,
			kind,
			hp_each,
			Balance.is_boss(wave)
		))

	boss_time_left = Balance.BOSS_TIME_SECONDS if Balance.is_boss(wave) else 0.0
	wave_started.emit(wave)

func tap_damage() -> float:
	return Balance.tap_damage(weapon_level, fragments)

func crit_chance() -> float:
	return Balance.crit_chance(weapon_level, fragments)

func crit_multiplier() -> float:
	return Balance.crit_multiplier(weapon_level, fragments)

func total_dps() -> float:
	var result := 0.0
	for i in unit_levels.size():
		result += Balance.unit_dps(i, unit_levels[i], fragments)
	return result

func fire_at(slot_index: int) -> bool:
	var enemy := get_enemy(slot_index)
	if enemy == null or not enemy.is_alive():
		return false

	var is_crit := randf() < crit_chance()
	var amount := tap_damage()
	if is_crit:
		amount *= crit_multiplier()
		total_crits += 1

	_deal_damage(enemy, amount, is_crit, "manual")
	return true

func tick(delta: float) -> void:
	if delta <= 0.0:
		return

	play_time += delta

	for enemy in enemies:
		enemy.tick(delta)

	_tick_units(delta)

	if Balance.is_boss(wave) and has_alive_enemies():
		boss_time_left -= delta
		if boss_time_left <= 0.0:
			fail_boss()

func _tick_units(delta: float) -> void:
	for unit_index in unit_levels.size():
		if unit_levels[unit_index] <= 0:
			continue

		unit_attack_timers[unit_index] += delta
		var interval := Balance.unit_attack_interval(unit_index)

		while unit_attack_timers[unit_index] >= interval:
			var target := first_alive_enemy()
			if target == null:
				break

			unit_attack_timers[unit_index] -= interval
			unit_attack.emit(unit_index, target.slot_index)

			var damage := Balance.unit_damage_per_attack(
				unit_index,
				unit_levels[unit_index],
				fragments
			)
			_deal_damage(
				target,
				damage,
				false,
				String(Balance.UNIT_DATA[unit_index]["id"])
			)

func _deal_damage(
	enemy: EnemyState,
	amount: float,
	is_crit: bool,
	source: String
) -> void:
	if enemy == null or not enemy.is_alive() or amount <= 0.0:
		return

	var applied := enemy.apply_damage(amount)
	if applied <= 0.0:
		return

	total_damage += applied
	damage_dealt.emit(enemy.slot_index, applied, is_crit, source)

	if not enemy.is_alive():
		_on_enemy_destroyed(enemy)

func _on_enemy_destroyed(enemy: EnemyState) -> void:
	var reward := Balance.enemy_reward_share(wave)
	energy += reward
	total_energy += reward
	total_kills += 1

	enemy_destroyed.emit(enemy.slot_index, enemy.kind)

	if not has_alive_enemies():
		complete_wave()

func complete_wave() -> void:
	var completed_wave := wave

	if Balance.is_boss(completed_wave):
		bosses_defeated += 1

	wave_completed.emit(completed_wave)
	wave += 1
	highest_wave = max(highest_wave, wave)
	start_wave()

func fail_boss() -> void:
	var failed_wave := wave
	boss_failed.emit(failed_wave)
	wave = max(1, wave - 1)
	start_wave()

func has_alive_enemies() -> bool:
	for enemy in enemies:
		if enemy.is_alive():
			return true
	return false

func first_alive_enemy() -> EnemyState:
	for enemy in enemies:
		if enemy.is_alive():
			return enemy
	return null

func get_enemy(slot_index: int) -> EnemyState:
	for enemy in enemies:
		if enemy.slot_index == slot_index:
			return enemy
	return null

func can_buy_weapon() -> bool:
	return energy >= Balance.weapon_cost(weapon_level)

func buy_weapon() -> bool:
	return buy_weapon_amount(1) > 0

func buy_weapon_amount(quantity: int) -> int:
	var levels := quantity
	if quantity <= 0:
		levels = Balance.weapon_max_affordable(weapon_level, energy)

	if levels <= 0:
		return 0

	var cost := Balance.weapon_bulk_cost(weapon_level, levels)
	if cost > energy:
		return 0

	energy -= cost
	weapon_level += levels
	return levels

func can_buy_unit(index: int) -> bool:
	if index < 0 or index >= unit_levels.size():
		return false
	if not Balance.unit_is_unlocked(index, highest_wave):
		return false
	return energy >= Balance.unit_cost(index, unit_levels[index])

func buy_unit(index: int) -> bool:
	return buy_unit_amount(index, 1) > 0

func buy_unit_amount(index: int, quantity: int) -> int:
	if index < 0 or index >= unit_levels.size():
		return 0
	if not Balance.unit_is_unlocked(index, highest_wave):
		return 0

	var levels := quantity
	if quantity <= 0:
		levels = Balance.unit_max_affordable(
			index,
			unit_levels[index],
			energy
		)

	if levels <= 0:
		return 0

	var cost := Balance.unit_bulk_cost(index, unit_levels[index], levels)
	if cost > energy:
		return 0

	energy -= cost
	unit_levels[index] += levels
	return levels

func fracture_reward() -> int:
	return Balance.fracture_reward(highest_wave)

func can_fracture() -> bool:
	return fracture_reward() > 0

func fracture() -> bool:
	var reward := fracture_reward()
	if reward <= 0:
		return false

	fragments += reward
	fractures += 1
	wave = 1
	energy = 0.0
	weapon_level = 0
	unit_levels = [0, 0, 0]
	unit_attack_timers = [0.0, 0.0, 0.0]
	start_wave()
	return true

func add_offline_reward(seconds: float) -> float:
	var capped_seconds := min(seconds, 12.0 * 60.0 * 60.0)
	var effective_dps := max(total_dps(), tap_damage() * 0.25)
	var reward := effective_dps * capped_seconds * 0.10
	energy += reward
	total_energy += reward
	return reward

func to_dict() -> Dictionary:
	return {
		"save_version": 2,
		"timestamp": Time.get_unix_time_from_system(),
		"wave": wave,
		"highest_wave": highest_wave,
		"energy": energy,
		"fragments": fragments,
		"weapon_level": weapon_level,
		"unit_levels": unit_levels,
		"total_damage": total_damage,
		"total_energy": total_energy,
		"total_kills": total_kills,
		"total_crits": total_crits,
		"bosses_defeated": bosses_defeated,
		"fractures": fractures,
		"play_time": play_time
	}

func load_dict(data: Dictionary) -> float:
	wave = int(data.get("wave", 1))
	highest_wave = int(data.get("highest_wave", wave))
	energy = float(data.get("energy", 0.0))
	fragments = float(data.get("fragments", 0.0))
	weapon_level = int(data.get("weapon_level", 0))

	var loaded_units: Array = data.get("unit_levels", [0, 0, 0])
	for i in min(loaded_units.size(), unit_levels.size()):
		unit_levels[i] = int(loaded_units[i])

	total_damage = float(data.get("total_damage", 0.0))
	total_energy = float(data.get("total_energy", 0.0))
	total_kills = int(data.get("total_kills", 0))
	total_crits = int(data.get("total_crits", 0))
	bosses_defeated = int(data.get("bosses_defeated", 0))
	fractures = int(data.get("fractures", 0))
	play_time = float(data.get("play_time", 0.0))
	unit_attack_timers = [0.0, 0.0, 0.0]

	start_wave()

	var previous_timestamp := float(data.get(
		"timestamp",
		Time.get_unix_time_from_system()
	))
	return max(0.0, Time.get_unix_time_from_system() - previous_timestamp)
