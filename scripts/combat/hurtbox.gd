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


func receive_hit(damage: int, knockback: Vector2) -> void:
	if invulnerable:
		return
	invulnerable = true
	get_tree().create_timer(invulnerability_time).timeout.connect(func() -> void: invulnerable = false)
	if target.has_method("take_hit"):
		target.take_hit(damage, knockback)
	elif target is PlayerStats:
		(target as PlayerStats).take_damage(damage)
		var player := target.get_parent() as PlayerController
		player.global_position += knockback * 0.035
		player.modulate = Color(1.45, 0.75, 0.75)
		var tween := player.create_tween(); tween.tween_property(player, "modulate", Color.WHITE, 0.14)
