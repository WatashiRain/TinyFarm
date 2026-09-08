class_name AudioHooks
extends Node


func _ready() -> void:
	add_to_group("audio_hooks")


func play(hook: StringName) -> void:
	var player := get_node_or_null(String(hook)) as AudioStreamPlayer
	if player != null and player.stream != null: player.play()
