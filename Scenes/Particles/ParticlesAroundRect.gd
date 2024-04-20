extends CPUParticles2D

@export var emission_spots_per_side: int = 5
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
	var center: Vector2 = rect.size / 2
	var index: int = 0
	const SPREAD_DIRS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	for side_origin: Vector2 in [
		Vector2(0, 0),
		 Vector2(rect.size.x, 0),
		 Vector2(rect.size.x, rect.size.y),
		 Vector2(0, rect.size.y)
		]:
		
		var spread_dir: Vector2 = SPREAD_DIRS[index]
		var length: float = rect.size[spread_dir.max_axis_index()]
		
		for spot: int in emission_spots_per_side + 1:
			emi_points.append(
				side_origin + (((spread_dir * length) / emission_spots_per_side) * spot)
			)
			
			if invert_normals:
				emi_normals.append(spread_dir.rotated(PI/2))
			else:
				emi_normals.append(spread_dir.rotated(-PI/2))
				
		index += 1
		
	emission_points = emi_points
	emission_normals = emi_normals

