extends Node3D
class_name ComponentMovement

## All movement is stopped by [Board.CellFlags.IMPASSABLE]
enum Types {
	WALK, #Can walk on cells that have FOOTING
	AMPHIBIOUS, #Can walk AND swim trough LIQUID
	FLY, #Can move and stop anywhere except for cells with DENSE
	HOVER, #Can stand on any IMPASSABLE or DENSE cell 
	SWIM, #Water only 
	TELEPORT, #Teleportation distance, cannot target cells that the unit cannot stay on.
	UNDEFINED, #Treated as an invalid value.
	}
	
enum Animations {
	INTERPOLATE
}

const COMPONENT_NAME: StringName = "ENTITY_MOVEMENT"

const BASE_POSITION_CHANGE_SPEED_PER_SECOND: float = 3.0
	
#ComponentMovement:Vector3i
static var board_position_dict: Dictionary

var cell_targets: Array[Vector3i]
var movement_type_current: Animations = Animations.INTERPOLATE


func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()

func _process(delta: float):
	## Movement code
	if cell_targets.is_empty():
		return
	
	var target: Vector3i = cell_targets.front()
	var target_local_position: Vector3 = Board.map_to_local(target)
	
	match movement_type_current:
		Animations.INTERPOLATE:
			var new_pos: Vector3 = get_entity().position.move_toward(
				target_local_position, delta * BASE_POSITION_CHANGE_SPEED_PER_SECOND
				)
			get_entity().position = new_pos
	
	## After reaching the target, complete the move and delete the target.
	if is_zero_approx(get_entity().position.distance_to(target_local_position)):
		set_position_in_board(cell_targets.pop_front())


func add_target_cells(cells: Array[Vector3i]):
	cell_targets.append_array(cells)


func set_position_in_board(cell: Vector3i):
	get_entity().position = Board.map_to_local(cell)
	board_position_dict.erase(self)
	board_position_dict[self] = get_position_in_board()
	Event.ENTITY_MOVED.emit(get_entity(), get_position_in_board())


func get_position_in_board() -> Vector3i:
	return Board.local_to_map(get_entity().position)
	
	
func get_entity_at_position_in_board(cell: Vector3i) -> Entity3D:
	var other_move_comp: ComponentMovement = board_position_dict.get(cell, null)
	return other_move_comp.get_entity()


func get_type() -> Types:
	var cap_comp: ComponentCapability = get_entity().get_component(ComponentCapability.COMPONENT_NAME)
	var output: Types = cap_comp.get_movement_type()
	if output == Types.UNDEFINED:
		push_error("Undefined movement type! Something went wrong.")
	return output


func get_move_distance() -> int:
	var stat_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	return stat_comp.get_stat(ComponentStatus.StatKeys.MOVE_DISTANCE)


func get_cell_movement_cost(cell: Vector3i, type_used: Types = get_type()) -> float:
	match type_used:
		Types.WALK:
			if Board.is_flag_in_cell(cell, Board.CellFlags.UNSTABLE):
				return 2
				
		Types.FLY:
			if Board.is_flag_in_cell(cell, Board.CellFlags.DENSE):
				return 4
				
		Types.HOVER:
			if Board.is_flag_in_cell(cell, Board.CellFlags.DENSE):
				return 4
	
	
	return 1
	
	
func get_pathable_cells() -> Array[Vector3i]:
	var output: Array[Vector3i] = Board.get_cells_flood_custom(
		get_position_in_board(), get_move_distance(), is_cell_pathable
		)
		
	return output


func is_cell_pathable(cell: Vector3i, type: Types = get_type()) -> bool:
	var flags_cell: Array[Board.CellFlags] = Board.get_cell_flags(cell)
	var flags_down: Array[Board.CellFlags] = Board.get_cell_flags(cell + Vector3i.DOWN)
	
	var self_fact_comp: ComponentFaction = get_entity().get_component(ComponentFaction.COMPONENT_NAME)
	
	## Check if the cell is occupied by someone
	if cell in board_position_dict.values():
		var other_move_comp: ComponentMovement = board_position_dict.find_key(cell)
		var other_fact_comp: ComponentFaction = other_move_comp.get_entity().get_component(ComponentFaction.COMPONENT_NAME)
		
		if not self_fact_comp.is_faction_friendly(other_fact_comp):
			return false
	
	if Board.CellFlags.IMPASSABLE in flags_cell:
		return false
	
	match type:
		Types.WALK:
			
			if not Board.CellFlags.FOOTING in flags_down:
				return false
			
	
	return true


func is_cell_landable(cell: Vector3i, type: Types = get_type()) -> bool:
	var flags_cell: Array[Board.CellFlags] = Board.get_cell_flags(cell)
	var flags_down: Array[Board.CellFlags] = Board.get_cell_flags(cell + Vector3i.DOWN)
	
	## Check if the cell is occupied by something.
	if cell in board_position_dict.values():
		return false
	
	if Board.CellFlags.IMPASSABLE in flags_cell:
		return false
	
	match type:
		Types.WALK:
			
			if not Board.CellFlags.FOOTING in flags_down:
				return false
			
	
	return true


func is_cell_closer_to_destination(cell: Vector3i, destination_cell: Vector3i) -> bool:
	Board.get_manhattan_distance(cell, destination_cell)
	return true

