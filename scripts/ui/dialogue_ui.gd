class_name DialogueUI
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var speaker_label: Label = $Panel/Margin/Content/Speaker
@onready var text_label: Label = $Panel/Margin/Content/Text
var lines: Array[String] = []
var index := 0
var finished_callback: Callable


func _ready() -> void:
	add_to_group("dialogue_ui")
	$Panel/Margin/Content/Buttons/Next.pressed.connect(next)
	$Panel/Margin/Content/Buttons/Close.pressed.connect(close)


func open(speaker: String, dialogue: Array[String], callback := Callable()) -> void:
	speaker_label.text = speaker
	lines = dialogue
	index = 0
	finished_callback = callback
	panel.visible = true
	_show_line()


func next() -> void:
	index += 1
	if index >= lines.size(): close()
	else: _show_line()


func close() -> void:
	panel.visible = false
	if finished_callback.is_valid(): finished_callback.call()
	finished_callback = Callable()


func _show_line() -> void:
	text_label.text = lines[index] if index < lines.size() else ""
