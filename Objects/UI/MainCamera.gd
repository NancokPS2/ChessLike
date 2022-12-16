extends Camera
func _ready() -> void:
	Ref.mainCamera = self

func _process(delta: float) -> void:
	if Input.is_action_pressed("shift_mod"):
		if Input.is_action_pressed("ui_up"):
			rotation += Vector3(1,0,0) * delta
			
		elif Input.is_action_pressed("ui_right"):
			translation += Vector3(0,1,0) * delta
			
		elif Input.is_action_pressed("ui_down"):
			rotation += Vector3(-1,0,0) * delta
			
		elif Input.is_action_pressed("ui_left"):
			translation += Vector3(0,-1,0) * delta
	else:
		if Input.is_action_pressed("ui_up"):
			translation += Vector3.FORWARD * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("ui_right"):
			translation += Vector3.RIGHT * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("ui_down"):
			translation += Vector3.BACK * delta * CVars.settingCameraSpeed
			
		elif Input.is_action_pressed("ui_left"):
			translation += Vector3.LEFT * delta * CVars.settingCameraSpeed
