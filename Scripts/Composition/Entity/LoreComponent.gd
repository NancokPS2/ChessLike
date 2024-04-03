extends Node
class_name ComponentLore

enum Keys {
	NAME
}

const PERSISTENT_PROPERTIES: Array[String] = ["data_dict"]

const COMPONENT_NAME: StringName = "ENTITY_LORE"

var data_dict: Dictionary

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()


func set_data(key: Keys, data: String):
	data_dict[key] = data


func get_data(key: Keys) -> String:
	return data_dict.get(key, "")
