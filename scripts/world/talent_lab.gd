extends Node2D

@onready var player: PlayerController = $Player
@onready var stats: PlayerStats = $Player/Stats
@onready var status_label: Label = $LabUI/Status


func _ready() -> void:
	TimeManager.paused = true
	SaveManager.active_save_path = "user://tinyfarm_talent_lab_save.json"
	$LabUI/Panel/Buttons/GainXP.pressed.connect(gain_level)
	$LabUI/Panel/Buttons/GivePoints.pressed.connect(func() -> void: TalentManager.grant_points(5))
	$LabUI/Panel/Buttons/DrainMana.pressed.connect(drain_mana)
	$LabUI/Panel/Buttons/Save.pressed.connect(func() -> void: SaveManager.save_game())
	$LabUI/Panel/Buttons/Load.pressed.connect(func() -> void: SaveManager.load_game())
	$LabUI/Panel/Buttons/Reset.pressed.connect(func() -> void: TalentManager.reset_talents())
	stats.stats_changed.connect(_update_status)
	TalentManager.points_changed.connect(_on_talent_points_changed)
	TalentManager.rank_changed.connect(_on_talent_rank_changed)
	_update_status()
	queue_redraw()


func gain_level() -> void:
	stats.add_experience(stats.experience_to_next_level() - stats.experience)


func drain_mana() -> void:
	stats.mana = 0
	stats.mana_changed.emit(stats.mana, stats.max_mana)
	stats.stats_changed.emit()
	GameState.notify("Mana drained — observe Mana Flow ticks")


func _on_talent_points_changed(_available: int, _earned: int, _spent: int) -> void:
	_update_status()


func _on_talent_rank_changed(_talent_id: StringName, _rank: int) -> void:
	_update_status()


func _update_status() -> void:
	if status_label == null or stats == null:
		return
	status_label.text = "LV %d   TP %d   HP %d/%d   DEF %d   SPEED %.0f%%   MANA %d/%d   REGEN %d / 2s" % [stats.level, TalentManager.available_points(), stats.health, stats.max_health, stats.defense, stats.movement_speed_multiplier * 100.0, stats.mana, stats.max_mana, TalentManager.mana_regen_amount]


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#172b31"), true)
	draw_rect(Rect2(28, 78, 584, 190), Color("#294b45"), true)
	for x: int in range(32, 613, 16):
		draw_line(Vector2(x, 78), Vector2(x, 268), Color(1, 1, 1, 0.035), 1.0)
	for y: int in range(78, 269, 16):
		draw_line(Vector2(28, y), Vector2(612, y), Color(1, 1, 1, 0.035), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(38, 100), "MOVE CHUN HERE TO FEEL SWIFT STEP", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#b9dc7a"))
