class_name CombatDebugOverlay
extends Node2D


func _ready() -> void:
	add_to_group("combat_debug_overlay")
	visible = false
	set_process(false)


func set_enabled(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	for monster: Monster in get_tree().get_nodes_in_group("monsters"):
		draw_arc(to_local(monster.global_position), monster.aggro_range, 0, TAU, 48, Color(0.95, 0.55, 0.25, 0.35), 1.0)
		var max_attack := 0.0
		for pattern: AttackPatternData in monster.data.attack_patterns: max_attack = maxf(max_attack, pattern.maximum_distance)
		draw_arc(to_local(monster.global_position), max_attack, 0, TAU, 36, Color(0.9, 0.25, 0.25, 0.45), 1.0)
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group("hurtboxes"):
		draw_arc(to_local(hurtbox.global_position), 9.0, 0, TAU, 16, Color(0.25, 0.85, 1.0, 0.7) if hurtbox.team == &"player" else Color(1.0, 0.35, 0.35, 0.7), 1.0)
	for projectile: CombatProjectile in get_tree().get_nodes_in_group("combat_projectiles"):
		draw_arc(to_local(projectile.global_position), 7.0, 0, TAU, 12, Color(1.0, 0.95, 0.35, 0.8), 1.0)
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	if player != null:
		var defense := player.get_node("DefenseController") as DefenseController
		var skills := player.get_node("SkillController") as SkillController
		var state_name: String = String(DefenseController.State.keys()[defense.state])
		var text := "DEF %s  PARRY %.2f\nQ %.1f  E %.1f  R %.1f" % [state_name, defense.state_time, float(skills.cooldowns.get(&"dash", 0.0)), float(skills.cooldowns.get(&"power_slash", 0.0)), float(skills.cooldowns.get(&"healing_pulse", 0.0))]
		draw_string(ThemeDB.fallback_font, to_local(player.global_position) + Vector2(-35, -48), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#fff5a5"))
