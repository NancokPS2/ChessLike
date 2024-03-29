extends Node3D

func _input(event: InputEvent) -> void:
	if event.is_action("ui_up"):
		#var cells: Array[Vector3i] = Board.get_cells_in_area(Vector3i.ZERO, Board.AreaTypes.FLOOD, Vector3i.FORWARD, 3, 0)
		#Board.set_cells_from_array(cells, 0)
		pass
	if event.is_action("ui_left"):
		pass
	if event.is_action("ui_down"):
		pass
	if event.is_action("ui_right"):
		pass

func _ready() -> void:
	assert(get_world_3d() == Board.get_world_3d())
	other.call_deferred()
	
	var new_entity := Entity3D.new()
	new_entity.add_all_components()
	add_child(new_entity)
	
	var move_comp: ComponentMovement = new_entity.get_component(ComponentMovement.COMPONENT_NAME)
	move_comp.add_target_cells([Vector3i.UP + Vector3i.ZERO, Vector3i.UP + Vector3i.RIGHT, Vector3i.UP + Vector3i.LEFT*2])
	
	var cells: Array[Vector3i] = Board.get_cells_in_area(
		Vector3i.ZERO, Board.AreaTypes.FLOOD, Vector3i.ZERO, 1
		)
	print(cells)

func other():
	await get_tree().process_frame
	print(Board.get_cells_in_line(Vector3i(-2, -1, 0), Vector3i(2, 1, 0), 100))


#func _process(delta: float):
	#var ray_params := PhysicsRayQueryParameters3D.create($Camera3D.global_position, $Camera3D.project_ray_normal(get_viewport().get_mouse_position()) * 1000)
	#print(get_world_3d().direct_space_state.intersect_ray(ray_params).get("position", "NONE"))
