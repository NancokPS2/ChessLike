extends Resource
class_name ComponentActionLog

## Section 1 (references)
var entity_source: Entity3D
var component_source: ComponentAction
var action: ComponentActionResource


## Section 2 (targeting)
var targeted_cells: Array[Vector3i]
var targeted_entities: Array[Entity3D]

## ???
var repetitions_left: int


func is_valid() -> bool:
		
	return true
