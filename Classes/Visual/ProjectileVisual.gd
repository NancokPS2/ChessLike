extends Sprite2D
class_name ProjectileVisual

@export var texImage:Texture2D
@export var texRotation:float
@export var speed:float



func move_simple(direction:Vector2):
	look_forward(direction)
	position += direction * get_process_delta_time()
	
	

func look_forward(forwardDir:Vector2):
	rotation = forwardDir.angle() + texRotation
	
