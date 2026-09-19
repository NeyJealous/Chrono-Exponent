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
var purchase_mode_buttons: Array[Button] = []
var fracture_button: Button
var tree_button: Button

var fracture_tree_overlay: ColorRect
var fracture_tree_fragments_label: Label
var fracture_node_buttons: Dictionary = {}

var fracture_confirm_overlay: ColorRect
var fracture_confirm_summary_label: Label
var fracture_result_overlay: ColorRect
var fracture_result_summary_label: Label

var purchase_amount := 1

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
	state.fracture_completed.connect(_on_fracture_completed)
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

	var purchase_modes := HBoxContainer.new()
	purchase_modes.alignment = BoxContainer.ALIGNMENT_CENTER
	purchase_modes.add_theme_constant_override("separation", 6)
	root.add_child(purchase_modes)

	var mode_values := [1, 10, 25, 0]
	var mode_names := ["×1", "×10", "×25", "MAX"]
	for i in mode_values.size():
		var mode_button := Button.new()
		mode_button.text = mode_names[i]
		mode_button.custom_minimum_size = Vector2(90, 44)
		mode_button.pressed.connect(_on_purchase_mode_pressed.bind(mode_values[i]))
		purchase_modes.add_child(mode_button)
		purchase_mode_buttons.append(mode_button)

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

	var bottom_actions := HBoxContainer.new()
	bottom_actions.add_theme_constant_override("separation", 8)
	root.add_child(bottom_actions)

	fracture_button = Button.new()
	fracture_button.text = "FRACTURE"
	fracture_button.custom_minimum_size.y = 62
	fracture_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fracture_button.pressed.connect(_on_fracture_pressed)
	bottom_actions.add_child(fracture_button)

	tree_button = Button.new()
	tree_button.text = "FRACTURE TREE"
	tree_button.custom_minimum_size = Vector2(300, 62)
	tree_button.pressed.connect(_on_tree_pressed)
	bottom_actions.add_child(tree_button)

	effects_layer = Control.new()
	effects_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(effects_layer)

	_build_fracture_tree_overlay()
	_build_fracture_dialogs()

func _build_fracture_tree_overlay() -> void:
	fracture_tree_overlay = ColorRect.new()
	fracture_tree_overlay.color = Color(0.018, 0.022, 0.040, 0.985)
	fracture_tree_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	fracture_tree_overlay.visible = false
	add_child(fracture_tree_overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	fracture_tree_overlay.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)

	var title := Label.new()
	title.text = "FRACTURE TREE"
	title.add_theme_font_size_override("font_size", 34)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	fracture_tree_fragments_label = Label.new()
	fracture_tree_fragments_label.add_theme_font_size_override(
		"font_size",
		28
	)
	fracture_tree_fragments_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	fracture_tree_fragments_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	header.add_child(fracture_tree_fragments_label)

	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.custom_minimum_size = Vector2(140, 54)
	close_button.pressed.connect(_on_tree_close_pressed)
	header.add_child(close_button)

	var hint := Label.new()
	hint.text = (
		"Fragments are spent permanently. " +
		"Each branch changes a different part of the run."
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 18)
	root.add_child(hint)

	var branches := HBoxContainer.new()
	branches.size_flags_vertical = Control.SIZE_EXPAND_FILL
	branches.add_theme_constant_override("separation", 10)
	root.add_child(branches)

	for branch in FractureTree.BRANCHES:
		var branch_box := VBoxContainer.new()
		branch_box.custom_minimum_size.x = 330
		branch_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		branch_box.add_theme_constant_override("separation", 8)
		branches.add_child(branch_box)

		var branch_title := Label.new()
		branch_title.text = String(branch["name"])
		branch_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		branch_title.add_theme_font_size_override("font_size", 22)
		branch_box.add_child(branch_title)

		for node in FractureTree.nodes_for_branch(
			String(branch["id"])
		):
			var node_id := String(node["id"])
			var node_button := Button.new()
			node_button.custom_minimum_size.y = 150
			node_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			node_button.add_theme_font_size_override("font_size", 16)
			node_button.pressed.connect(
				_on_fracture_node_pressed.bind(node_id)
			)
			branch_box.add_child(node_button)
			fracture_node_buttons[node_id] = node_button

