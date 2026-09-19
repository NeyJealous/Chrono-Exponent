class_name Balance
extends RefCounted

const BOSS_INTERVAL := 10
const BOSS_TIME_SECONDS := 30.0

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
		"dps_growth": 1.19
	},
	{
		"id": "beam",
		"name": "Beam Array",
		"base_cost": 250.0,
		"cost_growth": 1.17,
		"base_dps": 18.0,
		"dps_growth": 1.205
	},
	{
		"id": "rail",
		"name": "Rail Cannon",
		"base_cost": 2500.0,
		"cost_growth": 1.18,
		"base_dps": 150.0,
		"dps_growth": 1.22
	}
]

static func is_boss(wave: int) -> bool:
	return wave > 0 and wave % BOSS_INTERVAL == 0

static func enemy_hp(wave: int) -> float:
	var hp := 12.0 * pow(1.145, max(0, wave - 1))
	if is_boss(wave):
		hp *= 8.0
	return hp

static func enemy_reward(wave: int) -> float:
	var reward := 5.0 * pow(1.105, max(0, wave - 1))
	if is_boss(wave):
		reward *= 6.0
	return reward

static func weapon_cost(level: int) -> float:
	return WEAPON_BASE_COST * pow(WEAPON_COST_GROWTH, level)

static func tap_damage(level: int, fragments: float) -> float:
	var permanent_multiplier := 1.0 + fragments * 0.10
	return pow(WEAPON_DAMAGE_GROWTH, level) * permanent_multiplier

static func unit_cost(unit_index: int, level: int) -> float:
	var data: Dictionary = UNIT_DATA[unit_index]
	return float(data["base_cost"]) * pow(float(data["cost_growth"]), level)

static func unit_dps(unit_index: int, level: int, fragments: float) -> float:
	if level <= 0:
		return 0.0
	var data: Dictionary = UNIT_DATA[unit_index]
	var permanent_multiplier := 1.0 + fragments * 0.10
	return float(data["base_dps"]) * pow(float(data["dps_growth"]), level - 1) * permanent_multiplier

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
