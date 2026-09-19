extends Control

var state := GameState.new()

var wave_label: Label
var energy_label: Label
var stats_label: Label
var hp_label: Label
var boss_label: Label
var target_button: Button
var weapon_button: Button
var unit_buttons: Array[Button] = []
var fracture_button: Button
var offline_label: Label

var save_accumulator := 0.0

func _ready() -> void:
	_build_ui()
	var offline_seconds := SaveSystem.load_game(state)
	if offline_seconds > 1.0:
		var gained := state.add_offline_reward(offline_seconds)
		offline_label.text = "Offline %.0fs  +%s Energy" % [offline_seconds, Balance.format_number(gained)]
	else:
		offline_label.text = ""
	_update_ui()

func _process(delta: float) -> void:
	state.tick(delta)
	save_accumulator += delta

	if save_accumulator >= 30.0:
		save_accumulator = 0.0
		SaveSystem.save_game(state)

	_update_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveSystem.save_game(state)

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.025, 0.03, 0.055, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)

	wave_label = Label.new()
	wave_label.add_theme_font_size_override("font_size", 34)
	wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(wave_label)

	energy_label = Label.new()
	energy_label.add_theme_font_size_override("font_size", 34)
	energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	energy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(energy_label)

	offline_label = Label.new()
	offline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	offline_label.add_theme_font_size_override("font_size", 18)
	root.add_child(offline_label)

	var arena := VBoxContainer.new()
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.alignment = BoxContainer.ALIGNMENT_CENTER
	arena.add_theme_constant_override("separation", 12)
	root.add_child(arena)

	boss_label = Label.new()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", 24)
	arena.add_child(boss_label)

	target_button = Button.new()
	target_button.text = "TARGET"
	target_button.custom_minimum_size = Vector2(520, 260)
	target_button.add_theme_font_size_override("font_size", 46)
	target_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	target_button.pressed.connect(_on_target_pressed)
	arena.add_child(target_button)

	hp_label = Label.new()
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 28)
	arena.add_child(hp_label)

	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 23)
	arena.add_child(stats_label)

	var purchases := HBoxContainer.new()
	purchases.add_theme_constant_override("separation", 10)
	root.add_child(purchases)

	weapon_button = Button.new()
	weapon_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weapon_button.pressed.connect(_on_weapon_pressed)
	purchases.add_child(weapon_button)

	for i in Balance.UNIT_DATA.size():
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_unit_pressed.bind(i))
		purchases.add_child(button)
		unit_buttons.append(button)

	fracture_button = Button.new()
	fracture_button.text = "FRACTURE"
	fracture_button.custom_minimum_size.y = 70
	fracture_button.pressed.connect(_on_fracture_pressed)
	root.add_child(fracture_button)

func _on_target_pressed() -> void:
	state.fire()
	_update_ui()

func _on_weapon_pressed() -> void:
	state.buy_weapon()
	_update_ui()

func _on_unit_pressed(index: int) -> void:
	state.buy_unit(index)
	_update_ui()

func _on_fracture_pressed() -> void:
	if state.fracture():
		SaveSystem.save_game(state)
	_update_ui()

func _update_ui() -> void:
	if wave_label == null:
		return

	wave_label.text = "WAVE %d" % state.wave
	energy_label.text = "%s ENERGY" % Balance.format_number(state.energy)

	hp_label.text = "HP  %s / %s" % [
		Balance.format_number(max(state.enemy_hp, 0.0)),
		Balance.format_number(state.enemy_max_hp)
	]

	if Balance.is_boss(state.wave):
		boss_label.text = "BOSS   %.1fs" % max(state.boss_time_left, 0.0)
		target_button.text = "BOSS"
	else:
		boss_label.text = ""
		target_button.text = "TARGET"

	stats_label.text = "Tap %s    DPS %s    Fragments %s" % [
		Balance.format_number(state.tap_damage()),
		Balance.format_number(state.total_dps()),
		Balance.format_number(state.fragments)
	]

	var weapon_cost := Balance.weapon_cost(state.weapon_level)
	weapon_button.text = "GUN Lv.%d\n%s" % [
		state.weapon_level,
		Balance.format_number(weapon_cost)
	]
	weapon_button.disabled = state.energy < weapon_cost

	for i in unit_buttons.size():
		var data: Dictionary = Balance.UNIT_DATA[i]
		var cost := Balance.unit_cost(i, state.unit_levels[i])
		unit_buttons[i].text = "%s Lv.%d\n%s" % [
			String(data["name"]),
			state.unit_levels[i],
			Balance.format_number(cost)
		]
		unit_buttons[i].disabled = state.energy < cost

	var reward := state.fracture_reward()
	fracture_button.text = "FRACTURE  +%d FRAGMENTS" % reward if reward > 0 else "FRACTURE — reach Wave 100"
	fracture_button.disabled = reward <= 0
