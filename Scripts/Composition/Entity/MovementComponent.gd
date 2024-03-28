extends Node
class_name ComponentMovement

## All movement is stopped by [Board.CellFlags.IMPASSABLE]
enum Types {
	WALK, #Can walk on cells that have FOOTING
	FLY, #Can move and stop anywhere except for cells with DENSE
	HOVER, #Can stand on any IMPASSABLE or DENSE cell 
	SWIM, #Water only 
	TELEPORT, #Teleportation distance, cannot target cells that the unit cannot stay on.
	}

var speeds: Array[float] = [0,0,0,0,0]

const COMPONENT_NAME: StringName = "ENTITY_MOVEMENT"


func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()


func set_speed(type: Types, value: float):
	speeds[type] = value

	
func get_speed(type: Types) -> int:
	return speeds[type]


func get_grid_location() -> Vector3i:
	return Board.local_to_map(get_entity().position)
