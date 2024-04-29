extends Node
class_name ComponentInput

const COMPONENT_NAME: StringName = "ENTITY_INPUT"

enum States {
	BLOCKED, # No inputs should be being processed
	STANDBY, # Awaiting an action or some other input
	AWAITING_ACTION_TARGET,
}
enum MetaKeys {
	SELECTED_ACTION,
	LAST_SELECTED_CELL,
}
var input_comp_arr: Array[ComponentInput]

var state_current: States

var state_metadata: Dictionary

func _ready() -> void:
	assert(get_parent() is Entity3D)
	if not self in input_comp_arr:
		input_comp_arr.append(self)
	
	Event.ENTITY_TURN_STARTED.connect(on_turn_changed.bind(true))
	Event.ENTITY_TURN_ENDED.connect(on_turn_changed.bind(false))
	Event.BOARD_CELL_SELECTED.connect(on_cell_selected)
	Event.BOARD_CELL_HOVERED.connect(on_cell_hovered)
	Event.ENTITY_INTERFACE_ACTION_SELECTED.connect(on_action_selected)
	Event.ENTITY_INPUT_BACK.connect(on_input_back)


func get_entity() -> Entity3D:
	return get_parent()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("cancel"):
		Event.ENTITY_INPUT_BACK.emit(self)


func set_state(state: States):
	state_current = state
	
	if not is_node_ready():
		await ready
	
	state_metadata.clear()
	
	if state == States.BLOCKED:
		set_process_unhandled_input(false)
	else: 
		#BLOCK all other input components
		set_process_unhandled_input(true)
		for input_comp: ComponentInput in input_comp_arr:
			if input_comp == self:
				continue
			input_comp.set_state(States.BLOCKED)
		
		
func get_state() -> States:
	return state_current
	
	
func on_turn_changed(entity: Entity3D, started: bool) -> void:
	if not entity == self:
		return
		
	if started:
		set_state(States.STANDBY)
	else:
		set_state(States.BLOCKED)


func on_cell_hovered(cell: Vector3i):
	var disp_comp: ComponentDisplay = get_entity().get_component(ComponentDisplay.COMPONENT_NAME)
	
	match get_state():
		States.AWAITING_ACTION_TARGET:
			var action_comp: ComponentAction = get_entity().get_component(ComponentAction.COMPONENT_NAME)
			var action_selected: ComponentActionResource = state_metadata.get(MetaKeys.SELECTED_ACTION, null)
			var hittable_cells: Array[Vector3i] = action_comp.get_hit_cells_by_action(cell, action_selected)
			
			disp_comp.add_visibility_meshes_in_cells([cell], ComponentDisplay.SubMeshTypes.ACTION_TARGET)
			disp_comp.add_visibility_meshes_in_cells(hittable_cells, ComponentDisplay.SubMeshTypes.ACTION_HIT)
			
		_:
			disp_comp.add_visibility_meshes_in_cells([], ComponentDisplay.SubMeshTypes.ACTION_TARGET)
			disp_comp.add_visibility_meshes_in_cells([], ComponentDisplay.SubMeshTypes.ACTION_HIT)
			disp_comp.add_visibility_meshes_in_cells([cell], ComponentDisplay.SubMeshTypes.CELL_HOVERED_INVALID)
	
	
func on_cell_selected(cell: Vector3i, button_index: int):
	match get_state():
		States.AWAITING_ACTION_TARGET:
			#Must be a primary click
			if not button_index == MOUSE_BUTTON_LEFT:
				return
			
			#If this is the first time the cell is selected, stop here and mark it
			var last_cell: Vector3i = state_metadata.get(MetaKeys.LAST_SELECTED_CELL, Board.INVALID_CELL_COORDS)
			if last_cell != cell:
				state_metadata[MetaKeys.LAST_SELECTED_CELL] = cell
				return
			
			#An action must be selected
			var action_selected: ComponentActionResource = state_metadata.get(MetaKeys.SELECTED_ACTION, null)
			if not action_selected:
				push_warning("No action selected yet")
				return
			
			var stack_comp: ComponentStack = get_entity().get_component(ComponentStack.COMPONENT_NAME)
			var action_comp: ComponentAction = get_entity().get_component(ComponentAction.COMPONENT_NAME)
			#var targetable_cells: Array[Vector3i] = action_comp.get_targetable_cells_for_action(action_selected)
			var hit_cells: Array[Vector3i] = action_comp.get_hit_cells_by_action(cell, action_selected)
			var hit_entities: Array[Entity3D] = action_comp.get_entities_hit_by_action_at_cells(action_selected, hit_cells)
			
			var logs: Array[ComponentActionLog]
			var action_log: ComponentActionLog = action_comp.create_log_for_action(action_selected)
			action_log.targeted_cells = hit_cells
			action_log.targeted_entities = hit_entities
			assert(action_log.is_valid())
			logs.append(action_log)
			action_comp.action_logs_add_to_queue(logs)
				
			action_comp.action_logs_send_queue_to_stack_component()
			stack_comp.execute_stack.call_deferred()
			

func on_action_selected(comp: ComponentInterface, action: ComponentActionResource):
	if not comp == get_entity().get_component(ComponentInterface.COMPONENT_NAME):
		return
	print_debug("Action activated")
	
	match get_state():
		States.STANDBY:
			set_state(States.AWAITING_ACTION_TARGET)
			state_metadata[MetaKeys.SELECTED_ACTION] = action
			
			var disp_comp: ComponentDisplay = get_entity().get_component(ComponentDisplay.COMPONENT_NAME)
			var action_comp: ComponentAction = get_entity().get_component(ComponentAction.COMPONENT_NAME)
			var targetable_cells: Array[Vector3i] = action_comp.get_targetable_cells_for_action(action)
			
			disp_comp.add_visibility_meshes_in_cells(targetable_cells, ComponentDisplay.SubMeshTypes.MOVE_PATHABLE)
			
		States.AWAITING_ACTION_TARGET:
			set_state(States.STANDBY)
			


func on_input_back(component: ComponentInput):
	if not component == self:
		return
		
	match get_state():
		States.AWAITING_ACTION_TARGET:
			set_state(States.STANDBY)
			print_debug("Canceled action target selection")
