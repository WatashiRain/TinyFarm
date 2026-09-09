extends Node2D

const MONSTER_SCENE := preload("res://scenes/monsters/monster.tscn")
const ENEMIES := [
	["res://resources/monsters/slime.tres", Vector2(245, 205)],
	["res://resources/monsters/bat.tres", Vector2(397, 165)],
	["res://resources/monsters/spirit.tres", Vector2(450, 245)],
]

@onready var player: PlayerController = $Player
@onready var enemies: Node2D = $Enemies


func _ready() -> void:
	TimeManager.paused = true
	GameState.unlocked_skills.merge({"dash": true, "power_slash": true, "healing_pulse": true}, true)
	$LabUI/Panel/Buttons/Heal.pressed.connect(heal_player)
	$LabUI/Panel/Buttons/LowEnergy.pressed.connect(set_low_energy)
	$LabUI/Panel/Buttons/Reset.pressed.connect(reset_enemies)
	$LabUI/Panel/Buttons/Guides.pressed.connect(toggle_guides)
	queue_redraw()


func heal_player() -> void:
	player.get_node("Stats").restore_all()
	GameState.notify("Combat lab restored")


func set_low_energy() -> void:
	var stats: PlayerStats = player.get_node("Stats")
	stats.energy = 3; stats.energy_changed.emit(stats.energy, stats.max_energy); stats.stats_changed.emit()
	GameState.notify("Energy set to 3 — hold defend to test break")


func reset_enemies() -> void:
	for node: Node in get_tree().get_nodes_in_group("combat_projectiles"): node.queue_free()
	for node: Node in get_tree().get_nodes_in_group("sonic_waves"): node.queue_free()
	for child: Node in enemies.get_children(): child.queue_free()
	for definition: Array in ENEMIES:
		var monster: Monster = MONSTER_SCENE.instantiate(); monster.data = load(definition[0]); monster.position = definition[1]
		if monster.data.id == &"bat": monster.aggro_range = 130.0
		elif monster.data.id == &"spirit": monster.aggro_range = 150.0
		enemies.add_child(monster)
	heal_player()


func toggle_guides() -> void:
	var overlay: CombatDebugOverlay = $CombatDebugOverlay
	overlay.set_enabled(not overlay.visible)


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("#203b35"), true)
	draw_rect(Rect2(36, 60, 568, 240), Color("#315947"), true)
	for x: int in range(48, 604, 16): draw_line(Vector2(x, 60), Vector2(x, 300), Color(1, 1, 1, 0.035), 1.0)
	for y: int in range(60, 301, 16): draw_line(Vector2(36, y), Vector2(604, y), Color(1, 1, 1, 0.035), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(55, 82), "SLIME — LUNGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#a9e29b"))
	draw_string(ThemeDB.fallback_font, Vector2(345, 82), "BAT — DIVE / SONIC", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#c8b8e8"))
	draw_string(ThemeDB.fallback_font, Vector2(435, 285), "SPIRIT — SHOT / HOMING", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#9ce8cf"))
