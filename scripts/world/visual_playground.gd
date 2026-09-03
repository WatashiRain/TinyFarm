extends Node2D

@onready var demo_plant: InteractablePlant = $World/DemoPlant
@onready var camera: CameraShake2D = $Camera


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			demo_plant.trigger_interaction()
			camera.shake()
			get_viewport().set_input_as_handled()
