extends Node

signal time_changed(day: int, hour: int, minute: int)
signal day_started(day: int)
signal day_ended(day: int)

const MINUTES_PER_DAY := 24 * 60

var day: int = 1
var hour: int = 6
var minute: int = 0
var paused := false
var _accumulator := 0.0


func _process(delta: float) -> void:
	if paused:
		return
	_accumulator += delta
	if _accumulator >= 1.0:
		_accumulator -= 1.0
		advance_minutes(10)


func advance_minutes(amount: int) -> void:
	var total := hour * 60 + minute + amount
	while total >= MINUTES_PER_DAY:
		day_ended.emit(day)
		total -= MINUTES_PER_DAY
		day += 1
		day_started.emit(day)
	hour = total / 60
	minute = total % 60
	time_changed.emit(day, hour, minute)


func advance_day() -> void:
	day_ended.emit(day)
	day += 1
	hour = 6
	minute = 0
	day_started.emit(day)
	time_changed.emit(day, hour, minute)
	GameState.notify("A new day begins")


func to_state() -> Dictionary:
	return {"day": day, "hour": hour, "minute": minute}


func apply_state(data: Dictionary) -> void:
	day = int(data.get("day", 1))
	hour = int(data.get("hour", 6))
	minute = int(data.get("minute", 0))
	time_changed.emit(day, hour, minute)
