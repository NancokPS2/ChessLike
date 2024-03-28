extends Node3D
class_name DisplayComponent

const COMPONENT_NAME: StringName = "ENTITY_DISPLAY"

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()

