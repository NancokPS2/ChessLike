extends Node
class_name IdentificationSystem

const COMPONENT_NAME: StringName = "ENTITY_FACTION_COMPONENT"

var refCompFactions:Array[IdentificationSystemFaction]

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_entered)	

func on_node_entered(node:Node) -> void:
	if node is IdentificationSystemFaction:
		faction_add(node)


func faction_get_all(fromGroup:bool)->Array[IdentificationSystemFaction]:
	if fromGroup:
		var factions:Array[IdentificationSystemFaction]
		factions.assign(get_tree().get_nodes_in_group(COMP_FACTION))
		return factions
	else:
		return refCompFactions
	
func faction_add(faction:IdentificationSystemFaction):
	refCompFactions.append(faction)
	
func faction_is_friendly(faction:IdentificationSystemFaction, targetfaction:IdentificationSystemFaction)->bool:
	return targetfaction.factionBelonging in faction.factionFriendlies

func faction_is_neutral(faction:IdentificationSystemFaction, targetfaction:IdentificationSystemFaction)->bool:
	return targetfaction.factionBelonging in faction.factionHostiles
	
func faction_is_hostile(faction:IdentificationSystemFaction, targetfaction:IdentificationSystemFaction)->bool:
	return not targetfaction.factionBelonging in faction.factionFriendlies or targetfaction.factionBelonging in faction.factionHostiles
