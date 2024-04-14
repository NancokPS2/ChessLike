extends Resource
class_name ComponentCapabilityResource

@export_category("Main")
@export var identifier: String
@export var type: ComponentCapability.Types

@export_category("Contents")
@export var movement_type: ComponentMovement.Types = ComponentMovement.Types.UNDEFINED
@export var action_identifier_arr: Array[StringName]
@export var stat_bonuses: Array[int] = [
	100,#HEALTH
	100,#ENERGY
	100,#STRENGTH
	100,#AGILITY
	100,#MIND
	0,#SPECIAL
	5,#MOVE_DISTANCE
	0,#DEFENSE
	0,#DODGE
	100,#ACCURACY
	100,#TURN_DELAY_BASE
	]
@export var stat_modifiers: Array[float] = [1,1,1,1,1,1,1,1,1,1,1,]


func get_stat_bonus(stat: ComponentStatus.StatKeys) -> int:
	return stat_bonuses[stat]
	
	
func get_stat_modifier(stat: ComponentStatus.StatKeys) -> float:
	return stat_modifiers[stat]
