extends Control


func _input(event: InputEvent) -> void:
	if event.is_action("camera_forward"):
		$FancyLabel.floating_animation(false)
