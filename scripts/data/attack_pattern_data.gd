class_name AttackPatternData
extends Resource

enum Mode { MELEE_LUNGE, STRAIGHT_PROJECTILE, HOMING_PROJECTILE, SONIC_WAVE }

@export var id: StringName
@export var mode: Mode
@export var attack: AttackData
@export var minimum_distance := 0.0
@export var maximum_distance := 30.0
@export var cooldown := 1.5
@export var weight := 1.0
@export var telegraph_time := 0.25
@export var projectile_speed := 70.0
@export var projectile_lifetime := 3.0
@export var homing_turn_rate := 1.8
@export var wave_width_degrees := 55.0
