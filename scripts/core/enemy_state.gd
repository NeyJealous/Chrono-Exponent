class_name EnemyState
extends RefCounted

var slot_index: int
var kind: String
var max_hp: float
var hp: float
var is_boss: bool

var max_shield := 0.0
var shield := 0.0
var armor_reduction := 0.0
var regen_per_second := 0.0

func _init(
	p_slot_index: int,
	p_kind: String,
	p_max_hp: float,
	p_is_boss: bool = false
) -> void:
	slot_index = p_slot_index
	kind = p_kind
	max_hp = max(1.0, p_max_hp)
	hp = max_hp
	is_boss = p_is_boss

	match kind:
		"Armored":
			armor_reduction = 0.20
		"Shielded":
			max_shield = max_hp * 0.35
			shield = max_shield
		"Regenerator":
			regen_per_second = max_hp * 0.01

func is_alive() -> bool:
	return hp > 0.0

func health_ratio() -> float:
	if max_hp <= 0.0:
		return 0.0
	return clampf(hp / max_hp, 0.0, 1.0)

func shield_ratio() -> float:
	if max_shield <= 0.0:
		return 0.0
	return clampf(shield / max_shield, 0.0, 1.0)

func tick(delta: float) -> void:
	if not is_alive() or regen_per_second <= 0.0:
		return
	hp = min(max_hp, hp + regen_per_second * delta)

func apply_damage(amount: float) -> float:
	if amount <= 0.0 or not is_alive():
		return 0.0

	var remaining: float = amount
	var applied: float = 0.0

	if shield > 0.0:
		var shield_damage: float = min(shield, remaining)
		shield -= shield_damage
		remaining -= shield_damage
		applied += shield_damage

	if remaining > 0.0 and hp > 0.0:
		var effective: float = remaining * (1.0 - armor_reduction)
		var health_damage: float = min(hp, effective)
		hp -= health_damage
		applied += health_damage

	return applied

func status_text() -> String:
	if max_shield > 0.0 and shield > 0.0:
		return "%s  SHIELD %d%%" % [kind, int(round(shield_ratio() * 100.0))]
	if armor_reduction > 0.0:
		return "%s  ARMOR" % kind
	if regen_per_second > 0.0:
		return "%s  REGEN" % kind
	return kind
