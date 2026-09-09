class_name SkillController
extends Node2D

@onready var player: PlayerController = get_parent()
@onready var stats: PlayerStats = player.get_node("Stats")
@onready var combat: CombatController = player.get_node("CombatController")
var skills: Dictionary = {}
var cooldowns: Dictionary = {}
var pulse_time := 0.0

const SKILL_PATHS := ["res://resources/skills/dash.tres", "res://resources/skills/power_slash.tres", "res://resources/skills/healing_pulse.tres"]


func _ready() -> void:
	for path: String in SKILL_PATHS:
		var skill: SkillData = load(path); skills[skill.id] = skill


func _process(delta: float) -> void:
	for id: StringName in cooldowns.keys(): cooldowns[id] = maxf(0.0, float(cooldowns[id]) - delta)
	if pulse_time > 0.0: pulse_time -= delta; queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("skill_dash"):
		use_skill(&"dash")
	elif event.is_action_pressed("skill_power_slash"):
		use_skill(&"power_slash")
	elif event.is_action_pressed("skill_healing_pulse"):
		use_skill(&"healing_pulse")


func use_skill(id: StringName) -> bool:
	if not bool(GameState.unlocked_skills.get(String(id), false)):
		GameState.notify("Skill locked")
		return false
	var skill: SkillData = skills[id]
	if float(cooldowns.get(id, 0.0)) > 0.0:
		return false
	if id == &"healing_pulse" and stats.health >= stats.max_health:
		GameState.notify("Health already full")
		return false
	var mana_cost := stats.adjusted_skill_mana_cost(skill.mana_cost, id)
	if not stats.consume_mana(mana_cost):
		GameState.notify("Not enough mana")
		return false
	cooldowns[id] = stats.adjusted_skill_cooldown(skill.cooldown, id)
	if id == &"dash":
		var direction: Vector2 = player.get_node("ToolController").facing_vector()
		var start := player.global_position
		player.global_position += direction * 42.0
		var trail := Line2D.new(); trail.width = 3.0; trail.default_color = skill.placeholder_color; trail.add_point(start); trail.add_point(player.global_position); get_tree().current_scene.add_child(trail)
		var tween := trail.create_tween(); tween.tween_property(trail, "modulate:a", 0.0, 0.25); tween.tween_callback(trail.queue_free)
	elif id == &"power_slash":
		combat.cooldown = 0.0
		combat.attack(2.0 * stats.skill_power_multiplier(id), 36.0, skill.placeholder_color)
	else:
		stats.heal(30)
		pulse_time = 0.45
		queue_redraw()
	GameState.notify(skill.display_name)
	return true


func _draw() -> void:
	if pulse_time > 0.0:
		draw_arc(Vector2.ZERO, 12.0 + (0.45 - pulse_time) * 28.0, 0, TAU, 20, Color(0.55, 1, 0.68, pulse_time / 0.45), 2.0)
