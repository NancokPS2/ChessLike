extends Node
class_name ComponentStats
## Stores stats for various purposes

const COMPONENT_NAME: StringName = "ENTITY_STATS"

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()


func load_from_resource(stats: CharAttributes):
	pass
