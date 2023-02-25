extends Node3D

onready var cameraTransform:Transform = $Camera.get_global_transform()

func _ready() -> void:
	Ref.mainCamera = self
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("mouse_camera_mod"):
		#rotation.x += -event.relative.y * 0.01
		rotation.y += -event.relative.x * 0.01

func _process(delta: float) -> void:
	if Input.is_action_pressed("shift_mod"):
		
#		if Input.is_action_pressed("camera_backward"):
#			rotation += Vector3(-1,0,0) * delta

#		elif Input.is_action_pressed("camera_forward"):
#			rotation += Vector3(1,0,0) * delta
		pass
	else:
		if Input.is_action_pressed("camera_forward"):
			translation += + -get_global_transform().basis.z * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("camera_right"):
			translation += get_global_transform().basis.x * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("camera_backward"):
			translation += get_global_transform().basis.z * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("camera_left"):
			translation += -get_global_transform().basis.x * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("rotate_left"):
			rotation += Vector3(0,-1,0) * delta * CVars.settingCameraSpeed

		elif Input.is_action_pressed("rotate_right"):
			rotation += Vector3(0,1,0) * delta * CVars.settingCameraSpeed
