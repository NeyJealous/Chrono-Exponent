class_name FractureTree
extends RefCounted

const BRANCHES := [
	{"id": "arsenal", "name": "ARSENAL"},
	{"id": "squadron", "name": "SQUADRON"},
	{"id": "reactor", "name": "REACTOR"},
	{"id": "temporal", "name": "TEMPORAL"},
	{"id": "systems", "name": "SYSTEMS"}
]

const NODES := [
	{
		"id": "residual_caliber",
		"branch": "arsenal",
		"name": "Residual Caliber",
		"description": "+20% manual damage / level",
		"base_cost": 1,
		"cost_growth": 1.8,
		"max_level": 20
	},
	{
		"id": "critical_memory",
		"branch": "arsenal",
		"name": "Critical Memory",
		"description": "+0.5% crit chance / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "heavy_chamber",
		"branch": "arsenal",
		"name": "Heavy Chamber",
		"description": "+0.10 crit multiplier / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "team_synchronization",
		"branch": "squadron",
		"name": "Team Synchronization",
		"description": "+15% Team DPS / level",
		"base_cost": 1,
		"cost_growth": 1.8,
		"max_level": 20
	},
	{
		"id": "calibration",
		"branch": "squadron",
		"name": "Calibration",
		"description": "+3% unit attack speed / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "targeting_network",
		"branch": "squadron",
		"name": "Targeting Network",
		"description": "+10% Team boss damage / level",
		"base_cost": 3,
		"cost_growth": 2.1,
		"max_level": 10
	},
	{
		"id": "residual_energy",
		"branch": "reactor",
		"name": "Residual Energy",
		"description": "+10% Energy / level",
		"base_cost": 1,
		"cost_growth": 1.8,
		"max_level": 20
	},
	{
		"id": "boss_harvest",
		"branch": "reactor",
		"name": "Boss Harvest",
		"description": "+15% boss Energy / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "deep_extraction",
		"branch": "reactor",
		"name": "Deep Extraction",
		"description": "Energy scales with wave depth",
		"base_cost": 3,
		"cost_growth": 2.1,
		"max_level": 10
	},
	{
		"id": "starting_charge",
		"branch": "temporal",
		"name": "Starting Charge",
		"description": "+25 starting Energy / level",
		"base_cost": 1,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "wave_memory",
		"branch": "temporal",
		"name": "Wave Memory",
		"description": "+2 starting waves / level",
		"base_cost": 3,
		"cost_growth": 2.2,
		"max_level": 10
	},
	{
		"id": "fragment_echo",
		"branch": "temporal",
		"name": "Fragment Echo",
		"description": "+10% Fragments / level",
		"base_cost": 4,
		"cost_growth": 2.2,
		"max_level": 10
	},
	{
		"id": "auto_fire",
		"branch": "systems",
		"name": "Auto Fire",
		"description": "Unlock automatic player fire",
		"base_cost": 2,
		"cost_growth": 1.0,
		"max_level": 1
	},
	{
		"id": "targeting_assist",
		"branch": "systems",
		"name": "Targeting Assist",
		"description": "+5% Auto Fire rate / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	},
	{
		"id": "offline_processor",
		"branch": "systems",
		"name": "Offline Processor",
		"description": "+10% offline efficiency / level",
		"base_cost": 2,
		"cost_growth": 2.0,
		"max_level": 10
	}
]

static func level(upgrades: Dictionary, node_id: String) -> int:
	return int(upgrades.get(node_id, 0))

static func get_node(node_id: String) -> Dictionary:
	for node in NODES:
		if String(node["id"]) == node_id:
			return node
	return {}

static func nodes_for_branch(branch_id: String) -> Array:
	var result: Array = []
	for node in NODES:
		if String(node["branch"]) == branch_id:
			result.append(node)
	return result

static func cost(upgrades: Dictionary, node_id: String) -> int:
	var node := get_node(node_id)
	if node.is_empty():
		return 0

	var current_level := level(upgrades, node_id)
	if current_level >= int(node["max_level"]):
		return 0

	return max(
		1,
		int(ceil(
			float(node["base_cost"]) *
			pow(float(node["cost_growth"]), current_level)
		))
	)

static func is_maxed(upgrades: Dictionary, node_id: String) -> bool:
	var node := get_node(node_id)
	if node.is_empty():
		return true
	return level(upgrades, node_id) >= int(node["max_level"])

static func tap_multiplier(upgrades: Dictionary) -> float:
	return pow(1.20, level(upgrades, "residual_caliber"))

static func crit_chance_bonus(upgrades: Dictionary) -> float:
	return 0.005 * level(upgrades, "critical_memory")

static func crit_multiplier_bonus(upgrades: Dictionary) -> float:
	return 0.10 * level(upgrades, "heavy_chamber")

static func team_damage_multiplier(upgrades: Dictionary) -> float:
	return pow(1.15, level(upgrades, "team_synchronization"))

static func unit_attack_speed_multiplier(upgrades: Dictionary) -> float:
	return pow(1.03, level(upgrades, "calibration"))

static func boss_team_damage_multiplier(upgrades: Dictionary) -> float:
	return pow(1.10, level(upgrades, "targeting_network"))

static func energy_multiplier(upgrades: Dictionary) -> float:
	return pow(1.10, level(upgrades, "residual_energy"))

static func boss_energy_multiplier(upgrades: Dictionary) -> float:
	return pow(1.15, level(upgrades, "boss_harvest"))

static func depth_energy_multiplier(
	upgrades: Dictionary,
	wave: int
) -> float:
	var upgrade_level := level(upgrades, "deep_extraction")
	var depth_tier := int(max(0, wave - 1) / 10)
	return 1.0 + float(upgrade_level * depth_tier) * 0.01

static func starting_energy(upgrades: Dictionary) -> float:
	return 25.0 * level(upgrades, "starting_charge")

static func starting_wave(upgrades: Dictionary) -> int:
	return 1 + 2 * level(upgrades, "wave_memory")

static func fragment_multiplier(upgrades: Dictionary) -> float:
	return pow(1.10, level(upgrades, "fragment_echo"))

static func auto_fire_enabled(upgrades: Dictionary) -> bool:
	return level(upgrades, "auto_fire") > 0

static func auto_fire_interval(upgrades: Dictionary) -> float:
	var speed := pow(1.05, level(upgrades, "targeting_assist"))
	return 0.50 / speed

static func offline_multiplier(upgrades: Dictionary) -> float:
	return pow(1.10, level(upgrades, "offline_processor"))