func _build_fracture_dialogs() -> void:
	fracture_confirm_overlay = ColorRect.new()
	fracture_confirm_overlay.color = Color(0.012, 0.016, 0.032, 0.975)
	fracture_confirm_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	fracture_confirm_overlay.visible = false
	add_child(fracture_confirm_overlay)

	var confirm_center := CenterContainer.new()
	confirm_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fracture_confirm_overlay.add_child(confirm_center)

	var confirm_box := VBoxContainer.new()
	confirm_box.custom_minimum_size = Vector2(760, 0)
	confirm_box.add_theme_constant_override("separation", 18)
	confirm_center.add_child(confirm_box)

	var confirm_title := Label.new()
	confirm_title.text = "FRACTURE TIMELINE?"
	confirm_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_title.add_theme_font_size_override("font_size", 38)
	confirm_box.add_child(confirm_title)

	var warning := Label.new()
	warning.text = (
		"This ends the current run and resets Energy, Weapon and Team levels."
	)
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size", 18)
	confirm_box.add_child(warning)

	fracture_confirm_summary_label = Label.new()
	fracture_confirm_summary_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	fracture_confirm_summary_label.add_theme_font_size_override(
		"font_size",
		24
	)
	confirm_box.add_child(fracture_confirm_summary_label)

	var confirm_actions := HBoxContainer.new()
	confirm_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_actions.add_theme_constant_override("separation", 18)
	confirm_box.add_child(confirm_actions)

	var cancel_button := Button.new()
	cancel_button.text = "CANCEL"
	cancel_button.custom_minimum_size = Vector2(220, 62)
	cancel_button.pressed.connect(_on_fracture_cancel_pressed)
	confirm_actions.add_child(cancel_button)

	var confirm_button := Button.new()
	confirm_button.text = "CONFIRM FRACTURE"
	confirm_button.custom_minimum_size = Vector2(300, 62)
	confirm_button.pressed.connect(_on_fracture_confirm_pressed)
	confirm_actions.add_child(confirm_button)

	fracture_result_overlay = ColorRect.new()
	fracture_result_overlay.color = Color(0.012, 0.016, 0.032, 0.985)
	fracture_result_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	fracture_result_overlay.visible = false
	add_child(fracture_result_overlay)

	var result_center := CenterContainer.new()
	result_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fracture_result_overlay.add_child(result_center)

	var result_box := VBoxContainer.new()
	result_box.custom_minimum_size = Vector2(760, 0)
	result_box.add_theme_constant_override("separation", 18)
	result_center.add_child(result_box)

	var result_title := Label.new()
	result_title.text = "TIMELINE FRACTURED"
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size", 40)
	result_box.add_child(result_title)

	fracture_result_summary_label = Label.new()
	fracture_result_summary_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	fracture_result_summary_label.add_theme_font_size_override(
		"font_size",
		24
	)
	result_box.add_child(fracture_result_summary_label)

	var result_actions := HBoxContainer.new()
	result_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	result_actions.add_theme_constant_override("separation", 18)
	result_box.add_child(result_actions)

	var continue_button := Button.new()
	continue_button.text = "CONTINUE"
	continue_button.custom_minimum_size = Vector2(220, 62)
	continue_button.pressed.connect(_on_fracture_result_continue_pressed)
	result_actions.add_child(continue_button)

	var tree_after_button := Button.new()
	tree_after_button.text = "OPEN FRACTURE TREE"
	tree_after_button.custom_minimum_size = Vector2(320, 62)
	tree_after_button.pressed.connect(_on_fracture_result_tree_pressed)
	result_actions.add_child(tree_after_button)


func _format_duration(seconds_value: float) -> String:
	var total_seconds := max(0, int(round(seconds_value)))
	var hours := int(total_seconds / 3600)
	var minutes := int((total_seconds % 3600) / 60)
	var seconds := total_seconds % 60

	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	return "%02d:%02d" % [minutes, seconds]


func _run_summary_text(summary: Dictionary, completed: bool) -> String:
	var reward := int(summary.get("fragment_reward", 0))
	var reward_line := (
		"+%d FRAGMENTS EARNED" % reward
		if completed
		else "+%d FRAGMENTS ON FRACTURE" % reward
	)

	return (
		"RUN TIME   %s\n" +
		"WAVE   %d → %d\n" +
		"DAMAGE   %s\n" +
		"ENERGY EARNED   %s\n" +
		"KILLS   %d     BOSSES   %d     CRITS   %d\n\n" +
		reward_line
	) % [
		_format_duration(float(summary.get("run_time", 0.0))),
		int(summary.get("start_wave", 1)),
		int(summary.get("highest_wave", 1)),
		Balance.format_number(float(summary.get("damage", 0.0))),
		Balance.format_number(float(summary.get("energy_earned", 0.0))),
		int(summary.get("kills", 0)),
		int(summary.get("bosses", 0)),
		int(summary.get("crits", 0))
	]


func _show_fracture_confirmation() -> void:
	if not state.can_fracture():
		return

	_set_tree_visible(false)
	fracture_confirm_summary_label.text = _run_summary_text(
		state.current_run_summary(),
		false
	)
	fracture_confirm_overlay.visible = true


func _on_fracture_cancel_pressed() -> void:
	fracture_confirm_overlay.visible = false


func _on_fracture_confirm_pressed() -> void:
	if not state.fracture():
		fracture_confirm_overlay.visible = false
		return

	SaveSystem.save_game(state)
	_update_ui()


