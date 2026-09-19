class_name Balance
extends RefCounted

const BOSS_INTERVAL := 10
const BOSS_TIME_SECONDS := 30.0
const BOSS_HP_MULTIPLIER := 7.0
const BOSS_REWARD_MULTIPLIER := 6.0
const MAX_TARGET_SLOTS := 5

const ENEMY_HP_GROWTH := 1.135
const ENEMY_REWARD_GROWTH := 1.115

const BASE_CRIT_CHANCE := 0.05
const BASE_CRIT_MULTIPLIER := 2.0

const WEAPON_BASE_COST := 10.0
const WEAPON_COST_GROWTH := 1.15
const WEAPON_DAMAGE_GROWTH := 1.18

const UNIT_DATA := [
	{
		"id": "drone",
		"name": "Pulse Drone",
		"base_cost": 25.0,
		"cost_growth": 1.16,
		"base_dps": 2.0,
		"dps_growth": 1.19,
		"attack_interval": 0.35,
		"unlock_wave": 5
	},
	{
		"id": "beam",
		"name": "Beam Array",
		"base_cost": 250.0,
		"cost_growth": 1.17,
		"base_dps": 18.0,
		"dps_growth": 1.205,
		"attack_interval": 0.80,
		"unlock_wave": 20
	},
	{
		"id": "rail",
		"name": "Rail Cannon",
		"base_cost": 2500.0,
		"cost_growth": 1.18,
		"base_dps": 150.0,
		"dps_growth": 1.22,
		"attack_interval": 3.50,
		"unlock_wave": 40
	}
]

static func is_boss(wave: int) -> bool:
	return wave > 0 and wave % BOSS_INTERVAL == 0

static func enemy_count(wave: int) -> int:
	if is_boss(wave):
		return 1
	return clampi(1 + int((wave - 1) / 10), 1, MAX_TARGET_SLOTS)

static func wave_total_hp(wave: int) -> float:
	var hp := 12.0 * pow(ENEMY_HP_GROWTH, max(0, wave - 1))
	if is_boss(wave):
		hp *= BOSS_HP_MULTIPLIER
	return hp

static func enemy_hp(wave: int) -> float:
	return wave_total_hp(wave) / float(enemy_count(wave))

static func enemy_kind(wave: int, slot_index: int) -> String:
	if is_boss(wave):
		return "Boss"

	var key := wave + slot_index * 3
	if wave >= 35 and key % 7 == 0:
		return "Regenerator"
	if wave >= 25 and key % 5 == 0:
		return "Shielded"
	if wave >= 15 and key % 4 == 0:
		return "Armored"
	return "Basic"

static func enemy_reward(wave: int) -> float:
	var reward := 5.0 * pow(ENEMY_REWARD_GROWTH, max(0, wave - 1))
	if is_boss(wave):
		reward *= BOSS_REWARD_MULTIPLIER
	return reward

static func enemy_reward_share(wave: int) -> float:
	return enemy_reward(wave) / float(enemy_count(wave))

static func weapon_cost(level: int) -> float:
	return WEAPON_BASE_COST * pow(WEAPON_COST_GROWTH, level)

static func weapon_bulk_cost(level: int, quantity: int) -> float:
	return _geometric_bulk_cost(
		WEAPON_BASE_COST,
		WEAPON_COST_GROWTH,
		level,
		quantity
	)

static func weapon_max_affordable(level: int, budget: float) -> int:
	return _max_affordable_levels(
		WEAPON_BASE_COST,
		WEAPON_COST_GROWTH,
		level,
		budget
	)

static func tap_damage(level: int, _fragments: float) -> float:
	return pow(WEAPON_DAMAGE_GROWTH, level)

static func crit_chance(_weapon_level: int, _fragments: float) -> float:
	return BASE_CRIT_CHANCE

static func crit_multiplier(_weapon_level: int, _fragments: float) -> float:
	return BASE_CRIT_MULTIPLIER

static func unit_is_unlocked(unit_index: int, highest_wave: int) -> bool:
	return highest_wave >= int(UNIT_DATA[unit_index]["unlock_wave"])

static func unit_unlock_wave(unit_index: int) -> int:
	return int(UNIT_DATA[unit_index]["unlock_wave"])

static func unit_cost(unit_index: int, level: int) -> float:
	var data: Dictionary = UNIT_DATA[unit_index]
	return float(data["base_cost"]) * pow(float(data["cost_growth"]), level)

static func unit_bulk_cost(unit_index: int, level: int, quantity: int) -> float:
	var data: Dictionary = UNIT_DATA[unit_index]
	return _geometric_bulk_cost(
		float(data["base_cost"]),
		float(data["cost_growth"]),
		level,
		quantity
	)

static func unit_max_affordable(
	unit_index: int,
	level: int,
	budget: float
) -> int:
	var data: Dictionary = UNIT_DATA[unit_index]
	return _max_affordable_levels(
		float(data["base_cost"]),
		float(data["cost_growth"]),
		level,
		budget
	)

static func unit_dps(unit_index: int, level: int, _fragments: float) -> float:
	if level <= 0:
		return 0.0
	var data: Dictionary = UNIT_DATA[unit_index]
	return float(data["base_dps"]) * pow(float(data["dps_growth"]), level - 1)

static func unit_attack_interval(unit_index: int) -> float:
	return float(UNIT_DATA[unit_index]["attack_interval"])

static func unit_damage_per_attack(unit_index: int, level: int, fragments: float) -> float:
	return unit_dps(unit_index, level, fragments) * unit_attack_interval(unit_index)

static func fracture_reward(highest_wave: int) -> int:
	if highest_wave < 100:
		return 0
	return int(floor(pow(float(highest_wave) / 50.0, 1.5)))

static func format_number(value: float) -> String:
	if value < 0.0:
		return "-" + format_number(abs(value))
	if value < 1000.0:
		return "%.1f" % value
	if value < 1000000.0:
		return "%.0f" % value
	if value == 0.0:
		return "0"
	var exponent := int(floor(log(value) / log(10.0)))
	var mantissa := value / pow(10.0, exponent)
	return "%.3fe%d" % [mantissa, exponent]

static func _geometric_bulk_cost(
	base_cost: float,
	growth: float,
	current_level: int,
	quantity: int
) -> float:
	if quantity <= 0:
		return 0.0

	var first_cost: float = base_cost * pow(growth, current_level)
	if abs(growth - 1.0) < 0.000001:
		return first_cost * quantity

	return first_cost * (pow(growth, quantity) - 1.0) / (growth - 1.0)

static func _max_affordable_levels(
	base_cost: float,
	growth: float,
	current_level: int,
	budget: float
) -> int:
	if budget <= 0.0:
		return 0

	var first_cost := base_cost * pow(growth, current_level)
	if budget < first_cost:
		return 0

	if abs(growth - 1.0) < 0.000001:
		return int(floor(budget / first_cost))

	var scaled: float = 1.0 + budget * (growth - 1.0) / first_cost
	var levels: int = max(0, int(floor(log(scaled) / log(growth))))

	while levels > 0 and _geometric_bulk_cost(
		base_cost,
		growth,
		current_level,
		levels
	) > budget:
		levels -= 1

	while _geometric_bulk_cost(
		base_cost,
		growth,
		current_level,
		levels + 1
	) <= budget:
		levels += 1

	return levels
