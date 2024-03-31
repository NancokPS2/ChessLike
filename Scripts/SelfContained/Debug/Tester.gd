extends Node3D
class_name Tester

@export var enabled: bool = false:
	set(val):
		enabled = val
		set_process(enabled)
@export var raycast_point_a: Vector3
@export var raycast_point_b: Vector3
var last_result: String
var last_result2: String
var debug_mesh_instance := MeshInstance3D.new()

func _ready() -> void:
	var debug_mesh := SphereMesh.new()
	debug_mesh_instance.mesh = debug_mesh



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ray_params := PhysicsRayQueryParameters3D.create(raycast_point_a, raycast_point_b)
	var result: String = str(get_world_3d().direct_space_state.intersect_ray(ray_params).get("position", "NONE"))
	
	if result != last_result:
		print(result)
		last_result = result
		
	var camera: Camera3D = get_viewport().get_camera_3d()
	var ray_params2 := PhysicsRayQueryParameters3D.create(camera.global_position, camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000)
	var result2 = get_world_3d().direct_space_state.intersect_ray(ray_params2).get("position", "NONE")
	
	if Input.is_action_just_pressed("primary_click"):
		print(result2)
		if result2 is Vector3:
			debug_mesh_instance.global_position = result2
	elif Input.is_action_just_pressed("secondary_click"):
		if result2 is Vector3:
			print(
				"Cell is: " + str(Board.local_to_map(result2))
			)
			print(
				"Center is at local: " + str(Board.map_to_local(Board.local_to_map(result2)))
				)
