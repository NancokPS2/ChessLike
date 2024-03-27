extends Node
class_name TurnSystemUser

func _enter_tree() -> void:
	add_to_group(TurnSystem.COMP_TURN_USER)

@export var turnMaxDelay:float
var turnCurrentDelay:float
