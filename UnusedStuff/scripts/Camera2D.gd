extends Camera2D
var zoomAmount = Vector2(1,0.5)

func _physics_process(delta):
	if Input.is_action_pressed("camera_left"):
		$Field.position.x += 5
	if Input.is_action_pressed("camera_right"):
		$Field.position.x -= 5
	if Input.is_action_pressed("camera_down"):
		$Field.position.y -= 5
	if Input.is_action_pressed("camera_up"):
		$Field.position.y += 5
	if Input.is_action_pressed("camera_out"):
		zoom -= zoomAmount
	if Input.is_action_pressed("camera_out"):
		zoom += zoomAmount
