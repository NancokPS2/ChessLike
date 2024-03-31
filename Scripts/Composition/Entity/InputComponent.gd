extends Node
class_name ComponentInput

const COMPONENT_NAME: StringName = "ENTITY_INPUT"

enum States {
	BLOCKED,
	STANDBY,
	AWAITING_MOVEMENT,
	AWAITING_ACTION_TARGET,
}
var input_clicks_active: Array[bool] = [false, false, false]

var state_current: States

func _ready() -> void:
	assert(get_parent() is Entity3D)
	Event.ENTITY_TURN_STARTED.connect(on_turn_changed.bind(true))
	Event.ENTITY_TURN_ENDED.connect(on_turn_changed.bind(false))
	Event.BOARD_CELL_SELECTED.connect(on_cell_selected)
	Event.BOARD_CELL_HOVERED.connect(on_cell_hovered)


func get_entity() -> Entity3D:
	return get_parent()


func set_state(state: States):
	state_current = state
	
	if not is_node_ready():
		await ready
	
	if state == States.BLOCKED:
		set_process_unhandled_input(false)
	else: 
		set_process_unhandled_input(true)
		
		
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
	var sub_mesh_type: ComponentDisplay.SubMeshTypes = ComponentDisplay.SubMeshTypes.CELL_HOVERED_INVALID
	
	match get_state():
		States.AWAITING_MOVEMENT:
			sub_mesh_type = ComponentDisplay.SubMeshTypes.CELL_HOVERED_VALID
	
	disp_comp.add_visibility_meshes_in_cells([cell], sub_mesh_type)
	
func on_cell_selected(cell: Vector3i, button_index: int):
	input_clicks_active[button_index]
	match get_state():
		States.AWAITING_MOVEMENT:
			var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
			move_comp.add_target_cells([cell])
			
