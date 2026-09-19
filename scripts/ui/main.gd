extends Control

var state := GameState.new()

var wave_label: Label
var energy_label: Label
var stats_label: Label
var boss_label: Label
var offline_label: Label
var event_label: Label
var weapon_button: Button
var unit_buttons: Array[Button] = []
var fracture_button: Button

var target_cards: Array[VBoxContainer] = []
var target_buttons: Array[Button] = []
var target_bars: Array[ProgressBar] = []

var effects_layer: Control
var save_accumulator := 0.0
var event_message_time := 0.0

func _ready() -> void:
	_build_ui()
	_connect_game_signals()

	var offline_seconds := SaveSystem.load_game(state)
	if offline_seconds > 1.0:
		var gained := state.add_offline_reward(offline_seconds)
		offline_label.text = "Offline %.0fs   +%s Energy" % [
			offline_seconds,
			Balance.format_number(gained)
		]
	else:
		offline_label.text = ""

	_update_ui()

func _process(delta: float) -> void:
	state.tick(delta)
	save_accumulator += delta

	if event_message_time > 0.0:
		event_message_time -= delta
		if event_message_time <= 0.0:
			event_label.text = ""

	if save_accumulator >= 30.0:
		save_accumulator = 0.0
		SaveSystem.save_game(state)

	_update_ui()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveSystem.save_game(state)

func _connect_game_signals() -> void:
	state.damage_dealt.connect(_on_damage_dealt)
	state.enemy_destroyed.connect(_on_enemy_destroyed)
	state.wave_completed.connect(_on_wave_completed)
	state.boss_failed.connect(_on_boss_failed)

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.025, 0.03, 0.055, 1.0)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)

	wave_label = Label.new()
	wave_label.add_theme_font_size_override("font_size", 32)
	wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(wave_label)

	energy_label = Label.new()
	energy_label.add_theme_font_size_override("font_size", 32)
	energy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	energy_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(energy_label)

	offline_label = Label.new()
	offline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	offline_label.add_theme_font_size_override("font_size", 17)
	root.add_child(offline_label)

	event_label = Label.new()
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.add_theme_font_size_override("font_size", 20)
	root.add_child(event_label)

	var arena := VBoxContainer.new()
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena.alignment = BoxContainer.ALIGNMENT_CENTER
	arena.add_theme_constant_override("separation", 8)
	root.add_child(arena)

	boss_label = Label.new()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.add_theme_font_size_override("font_size", 24)
	arena.add_child(boss_label)

	var target_grid := GridContainer.new()
	target_grid.columns = 3
	target_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	target_grid.add_theme_constant_override("h_separation", 14)
	target_grid.add_theme_constant_override("v_separation", 10)
	arena.add_child(target_grid)

	for slot_index in Balance.MAX_TARGET_SLOTS:
		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(300, 128)
		card.add_theme_constant_override("separation", 4)
		target_grid.add_child(card)
		target_cards.append(card)

		var button := Button.new()
		button.custom_minimum_size = Vector2(300, 100)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_target_pressed.bind(slot_index))
		card.add_child(button)
		target_buttons.append(button)

		var hp_bar := ProgressBar.new()
		hp_bar.custom_minimum_size = Vector2(300, 18)
		hp_bar.min_value = 0.0
		hp_bar.max_value = 100.0
		hp_bar.show_percentage = false
		card.add_child(hp_bar)
		target_bars.append(hp_bar)

	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 21)
	arena.add_child(stats_label)

	var purchases := HBoxContainer.new()
	purchases.add_theme_constant_override("separation", 8)
	root.add_child(purchases)

	weapon_button = Button.new()
	weapon_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weapon_button.custom_minimum_size.y = 72
	weapon_button.pressed.connect(_on_weapon_pressed)
	purchases.add_child(weapon_button)

	for i in Balance.UNIT_DATA.size():
		var button := Button.new()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 72
		button.pressed.connect(_on_unit_pressed.bind(i))
		purchases.add_child(button)
		unit_buttons.append(button)

	fracture_button = Button.new()
	fracture_button.text = "FRACTURE"
	fracture_button.custom_minimum_size.y = 62
	fracture_button.pressed.connect(_on_fracture_pressed)
	root.add_child(fracture_button)

	effects_layer = Control.new()
	effects_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(effects_layer)

func _on_target_pressed(slot_index: int) -> void:
	state.fire_at(slot_index)
	_update_ui()

func _on_weapon_pressed() -> void:
	state.buy_weapon()
	_update_ui()

func _on_unit_pressed(index: int) -> void:
	state.buy_unit(index)
	_update_ui()

func _on_fracture_pressed() -> void:
	if state.fracture():
		_show_event("FRACTURE COMPLETE")
		SaveSystem.save_game(state)
	_update_ui()

func _on_damage_dealt(
	slot_index: int,
	amount: float,
	is_crit: bool,
	source: String
) -> void:
	_show_damage_popup(slot_index, amount, is_crit, source)
	_flash_target(slot_index, is_crit)

