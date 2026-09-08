class_name DefeatOverlay
extends CanvasLayer


func show_defeat() -> void:
	$Shade.visible = true
	await get_tree().create_timer(0.75).timeout
	$Shade.visible = false