func _on_fracture_completed(summary: Dictionary) -> void:
	fracture_confirm_overlay.visible = false
	fracture_result_summary_label.text = _run_summary_text(summary, true)
	fracture_result_overlay.visible = true
	_show_event("FRACTURE COMPLETE")


func _on_fracture_result_continue_pressed() -> void:
	fracture_result_overlay.visible = false


func _on_fracture_result_tree_pressed() -> void:
	fracture_result_overlay.visible = false
	_set_tree_visible(true)


func _update_fracture_tree_ui() -> void:
	if fracture_tree_overlay == null:
		return

	fracture_tree_fragments_label.text = "%s FRAGMENTS" % (
		Balance.format_number(state.fragments)
	)

	for node in FractureTree.NODES:
		var node_id := String(node["id"])
		if not fracture_node_buttons.has(node_id):
			continue

		var button: Button = fracture_node_buttons[node_id]
		var current_level := state.fracture_upgrade_level(node_id)
		var max_level := int(node["max_level"])
		var cost := FractureTree.cost(
			state.fracture_upgrades,
			node_id
		)

		if current_level >= max_level:
			button.text = "%s\nLv.%d/%d  MAX\n%s" % [
				String(node["name"]),
				current_level,
				max_level,
				String(node["description"])
			]
			button.disabled = true
		else:
			button.text = "%s\nLv.%d/%d  COST %d F\n%s" % [
				String(node["name"]),
				current_level,
				max_level,
				cost,
				String(node["description"])
			]
			button.disabled = not state.can_buy_fracture_upgrade(
				node_id
			)

func _on_target_pressed(slot_index: int) -> void:
	state.fire_at(slot_index)
	_update_ui()

func _on_purchase_mode_pressed(amount: int) -> void:
	purchase_amount = amount
	_update_ui()

func _on_weapon_pressed() -> void:
	state.buy_weapon_amount(purchase_amount)
	_update_ui()

func _on_unit_pressed(index: int) -> void:
	state.buy_unit_amount(index, purchase_amount)
	_update_ui()

func _on_fracture_pressed() -> void:
	_show_fracture_confirmation()

func _on_tree_pressed() -> void:
	_set_tree_visible(not fracture_tree_overlay.visible)

func _on_tree_close_pressed() -> void:
	_set_tree_visible(false)

func _on_fracture_node_pressed(node_id: String) -> void:
	if state.buy_fracture_upgrade(node_id):
		_show_event("UPGRADE: " + String(
			FractureTree.get_node(node_id).get("name", node_id)
		))
		SaveSystem.save_game(state)
	_update_ui()
	_update_fracture_tree_ui()

func _set_tree_visible(value: bool) -> void:
	fracture_tree_overlay.visible = value
	if value:
		_update_fracture_tree_ui()

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

	for i in purchase_mode_buttons.size():
		var values := [1, 10, 25, 0]
		purchase_mode_buttons[i].disabled = purchase_amount == values[i]

	var weapon_levels := purchase_amount
	if purchase_amount <= 0:
		weapon_levels = Balance.weapon_max_affordable(
			state.weapon_level,
			state.energy
		)
	var weapon_cost := Balance.weapon_bulk_cost(
		state.weapon_level,
		weapon_levels
	)
	weapon_button.text = "GUN Lv.%d  +%d\n%s" % [
		state.weapon_level,
		weapon_levels,
		Balance.format_number(weapon_cost)
	]
	weapon_button.disabled = weapon_levels <= 0 or state.energy < weapon_cost

	for i in unit_buttons.size():
		var data: Dictionary = Balance.UNIT_DATA[i]
		var unlocked := Balance.unit_is_unlocked(i, state.highest_wave)

		if not unlocked:
			unit_buttons[i].text = "%s\nUNLOCK WAVE %d" % [
				String(data["name"]),
				Balance.unit_unlock_wave(i)
			]
			unit_buttons[i].disabled = true
			continue

		var unit_levels := purchase_amount
		if purchase_amount <= 0:
			unit_levels = Balance.unit_max_affordable(
				i,
				state.unit_levels[i],
				state.energy
			)

		var cost := Balance.unit_bulk_cost(
			i,
			state.unit_levels[i],
			unit_levels
		)
		unit_buttons[i].text = "%s Lv.%d  +%d\n%s" % [
			String(data["name"]),
			state.unit_levels[i],
			unit_levels,
			Balance.format_number(cost)
		]
		unit_buttons[i].disabled = unit_levels <= 0 or state.energy < cost

	var reward := state.fracture_reward()
	if reward > 0:
		fracture_button.text = "FRACTURE   +%d FRAGMENTS" % reward
	else:
		fracture_button.text = "FRACTURE — REACH WAVE 100"
	fracture_button.disabled = reward <= 0

	tree_button.text = "FRACTURE TREE   •   %s F" % (
		Balance.format_number(state.fragments)
	)

	if fracture_tree_overlay.visible:
		_update_fracture_tree_ui()
