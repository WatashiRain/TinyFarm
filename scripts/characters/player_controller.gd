class_name PlayerController
extends CharacterBody2D

enum Facing {
	LEFT,
	RIGHT,
	DOWN,
	UP,
}

const VISUAL_POSITIONS := {
	Facing.LEFT: Vector2(-20, -36),
	Facing.RIGHT: Vector2(-24, -36),
	Facing.DOWN: Vector2(-15, -36),
	Facing.UP: Vector2(-11, -36),
}

@export var move_speed: float = 65.0

@onready var directional_sprite: AnimatedSprite2D = $Visual/DirectionalSprite

var last_facing: Facing = Facing.DOWN


func _ready() -> void:
	add_to_group("player")
	_apply_facing_visual()


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	velocity = input_vector * move_speed
	if not input_vector.is_zero_approx():
		_update_facing(input_vector)
	move_and_slide()


func _update_facing(direction: Vector2) -> void:
	var horizontal := absf(direction.x)
	var vertical := absf(direction.y)
	if is_equal_approx(horizontal, vertical) and _facing_is_held(direction):
		_apply_facing_visual()
		return
	if horizontal >= vertical:
		last_facing = Facing.LEFT if direction.x < 0.0 else Facing.RIGHT
	else:
		last_facing = Facing.UP if direction.y < 0.0 else Facing.DOWN
	_apply_facing_visual()


func _facing_is_held(direction: Vector2) -> bool:
	match last_facing:
		Facing.LEFT:
			return direction.x < 0.0
		Facing.RIGHT:
			return direction.x > 0.0
		Facing.UP:
			return direction.y < 0.0
		Facing.DOWN:
			return direction.y > 0.0
	return false


func _apply_facing_visual() -> void:
	var animation_name := &"idle_down"
	match last_facing:
		Facing.LEFT:
			animation_name = &"idle_left"
		Facing.RIGHT:
			animation_name = &"idle_right"
		Facing.UP:
			animation_name = &"idle_up"
	if directional_sprite.animation != animation_name:
		directional_sprite.play(animation_name)
	directional_sprite.position = VISUAL_POSITIONS[last_facing]


func get_facing_animation() -> StringName:
	return directional_sprite.animation
