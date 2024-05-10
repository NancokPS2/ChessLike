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
	
	world_test()

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
	new_entity.position = Board.map_to_local(Vector3i.UP)
	add_child(new_entity)
	
	## Input
	var input_comp: ComponentInput = new_entity.get_component(ComponentInput.COMPONENT_NAME)
	input_comp.set_state(ComponentInput.States.STANDBY)
	
	## Movement
	var move_comp: ComponentMovement = new_entity.get_component(ComponentMovement.COMPONENT_NAME)
	#move_comp.add_target_cells([Vector3i.UP + Vector3i.ZERO, Vector3i.UP + Vector3i.RIGHT, Vector3i.UP + Vector3i.LEFT*2])
	
	## Display
	#var output: Array[Vector3i]
	

	
	# Capability
	var capa_comp: ComponentCapability = new_entity.get_component(ComponentCapability.COMPONENT_NAME)
	var capa_res: ComponentCapabilityResource = ComponentCapability.get_capability_resource_by_identifier("HUMAN")
	capa_comp.add_capability("HUMAN")
	
	## Lore
	var lore_comp: ComponentLore = new_entity.get_component(ComponentLore.COMPONENT_NAME)
	lore_comp.set_data(ComponentLore.Keys.NAME, "Marcelo")
	
	## Entity saving and loading
	new_entity.store_config_file("Marcelo")
	new_entity.load_config_file("Marcelo")
	
	## Interface
	var inter_comp: ComponentInterface = new_entity.get_component(ComponentInterface.COMPONENT_NAME)
	
	## Action
	#TODO: Properly test repetition actions
	var action_comp: ComponentAction = new_entity.get_component(ComponentAction.COMPONENT_NAME)
	var stack_comp: ComponentStack = new_entity.get_component(ComponentStack.COMPONENT_NAME)
	action_comp.update_actions_available()
	print_debug(action_comp.get_actions_available(ComponentAction.ActionCategories.ALL))
	
	var pos_in_board: Vector3i = move_comp.get_position_in_board()
	
	move_comp.set_position_in_board(move_comp.get_position_in_board())
	
	print(stack_comp.call_stack_arr)
	stack_comp.execute_stack()
	print("A")

	## Turn
	var turn_comp: ComponentTurn = new_entity.get_component(ComponentTurn.COMPONENT_NAME)
	turn_comp.end_turn()
	stack_comp.execute_stack()

#func _process(delta: float):
	#var ray_params := PhysicsRayQueryParameters3D.create($Camera3D.global_position, $Camera3D.project_ray_normal(get_viewport().get_mouse_position()) * 1000)
	#print(get_world_3d().direct_space_state.intersect_ray(ray_params).get("position", "NONE"))

func world_test():
	var new_world := WorldNode3D.new()
	add_child(new_world)
	new_world.add_all_components()
	
	#Day cycle
	var time_comp: WorldCompTime = new_world.get_component(WorldCompTime.COMPONENT_NAME)
	var tween: Tween = time_comp.create_tween()	
	tween.set_loops(0)
	tween.tween_method(time_comp.set_time, 0, time_comp.Lengths.DAY, 10)
	tween.tween_callback(time_comp.set_time.bind(0))
	tween.play()

