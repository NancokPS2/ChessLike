extends Node
class_name ComponentInventory

const COMPONENT_NAME: StringName = "ENTITY_INVENTORY"


func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
