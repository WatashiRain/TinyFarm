extends Node2D

@onready var demo_plant: InteractablePlant = $World/DemoPlant
@onready var camera: CameraShake2D = $World/Player/Camera2D
@onready var pixel_grid: PixelGrid = $World/PixelGrid


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE:
			demo_plant.trigger_interaction()
			camera.shake()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_G or event.physical_keycode == KEY_G:
			pixel_grid.visible = not pixel_grid.visible
			get_viewport().set_input_as_handled()
