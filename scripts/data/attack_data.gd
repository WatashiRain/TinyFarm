class_name AttackData
extends Resource

enum Type { MELEE, PROJECTILE, SONIC, MAGIC }

@export var id: StringName
@export var type: Type = Type.MELEE
@export var damage: int = 8
@export var knockback: float = 35.0
@export var parryable := true
@export var blockable := true
@export var reflectable := false
@export var team: StringName = &"monster"


func runtime_copy(new_team: StringName = team) -> AttackData:
	var copy := duplicate(true) as AttackData
	copy.team = new_team
	return copy
