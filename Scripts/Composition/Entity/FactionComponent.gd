extends Node
class_name FactionCOmponent

const COMPONENT_NAME: StringName = "ENTITY_FACTION_COMPONENT"

@export var own_faction: StringName
@export var friendly_factions: Array[StringName]
@export var hostile_factions: Array[StringName]

	
func set_faction(faction_name: StringName):
	own_faction = faction_name
	
func faction_is_friendly(faction_component: FactionCOmponent) -> bool:
	return own_faction in faction_component.friendly_factions

	
func faction_is_hostile(faction_component: FactionCOmponent) -> bool:
	return own_faction in faction_component.hostile_factions or faction_component.own_faction in hostile_factions


func faction_is_neutral(faction_component: FactionCOmponent) -> bool:
	return not (faction_is_friendly(faction_component) or faction_is_hostile(faction_component))
