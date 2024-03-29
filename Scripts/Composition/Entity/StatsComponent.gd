extends Node
class_name ComponentStats
## Stores stats for various purposes

enum Keys {
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
	TURN_DELAY,
	}

const COMPONENT_NAME: StringName = "ENTITY_STATS"

var stat_dict: Dictionary
var boost_additive_dict: Dictionary
var boost_multiplier_dict: Dictionary

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()


func load_from_resource(stats: CharAttributes):
	pass
 

func set_stat(key: Keys, value: int):
	stat_dict[key] = value
 
 
## TODO: Implement stat modifications from status effects
func get_stat(key: Keys) -> int:
	var capability_comp: ComponentCapability = get_entity().get_component(ComponentCapability.COMPONENT_NAME)
	#var status_comp: Component = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	
	var base_value: int = stat_dict.get(key, 0)
	base_value += capability_comp.get_stat_bonus(key)
	#base_value += status_comp
	
	var modifier_value: float = 1
	modifier_value *= capability_comp.get_stat_modifier(key)
 	
	return base_value * modifier_value
	
## TODO: Everything below? Or just do it in ComponentStatus
	
func add_boost(stat_to_boost: Keys, value, identifier: String = "") -> Boost:
	var boost := Boost.new()
	boost.identifier = identifier
	boost.stat_boosted = stat_to_boost
	
	boost_additive_dict[stat_to_boost] = boost_additive_dict.get(stat_to_boost, []) + [boost]
	
	return boost
	
 
func remove_boost(boost: Boost):
	var stat: Keys = boost.stat_boosted
	boost_additive_dict.get(stat, []).erase( boost )
 
 
class Boost extends RefCounted:
	## This is used to store the boosts a player may obtain. Most common sources being items and status effects.
	## These are meant to be temporary and may be deleted at any time.
 
	const NO_IDENTIFIER: String = ""
	
	enum BoostTypes {ADDITIVE, MULTIPLICATIE}
	
	## If another boost with this identifier is present, prevent its addition
	var identifier: String = NO_IDENTIFIER
	
	var stat_boosted: Keys
 
	var linked_object: Object 
 
	var value: float = 0
