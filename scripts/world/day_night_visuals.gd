class_name DayNightVisuals
extends CanvasModulate


func _ready() -> void:
	TimeManager.time_changed.connect(_on_time_changed)
	_on_time_changed(TimeManager.day, TimeManager.hour, TimeManager.minute)


func _on_time_changed(_day: int, hour: int, minute: int) -> void:
	var time := hour + minute / 60.0
	if time < 7.0:
		color = Color("#a7b8d4")
	elif time < 17.0:
		color = Color.WHITE
	elif time < 20.0:
		color = Color("#e5b69a")
	else:
		color = Color("#697b9c")
