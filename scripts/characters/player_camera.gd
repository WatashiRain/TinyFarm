class_name PlayerCamera
extends CameraShake2D

@export var follow_offset: Vector2 = Vector2(0, -16)
@export var snap_to_pixel: bool = true

var _follow_target: Node2D


func _ready() -> void:
	_follow_target = get_parent() as Node2D
	top_level = true
	super._ready()
	set_physics_process(true)
	_update_follow_position()


func _physics_process(_delta: float) -> void:
	_update_follow_position()


func _update_follow_position() -> void:
	if _follow_target == null:
		return
	var target_position := _follow_target.global_position + follow_offset
	global_position = target_position.round() if snap_to_pixel else target_position
