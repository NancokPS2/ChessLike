extends Node3D
class_name ComponentVision

const COMPONENT_NAME: StringName = "ENTITY_VISION"

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
	
	
func is_cell_visible(coordinate: Vector3i) -> bool:
	var placed_at: Vector3i = get_entity().get_position_in_board()
	var collision: Array[Vector3i] = Board.get_cells_in_line(
		placed_at, 
		coordinate, 
		1,
		[Board.CellFlags.OPAQUE]
		)
		
	if collision.size() == 1 and collision[0] == coordinate:
		return true

	return false
	
	
func is_cell_targetable() -> bool:
	return true


func get_visible_cells() -> Array[Vector3i]:
	return [Vector3i.ONE]
