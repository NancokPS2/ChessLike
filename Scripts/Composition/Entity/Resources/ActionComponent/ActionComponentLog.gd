extends Resource
class_name ComponentActionEffectLog

var entity_source: Entity3D
var action: ComponentActionResource
var effect: ComponentActionResourceEffect
var effect_parameter_dict: Dictionary
var targeted_cells: Array[Vector3i]
var entities_can_hit: Array[Entity3D]

var repeating: bool = false
var repetitions_left: int


func is_valid() -> bool:
	if not effect in action.effects:
		return false
		
	return true

func set_effect_parameter(key: ComponentAction.Params, value):
	effect_parameter_dict[key] = value

func get_effect_parameter(key: ComponentAction.Params) -> Variant:
	return effect_parameter_dict.get(key, null)
