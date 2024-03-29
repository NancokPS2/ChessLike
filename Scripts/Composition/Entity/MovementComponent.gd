extends Node3D
class_name ComponentMovement

## All movement is stopped by [Board.CellFlags.IMPASSABLE]
enum SpeedTypes {
	WALK, #Can walk on cells that have FOOTING
	FLY, #Can move and stop anywhere except for cells with DENSE
	HOVER, #Can stand on any IMPASSABLE or DENSE cell 
	SWIM, #Water only 
	TELEPORT, #Teleportation distance, cannot target cells that the unit cannot stay on.
	}
	
enum MovementTypes {
	INTERPOLATE
}

const COMPONENT_NAME: StringName = "ENTITY_MOVEMENT"

const BASE_POSITION_CHANGE_SPEED_PER_SECOND: float = 3.0
	
#ComponentMovement:Vector3i
static var board_position_dict: Dictionary

var speeds: Array[float] = [0,0,0,0,0]

var cell_targets: Array[Vector3i]
var speed_current: SpeedTypes
var movement_type_current: MovementTypes = MovementTypes.INTERPOLATE


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
		MovementTypes.INTERPOLATE:
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
	
	
func set_speed(type: SpeedTypes, value: float):
	speeds[type] = value


func get_position_in_board() -> Vector3i:
	return Board.local_to_map(get_entity().position)


func get_speed(type: SpeedTypes) -> int:
	return speeds[type]


func get_cell_movement_cost(cell: Vector3i, speed_used: SpeedTypes = speed_current) -> float:
	var output: float = 1
	
	match speed_used:
		SpeedTypes.WALK:
			if Board.is_flag_in_cell(cell, Board.CellFlags.UNSTABLE):
				return 2
				
		SpeedTypes.FLY:
			if Board.is_flag_in_cell(cell, Board.CellFlags.DENSE):
				return 4
				
		SpeedTypes.HOVER:
			if Board.is_flag_in_cell(cell, Board.CellFlags.DENSE):
				return 4
	
	
	return 1
	
	
func get_pathable_cells(speed_used: SpeedTypes = speed_current) -> Array[Vector3i]:		
	var output: Array[Vector3i] = Board.get_cells_flood_custom(get_position_in_board(), get_speed(speed_current), is_cell_pathable)
		
	return output



func is_cell_pathable(cell: Vector3i, speed_used: SpeedTypes = speed_current) -> bool:
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
	
	match speed_used:
		SpeedTypes.WALK:
			
			if not Board.CellFlags.FOOTING in flags_down:
				return false
			
	
	return true


func is_cell_landable(cell: Vector3i, speed_used: SpeedTypes = speed_current) -> bool:
	var flags_cell: Array[Board.CellFlags] = Board.get_cell_flags(cell)
	var flags_down: Array[Board.CellFlags] = Board.get_cell_flags(cell + Vector3i.DOWN)
	
	## Check if the cell is occupied by something.
	if cell in board_position_dict.values():
		return false
	
	if Board.CellFlags.IMPASSABLE in flags_cell:
		return false
	
	match speed_used:
		SpeedTypes.WALK:
			
			if not Board.CellFlags.FOOTING in flags_down:
				return false
			
	
	return true


