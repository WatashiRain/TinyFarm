class_name BreezeTree
extends Node2D

@export_range(0.1, 2.0, 0.05) var breeze_amount: float = 0.65
@export_range(1.0, 6.0, 0.1) var breeze_duration: float = 3.2

@onready var foliage: Node2D = $Foliage


func _ready() -> void:
	var base_position := foliage.position
	var idle_tween := create_tween().set_loops()
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(foliage, "rotation", deg_to_rad(breeze_amount), breeze_duration)
	idle_tween.parallel().tween_property(foliage, "position", base_position + Vector2(0.6, -0.25), breeze_duration)
	idle_tween.tween_property(foliage, "rotation", deg_to_rad(-breeze_amount * 0.75), breeze_duration * 1.1)
	idle_tween.parallel().tween_property(foliage, "position", base_position + Vector2(-0.45, 0.1), breeze_duration * 1.1)
