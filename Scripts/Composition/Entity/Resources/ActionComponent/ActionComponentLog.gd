extends Resource
class_name ComponentActionEffectLog

## Section 1 (references)
var entity_source: Entity3D
var component_source: ComponentAction
var action: ComponentActionResource
var effect: ComponentActionResourceEffect


## Section 2 (targeting)
var targeted_cells: Array[Vector3i]
var targeted_entities: Array[Entity3D]

## ???
var effect_parameter_dict: Dictionary
var repeating: bool = false
var repetitions_left: int


func is_valid() -> bool:
	if not effect in action.effects:
		return false
		
	return true
