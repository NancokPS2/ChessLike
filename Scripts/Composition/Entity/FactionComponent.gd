extends Node
class_name ComponentFaction

const COMPONENT_NAME: StringName = "ENTITY_FACTION"

@export var own_faction: StringName
@export var friendly_factions: Array[StringName]
@export var hostile_factions: Array[StringName]

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()

	
func set_faction(faction_name: StringName):
	own_faction = faction_name
	
func is_faction_friendly(faction_component: ComponentFaction) -> bool:
	return own_faction in faction_component.friendly_factions

	
func is_faction_hostile(faction_component: ComponentFaction) -> bool:
	return own_faction in faction_component.hostile_factions or faction_component.own_faction in hostile_factions


func is_faction_neutral(faction_component: ComponentFaction) -> bool:
	return not (is_faction_friendly(faction_component) or is_faction_hostile(faction_component))
