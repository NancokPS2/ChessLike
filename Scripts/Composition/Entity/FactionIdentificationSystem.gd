extends Node
class_name IdentificationSystemFaction

@export var factionBelonging:StringName

@export var factionFriendlies:Array[StringName]
@export var factionHostiles:Array[StringName]

func _enter_tree() -> void:
	add_to_group(IdentificationSystem.COMP_FACTION_MEMBER)