func _on_enemy_destroyed(slot_index: int, _kind: String) -> void:
	_spawn_shards(slot_index, 12)

func _on_wave_completed(completed_wave: int) -> void:
	if Balance.is_boss(completed_wave):
		_show_event("BOSS DEFEATED — WAVE %d" % completed_wave)

func _on_boss_failed(failed_wave: int) -> void:
	_show_event("BOSS FAILED — WAVE %d" % failed_wave)

func _show_event(message: String) -> void:
	event_label.text = message
	event_message_time = 2.0

func _show_damage_popup(
	slot_index: int,
	amount: float,
	is_crit: bool,
	source: String
) -> void:
	if slot_index < 0 or slot_index >= target_buttons.size():
		return

	var target := target_buttons[slot_index]
	if not target.visible:
		return

	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if source == "manual":
		label.text = Balance.format_number(amount)
		label.add_theme_font_size_override("font_size", 42 if is_crit else 30)
	elif source == "rail":
		label.text = "RAIL  " + Balance.format_number(amount)
		label.add_theme_font_size_override("font_size", 28)
	elif source == "beam":
		label.text = "BEAM  " + Balance.format_number(amount)
		label.add_theme_font_size_override("font_size", 21)
	else:
		label.text = Balance.format_number(amount)
		label.add_theme_font_size_override("font_size", 18)

	if is_crit:
		label.text = "CRIT  " + label.text
		label.modulate = Color(1.0, 0.82, 0.35, 1.0)
	elif source == "rail":
		label.modulate = Color(1.0, 0.55, 0.40, 1.0)
	elif source == "beam":
		label.modulate = Color(0.55, 0.90, 1.0, 1.0)
	else:
		label.modulate = Color(0.90, 0.95, 1.0, 1.0)

	effects_layer.add_child(label)

	var origin := target.global_position + Vector2(
		target.size.x * 0.5 - 40.0,
		target.size.y * 0.20
	)
	label.global_position = origin

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		label,
		"global_position",
		origin + Vector2(0.0, -65.0),
		0.55
	)
	tween.tween_property(label, "modulate:a", 0.0, 0.55)
	tween.chain().tween_callback(label.queue_free)

func _flash_target(slot_index: int, is_crit: bool) -> void:
	if slot_index < 0 or slot_index >= target_buttons.size():
		return

	var target := target_buttons[slot_index]
	if not target.visible:
		return

	target.modulate = (
		Color(1.0, 0.78, 0.42, 1.0)
		if is_crit
		else Color(0.72, 0.90, 1.0, 1.0)
	)

	var tween := create_tween()
	tween.tween_property(target, "modulate", Color.WHITE, 0.12)

func _spawn_shards(slot_index: int, count: int) -> void:
	if slot_index < 0 or slot_index >= target_buttons.size():
		return

	var target := target_buttons[slot_index]
	var center := target.global_position + target.size * 0.5

	for _i in count:
		var shard := ColorRect.new()
		shard.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shard.color = Color(0.55, 0.88, 1.0, 1.0)
		shard.size = Vector2(7.0, 7.0)
		effects_layer.add_child(shard)
		shard.global_position = center

		var destination := center + Vector2(
			randf_range(-95.0, 95.0),
			randf_range(-80.0, 45.0)
		)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(shard, "global_position", destination, 0.34)
		tween.tween_property(shard, "modulate:a", 0.0, 0.34)
		tween.chain().tween_callback(shard.queue_free)

func _update_ui() -> void:
	if wave_label == null:
		return

	wave_label.text = "WAVE %d" % state.wave
	energy_label.text = "%s ENERGY" % Balance.format_number(state.energy)

	if Balance.is_boss(state.wave):
		boss_label.text = "BOSS   %.1fs" % max(state.boss_time_left, 0.0)
	else:
		boss_label.text = ""

	for slot_index in Balance.MAX_TARGET_SLOTS:
		var enemy := state.get_enemy(slot_index)
		var card := target_cards[slot_index]
		var button := target_buttons[slot_index]
		var hp_bar := target_bars[slot_index]

		if enemy == null or not enemy.is_alive():
			card.visible = false
			continue

		card.visible = true
		button.text = "%s\n%s / %s" % [
			enemy.status_text(),
			Balance.format_number(enemy.hp),
			Balance.format_number(enemy.max_hp)
		]
		hp_bar.value = enemy.health_ratio() * 100.0

	stats_label.text = "Tap %s   Crit %.0f%% ×%.1f   Team DPS %s   Fragments %s" % [
		Balance.format_number(state.tap_damage()),
		state.crit_chance() * 100.0,
		state.crit_multiplier(),
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
	if reward > 0:
		fracture_button.text = "FRACTURE   +%d FRAGMENTS" % reward
	else:
		fracture_button.text = "FRACTURE — REACH WAVE 100"
	fracture_button.disabled = reward <= 0
