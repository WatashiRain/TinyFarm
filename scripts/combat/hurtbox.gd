class_name Hurtbox
extends Area2D

@export var team: StringName
@export var target_path: NodePath = NodePath("..")
var target: Node


func _ready() -> void:
	add_to_group("hurtboxes")
	target = get_node(target_path)


func receive_hit(damage: int, knockback: Vector2) -> void:
	if target.has_method("take_hit"):
		target.take_hit(damage, knockback)
	elif target is PlayerStats:
		(target as PlayerStats).take_damage(damage)
