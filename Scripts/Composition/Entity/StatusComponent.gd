extends Node
class_name ComponentStatus
## Used to store and return stats and status effects

enum StatKeys {
	HEALTH,
	ENERGY,
	STRENGTH,
	AGILITY,
	MIND,
	SPECIAL,
	MOVE_DISTANCE,
	DEFENSE,
	DODGE,
	ACCURACY,
	TURN_DELAY_BASE,
	}
	
const MeterKeys: Dictionary = {
	HEALTH = "HEALTH",
	ENERGY = "ENERGY",
}
const COMPONENT_NAME: StringName = "ENTITY_STATS"

var stat_dict: Dictionary
var boost_additive_dict: Dictionary
var boost_multiplier_dict: Dictionary

var meter_dict: Dictionary


func _init() -> void:
	for meter: String in MeterKeys:
		set_meter(meter, 0)


func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
 

func set_meter(key: String, value: int):
	meter_dict[key] = value


func set_stat(key: StatKeys, value: int):
	stat_dict[key] = value
 

func get_meter(key: String) -> int:
	return meter_dict.get(key, 0)

 
## TODO: Implement stat modifications from status effects
func get_stat(key: StatKeys) -> int:
	var capability_comp: ComponentCapability = get_entity().get_component(ComponentCapability.COMPONENT_NAME)
	
	var base_value: int = stat_dict.get(key, 0)
	base_value += capability_comp.get_stat_bonus(key)
	
	var modifier_value: float = 1
	modifier_value *= capability_comp.get_stat_modifier(key)
 	
	return base_value * modifier_value
	
## TODO: Everything below?
	
func add_boost(stat_to_boost: StatKeys, value, identifier: String = "") -> Boost:
	var boost := Boost.new()
	boost.identifier = identifier
	boost.stat_boosted = stat_to_boost
	
	boost_additive_dict[stat_to_boost] = boost_additive_dict.get(stat_to_boost, []) + [boost]
	
	return boost
	
 
func remove_boost(boost: Boost):
	var stat: StatKeys = boost.stat_boosted
	boost_additive_dict.get(stat, []).erase( boost )
 
 
class Boost extends RefCounted:
	## This is used to store the boosts a player may obtain. Most common sources being items and status effects.
	## These are meant to be temporary and may be deleted at any time.
 
	const NO_IDENTIFIER: String = ""
	
	enum BoostTypes {ADDITIVE, MULTIPLICATIE}
	
	## If another boost with this identifier is present, prevent its addition
	var identifier: String = NO_IDENTIFIER
	
	var stat_boosted: StatKeys
 
	var linked_object: Object 
 
	var value: float = 0
