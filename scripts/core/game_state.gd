class_name GameState
extends RefCounted

var wave := 1
var highest_wave := 1
var energy := 0.0
var fragments := 0.0
var weapon_level := 0
var unit_levels := [0, 0, 0]

var enemy_hp := 0.0
var enemy_max_hp := 0.0
var boss_time_left := 0.0

var total_damage := 0.0
var total_energy := 0.0
var total_kills := 0
var bosses_defeated := 0
var fractures := 0
var play_time := 0.0

func _init() -> void:
	start_wave()

func start_wave() -> void:
	enemy_max_hp = Balance.enemy_hp(wave)
	enemy_hp = enemy_max_hp
	boss_time_left = Balance.BOSS_TIME_SECONDS if Balance.is_boss(wave) else 0.0

func tap_damage() -> float:
	return Balance.tap_damage(weapon_level, fragments)

func total_dps() -> float:
	var result := 0.0
	for i in unit_levels.size():
		result += Balance.unit_dps(i, unit_levels[i], fragments)
	return result

func fire() -> void:
	deal_damage(tap_damage())

func tick(delta: float) -> void:
	play_time += delta

	var dps := total_dps()
	if dps > 0.0:
		deal_damage(dps * delta)

	if Balance.is_boss(wave) and enemy_hp > 0.0:
		boss_time_left -= delta
		if boss_time_left <= 0.0:
			fail_boss()

func deal_damage(amount: float) -> void:
	if amount <= 0.0 or enemy_hp <= 0.0:
		return

	var applied := min(amount, enemy_hp)
	enemy_hp -= applied
	total_damage += applied

	if enemy_hp <= 0.0:
		complete_wave()

func complete_wave() -> void:
	var reward := Balance.enemy_reward(wave)
	energy += reward
	total_energy += reward
	total_kills += 1

	if Balance.is_boss(wave):
		bosses_defeated += 1

	wave += 1
	highest_wave = max(highest_wave, wave)
	start_wave()

func fail_boss() -> void:
	wave = max(1, wave - 1)
	start_wave()

func can_buy_weapon() -> bool:
	return energy >= Balance.weapon_cost(weapon_level)

func buy_weapon() -> bool:
	var cost := Balance.weapon_cost(weapon_level)
	if energy < cost:
		return false
	energy -= cost
	weapon_level += 1
	return true

func can_buy_unit(index: int) -> bool:
	return energy >= Balance.unit_cost(index, unit_levels[index])

func buy_unit(index: int) -> bool:
	var cost := Balance.unit_cost(index, unit_levels[index])
	if energy < cost:
		return false
	energy -= cost
	unit_levels[index] += 1
	return true

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
	start_wave()
	return true

func add_offline_reward(seconds: float) -> float:
	var capped_seconds := min(seconds, 12.0 * 60.0 * 60.0)
	var dps := max(total_dps(), tap_damage() * 0.25)
	var reward := dps * capped_seconds * 0.10
	energy += reward
	total_energy += reward
	return reward

func to_dict() -> Dictionary:
	return {
		"save_version": 1,
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
	bosses_defeated = int(data.get("bosses_defeated", 0))
	fractures = int(data.get("fractures", 0))
	play_time = float(data.get("play_time", 0.0))

	start_wave()

	var previous_timestamp := float(data.get("timestamp", Time.get_unix_time_from_system()))
	return max(0.0, Time.get_unix_time_from_system() - previous_timestamp)
