class_name GameplayHUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $SafeArea/Top/Content/Stats/HP
@onready var energy_bar: ProgressBar = $SafeArea/Top/Content/Stats/Energy
@onready var mana_bar: ProgressBar = $SafeArea/Top/Content/Stats/Mana
@onready var xp_bar: ProgressBar = $SafeArea/Top/Content/Stats/XP
@onready var level_label: Label = $SafeArea/Top/Content/Meta/Level
@onready var time_label: Label = $SafeArea/Top/Content/Meta/Time
@onready var region_label: Label = $SafeArea/Top/Content/Meta/Region
@onready var notice_label: Label = $SafeArea/Notice

var _notice_tween: Tween


func _ready() -> void:
	GameState.player_registered.connect(_bind_stats)
	GameState.region_changed.connect(_on_region_changed)
	GameState.notification_requested.connect(show_notice)
	TimeManager.time_changed.connect(_on_time_changed)
	if GameState.player_stats != null:
		_bind_stats(GameState.player_stats)
	_on_region_changed(GameState.current_region)
	_on_time_changed(TimeManager.day, TimeManager.hour, TimeManager.minute)


func _bind_stats(stats: PlayerStats) -> void:
	stats.health_changed.connect(func(value: int, maximum: int) -> void: _set_bar(hp_bar, value, maximum))
	stats.energy_changed.connect(func(value: int, maximum: int) -> void: _set_bar(energy_bar, value, maximum))
	stats.mana_changed.connect(func(value: int, maximum: int) -> void: _set_bar(mana_bar, value, maximum))
	stats.experience_changed.connect(func(value: int, required: int) -> void: _set_bar(xp_bar, value, required))
	stats.level_changed.connect(func(value: int) -> void: level_label.text = "LV %d" % value)
	_set_bar(hp_bar, stats.health, stats.max_health)
	_set_bar(energy_bar, stats.energy, stats.max_energy)
	_set_bar(mana_bar, stats.mana, stats.max_mana)
	_set_bar(xp_bar, stats.experience, stats.experience_to_next_level())
	level_label.text = "LV %d" % stats.level


func _set_bar(bar: ProgressBar, value: int, maximum: int) -> void:
	bar.max_value = maximum
	bar.value = value
	bar.tooltip_text = "%d / %d" % [value, maximum]


func _on_time_changed(day: int, hour: int, minute: int) -> void:
	time_label.text = "DAY %d  %02d:%02d" % [day, hour, minute]


func _on_region_changed(region_id: StringName) -> void:
	region_label.text = String(region_id).to_upper()


func show_notice(message: String) -> void:
	notice_label.text = message
	notice_label.modulate.a = 1.0
	if _notice_tween != null:
		_notice_tween.kill()
	_notice_tween = create_tween()
	_notice_tween.tween_interval(1.4)
	_notice_tween.tween_property(notice_label, "modulate:a", 0.0, 0.5)
