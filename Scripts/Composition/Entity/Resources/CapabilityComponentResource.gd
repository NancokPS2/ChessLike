extends Resource
class_name ComponentCapabilityResource

@export_category("Main")
@export var identifier: String
@export var type: ComponentCapability.Types

@export_category("Contents")
@export var ability_identifier_arr: Array[String]
@export var stat_bonuses: Array[int] = [0,0,0,0,0,0,0,0,0,0,0,0]
@export var stat_modifiers: Array[float] = [1,1,1,1,1,1,1,1,1,1,1,1]

func get_stat_bonus(stat: ComponentStats.Keys) -> int:
	return stat_bonuses[stat]
	
	
func get_stat_modifier(stat: ComponentStats.Keys) -> float:
	return stat_modifiers[stat]
