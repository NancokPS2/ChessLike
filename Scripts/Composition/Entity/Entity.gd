extends Node3D
class_name Entity3D

enum EntityFlags {
	HEAVY,
	LIGHT,
}

var components: Dictionary
var flags: Array[String]

func _init():
	child_entered_tree.connect(on_child_entered_tree)


func get_component(component_name: String) -> Node:
	assert(components.get(component_name, null).get("COMPONENT_NAME"))
	return components.get(component_name, null)
	

func on_child_entered_tree(node: Node):
	var comp_name: String = node.get("COMPONENT_NAME")
	
	if not comp_name is String:
		return
	
	components[comp_name] = node

func has_flag(flag: String) -> bool:
	return flag in flags
	
func set_flag(flag: String):
	pass
