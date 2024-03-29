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
	
	## After moving, if at the target location, remove the target.
	if is_zero_approx(get_entity().position.distance_to(target_local_position)):
		cell_targets.pop_front()


func set_speed(type: SpeedTypes, value: float):
	speeds[type] = value
	

func add_target_cells(cells: Array[Vector3i]):
	cell_targets.append_array(cells)

	
func get_speed(type: SpeedTypes) -> int:
	return speeds[type]


func get_cell_movement_cost(cell: Vector3i):
	pass
	
func get_pathable_cells() -> Array[Vector3i]:
	var output: Array[Vector3i] = Board.get_cells_flood_custom(get_grid_location(), get_speed(speed_current), is_cell_pathable)
	return []


func get_grid_location() -> Vector3i:
	return Board.local_to_map(get_entity().position)


func is_cell_pathable(cell: Vector3i, speed_used: SpeedTypes = speed_current):
	var flags_cell: Array[Board.CellFlags] = Board.get_cell_flags(cell)
	var flags_down: Array[Board.CellFlags] = Board.get_cell_flags(cell + Vector3i.DOWN)
	if Board.CellFlags.IMPASSABLE in flags_cell:
		return false
	
	match speed_used:
		SpeedTypes.WALK:
			
			if not Board.CellFlags.FOOTING in flags_down:
				return false
			
			
			
	return true




