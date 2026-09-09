class_name AttackTelegraph
extends Node2D

var active := false
var progress := 0.0
var duration := 0.25
var mode := AttackPatternData.Mode.MELEE_LUNGE
var facing := Vector2.DOWN


func show_attack(pattern: AttackPatternData, direction: Vector2) -> void:
	active = true; progress = 0.0; duration = maxf(0.05, pattern.telegraph_time); mode = pattern.mode; facing = direction
	queue_redraw()


func hide_attack() -> void:
	active = false; queue_redraw()


func _process(delta: float) -> void:
	if active: progress = minf(1.0, progress + delta / duration); queue_redraw()


func _draw() -> void:
	if not active: return
	var color := Color("#ffcf67") if mode in [AttackPatternData.Mode.MELEE_LUNGE, AttackPatternData.Mode.SONIC_WAVE] else Color("#77e2c4")
	var pulse := 3.0 + progress * 7.0
	draw_circle(Vector2(0, -7), pulse, Color(color, 0.16), true)
	draw_arc(Vector2(0, -7), pulse, 0, TAU, 12, Color(color, 0.85), 1.5)
	if mode == AttackPatternData.Mode.SONIC_WAVE:
		draw_arc(facing * 5.0, 13.0, facing.angle() - 0.7, facing.angle() + 0.7, 9, Color(color, 0.75), 2.0)
