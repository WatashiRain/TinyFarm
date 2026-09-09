class_name TalentTreeGraph
extends Control

signal talent_hovered(talent: TalentData)

const BRANCH_NAMES: Array[String] = ["VITALITY", "AGILITY", "MANA", "MANA FLOW"]
const BRANCH_COLORS: Array[Color] = [
	Color("#dc574f"),
	Color("#a9cf4b"),
	Color("#4c83df"),
	Color("#63c8d4"),
]
const NODE_SIZE := Vector2(135, 29)

var _buttons: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(580, 240)
	mouse_filter = Control.MOUSE_FILTER_PASS
	TalentManager.points_changed.connect(_on_talents_changed)
	TalentManager.rank_changed.connect(_on_rank_changed)
	TalentManager.talents_rebuilt.connect(refresh)
	rebuild()


func rebuild() -> void:
	for child: Node in get_children():
		child.queue_free()
	_buttons.clear()
	for branch_index: int in BRANCH_NAMES.size():
		var title := Label.new()
		title.position = Vector2(8 + branch_index * 143, 2)
		title.size = Vector2(135, 24)
		title.text = BRANCH_NAMES[branch_index]
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_color_override("font_color", BRANCH_COLORS[branch_index])
		title.add_theme_font_size_override("font_size", 9)
		add_child(title)
	for talent: TalentData in TalentManager.talent_list:
		var button := Button.new()
		button.position = talent.ui_position
		button.size = NODE_SIZE
		button.add_theme_font_size_override("font_size", 7)
		button.tooltip_text = _details_for(talent)
		button.mouse_entered.connect(_on_talent_hovered.bind(talent))
		button.focus_entered.connect(_on_talent_hovered.bind(talent))
		button.pressed.connect(_on_talent_pressed.bind(talent.id))
		add_child(button)
		_buttons[String(talent.id)] = button
	refresh()


func refresh() -> void:
	for talent: TalentData in TalentManager.talent_list:
		var button := _buttons.get(String(talent.id)) as Button
		if button == null:
			continue
		var rank := TalentManager.get_rank(talent.id)
		button.text = "%s  %d/%d" % [talent.display_name, rank, talent.max_rank]
		button.tooltip_text = _details_for(talent)
		button.disabled = rank >= talent.max_rank
		var unlocked := TalentManager.is_unlocked(talent.id)
		var base_color: Color = BRANCH_COLORS[talent.branch]
		var color: Color = base_color.lightened(0.14) if rank > 0 else (base_color.darkened(0.28) if unlocked else Color("#343b42"))
		button.add_theme_stylebox_override("normal", _style(color, base_color if unlocked else Color("#59616a")))
		button.add_theme_stylebox_override("hover", _style(color.lightened(0.16), Color("#fff0b0")))
		button.add_theme_stylebox_override("pressed", _style(color.darkened(0.12), Color.WHITE))
		button.add_theme_stylebox_override("disabled", _style(base_color.lightened(0.08), Color("#f7e0a0")))
	queue_redraw()


func _draw() -> void:
	for talent: TalentData in TalentManager.talent_list:
		for prerequisite: StringName in talent.prerequisite_ids:
			var parent_talent := TalentManager.get_talent(prerequisite)
			if parent_talent == null:
				continue
			var from := parent_talent.ui_position + Vector2(NODE_SIZE.x * 0.5, NODE_SIZE.y)
			var to := talent.ui_position + Vector2(NODE_SIZE.x * 0.5, 0)
			var line_color: Color = BRANCH_COLORS[talent.branch] if TalentManager.get_rank(prerequisite) > 0 else Color("#59616a")
			draw_line(from, to, line_color, 2.0)


func _style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	return style


func _details_for(talent: TalentData) -> String:
	var prerequisites: Array[String] = []
	for prerequisite: StringName in talent.prerequisite_ids:
		var required := TalentManager.get_talent(prerequisite)
		prerequisites.append(required.display_name if required != null else String(prerequisite))
	var requirement := "None" if prerequisites.is_empty() else ", ".join(prerequisites)
	return "%s\n%s\nRank %d/%d | Cost %d TP\nPrerequisite: %s | Required level: %d" % [talent.display_name, talent.description, TalentManager.get_rank(talent.id), talent.max_rank, talent.cost_per_rank, requirement, talent.required_level]


func _on_talent_hovered(talent: TalentData) -> void:
	talent_hovered.emit(talent)


func _on_talent_pressed(talent_id: StringName) -> void:
	TalentManager.purchase_talent(talent_id)
	var talent := TalentManager.get_talent(talent_id)
	if talent != null:
		talent_hovered.emit(talent)


func _on_talents_changed(_available: int, _earned: int, _spent: int) -> void:
	refresh()


func _on_rank_changed(_talent_id: StringName, _rank: int) -> void:
	refresh()
