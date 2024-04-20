extends CPUParticles2D

@export var emission_spots_total: int = 5
@export var invert_normals: bool

func _ready() -> void:
	update()

func update():
	if not get_parent() is Control:
		push_error("Only works on Control nodes")
		return
	
	emission_shape = EMISSION_SHAPE_DIRECTED_POINTS
	emission_points.clear()
	emission_normals.clear()
	
	var emi_points: Array[Vector2]
	var emi_normals: Array[Vector2]
	
	var rect: Rect2 = get_parent().get_rect()
	var index: int = 0
	const SPREAD_DIRS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	var side_origin: Vector2 = Vector2(0, rect.size.y)
		
	var length: float = rect.size.x
		
	for spot: int in emission_spots_total + 1:
		emi_points.append(
			side_origin + (((Vector2.RIGHT * length) / emission_spots_total) * spot)
		)
		
		if invert_normals:
			emi_normals.append(Vector2.UP)
		else:
			emi_normals.append(Vector2.DOWN)
			
	index += 1
		
	emission_points = emi_points
	emission_normals = emi_normals

