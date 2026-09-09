class_name Hurtbox
extends Area2D

@export var team: StringName
@export var target_path: NodePath = NodePath("..")
var target: Node
var invulnerable := false
@export var invulnerability_time := 0.16


func _ready() -> void:
	add_to_group("hurtboxes")
	target = get_node(target_path)


func receive_attack(attack: AttackData, impact_direction: Vector2, source: Node = null) -> StringName:
	if attack.team == team:
		return &"ignored"
	if invulnerable:
		return &"invulnerable"
	var outcome: StringName = &"hit"
	var damage := attack.damage
	if target is PlayerStats:
		var defense := target.get_parent().get_node_or_null("DefenseController") as DefenseController
		if defense != null:
			var resolution := defense.resolve_attack(attack, source, impact_direction)
			outcome = resolution["outcome"]
			damage = int(resolution["damage"])
		if outcome == &"parry":
			return outcome
	invulnerable = true
	get_tree().create_timer(invulnerability_time).timeout.connect(func() -> void: invulnerable = false)
	if target.has_method("take_hit"):
		target.take_hit(damage, impact_direction * attack.knockback)
	elif target is PlayerStats:
		(target as PlayerStats).take_damage(damage)
		var player := target.get_parent() as PlayerController
		player.global_position += impact_direction * attack.knockback * 0.035
		player.modulate = Color(1.45, 0.75, 0.75)
		var tween := player.create_tween(); tween.tween_property(player, "modulate", Color.WHITE, 0.14)
	return outcome


func receive_hit(damage: int, knockback: Vector2) -> void:
	var attack := AttackData.new()
	attack.damage = damage
	attack.knockback = knockback.length()
	attack.team = &"monster" if team == &"player" else &"player"
	receive_attack(attack, knockback.normalized(), null)
