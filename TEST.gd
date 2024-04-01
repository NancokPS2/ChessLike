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
	
	entity_test()
	
	map_tests()
	
	board_test()

func board_test():
	await get_tree().process_frame
	var cells: Array[Vector3i] = Board.get_cells_in_area(
		Vector3i.ZERO, Board.AreaTypes.FLOOD, Vector3i.ZERO, 1
		)
	Board.build_from_map(load("user://MapExport.tres"))
	print(cells)
	
	print(Board.get_cells_in_line(Vector3i(-2, -1, 0), Vector3i(2, 1, 0), 100))

func map_tests():
	var new_map: Map = load("res://Singletons/Board/Map/GenerationTest.tres")
	new_map.generate()
	ResourceSaver.save(new_map, "user://MapExport.tres")


func entity_test():
	var new_entity := Entity3D.new()
	new_entity.add_all_components()
	add_child(new_entity)
	
	## Input
	var input_comp: ComponentInput = new_entity.get_component(ComponentInput.COMPONENT_NAME)
	input_comp.set_state(ComponentInput.States.AWAITING_MOVEMENT)
	
	## Movement
	var move_comp: ComponentMovement = new_entity.get_component(ComponentMovement.COMPONENT_NAME)
	#move_comp.add_target_cells([Vector3i.UP + Vector3i.ZERO, Vector3i.UP + Vector3i.RIGHT, Vector3i.UP + Vector3i.LEFT*2])
	
	## Display
	var output: Array[Vector3i]
	for cell: Vector3i in Board.get_cells_in_area(
		Vector3i.ZERO, Board.AreaTypes.FLOOD, Vector3i.ZERO, 1
		):
		output.append(cell + Vector3i.UP)
	var disp_comp: ComponentDisplay = new_entity.get_component(ComponentDisplay.COMPONENT_NAME)
	disp_comp.add_visibility_meshes_in_cells(output, disp_comp.SubMeshTypes.MOVE_PATHABLE)
	disp_comp.add_visibility_meshes_in_cells([Vector3i(2,1,0)], disp_comp.SubMeshTypes.ACTION_TARGET)
	disp_comp.add_visibility_meshes_in_cells([Vector3i(3,1,0)], disp_comp.SubMeshTypes.ACTION_HIT)
	
	## Action
	var pos_in_board: Vector3i = move_comp.get_position_in_board()
	move_comp.set_position_in_board(move_comp.get_position_in_board())
	var action_comp: ComponentAction = new_entity.get_component(ComponentAction.COMPONENT_NAME)
	var heal_resource: ComponentActionResource = ComponentAction.get_action_resource_by_identifier("HEAL")
	action_comp.use_action(heal_resource, [move_comp.get_position_in_board()])
	print("A")

	

#func _process(delta: float):
	#var ray_params := PhysicsRayQueryParameters3D.create($Camera3D.global_position, $Camera3D.project_ray_normal(get_viewport().get_mouse_position()) * 1000)
	#print(get_world_3d().direct_space_state.intersect_ray(ray_params).get("position", "NONE"))
