class_name CameraShake2D
extends Camera2D

@export_range(0.0, 8.0, 0.1) var amplitude: float = 1.5
@export_range(0.01, 1.0, 0.01) var duration: float = 0.16
@export_range(0.5, 5.0, 0.1) var decay: float = 2.4

var _active_amplitude: float = 0.0
var _active_duration: float = 0.0
var _elapsed: float = 0.0


func _ready() -> void:
	set_process(false)


func shake(new_amplitude: float = -1.0, new_duration: float = -1.0) -> void:
	_active_amplitude = amplitude if new_amplitude < 0.0 else new_amplitude
	_active_duration = duration if new_duration < 0.0 else new_duration
	_elapsed = 0.0
	set_process(_active_amplitude > 0.0 and _active_duration > 0.0)


func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _active_duration, 0.0, 1.0)
	var strength := pow(1.0 - progress, decay)
	offset = Vector2(
		sin(_elapsed * 67.0) * _active_amplitude * strength,
		cos(_elapsed * 59.0) * _active_amplitude * strength * 0.65
	)
	if progress >= 1.0:
		offset = Vector2.ZERO
		set_process(false)
