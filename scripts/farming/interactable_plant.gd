class_name InteractablePlant
extends Node2D

@export_range(0.5, 2.0, 0.05) var response_scale: float = 1.0

@onready var burst_effect: InteractionBurst = $Burst

var _busy: bool = false
var _rest_position: Vector2


func _ready() -> void:
	_rest_position = position


func trigger_interaction() -> void:
	if _busy:
		return
	_busy = true
	burst_effect.burst()

	var response := create_tween()
	response.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	response.tween_property(self, "scale", Vector2(1.0 + 0.15 * response_scale, 1.0 - 0.22 * response_scale), 0.065)
	response.parallel().tween_property(self, "position", _rest_position + Vector2(0.0, 1.5), 0.065)
	response.tween_property(self, "scale", Vector2(1.0 - 0.10 * response_scale, 1.0 + 0.14 * response_scale), 0.085)
	response.parallel().tween_property(self, "position", _rest_position + Vector2(0.0, -5.0), 0.085)
	response.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	response.tween_property(self, "scale", Vector2.ONE, 0.16)
	response.parallel().tween_property(self, "position", _rest_position, 0.16)
	await response.finished
	_busy = false
