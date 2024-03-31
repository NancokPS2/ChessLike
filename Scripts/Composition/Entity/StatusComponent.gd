extends Node
class_name ComponentStatus
## Used to store and return stats and passive effects

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

enum PassiveActivationConditions {
	APPLIED,# No parameters
	TIME_PASSED,# [Turn ticks: int]
	TURN_ENDED,# No parameters
	SUFFERED_DAMAGE,# Minimum damage
	TARGETED_BY_ACTION,# Flags required
}

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Resources/StatusComponents/", "user://Data/Composition/Resources/StatusComponents/"]
const COMPONENT_NAME: StringName = "ENTITY_STATUS"

static var pasive_effect_resource_cache_dict: Dictionary

var stat_dict: Dictionary
var boost_additive_dict: Dictionary
var boost_multiplier_dict: Dictionary

var meter_dict: Dictionary

var passive_effects_applied: Array


func _init() -> void:
	for meter: String in MeterKeys:
		set_meter(meter, 0)


func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
 

static func cache_all_resources():
	pasive_effect_resource_cache_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentStatusResourcePassive:
				pasive_effect_resource_cache_dict[res.identifier] = res
	
	
func set_meter(key: String, value: int):
	meter_dict[key] = value


func set_stat(key: StatKeys, value: int):
	stat_dict[key] = value


func add_passive_applied(passive_effect: ComponentStatusResourcePassive):
	passive_effects_applied.append(passive_effect)
	
	
## Removes invalid passive effects
func clean_passive_applied():
	for passive: ComponentStatusResourcePassive in passive_effects_applied:
		if not passive:
			remove_passive_applied.call_deferred(passive)
	
	
func remove_passive_applied(passive: ComponentStatusResourcePassive):
	passive_effects_applied.erase(passive)
	
	
static func get_passive_resource_by_identifier(identifier: String) -> ComponentStatusResourcePassive:
	if pasive_effect_resource_cache_dict.is_empty():
		ComponentStatus.cache_all_resources()
		
	var pasive_effect_res: ComponentStatusResourcePassive = pasive_effect_resource_cache_dict.get(identifier, null)
	if not pasive_effect_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return pasive_effect_res.duplicate(true)
 

func get_meter(key: String) -> int:
	return meter_dict.get(key, 0)

 
## TODO: Implement stat modifications from passive effects
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
