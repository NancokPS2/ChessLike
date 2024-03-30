extends Node2D
class_name ComponentInterface
## In order to find a node, it's name must be "UI_NodeTypesKeyHere"
## Do not add to the group any nodes that are meant to display a different entity at the same time

enum NodeTypes {
	HEALTH_NUMBER,
	ENERGY_NUMBER,
}

const COMPONENT_NAME: StringName = "ENTITY_INTERFACE"

static var interface_node_dict_static: Dictionary

var auto_update_enabled: bool = true
var interface_node_dict: Dictionary
## NodeTypes:[Node, NodePath]
## NodeTypes = enum used to fetch the interface node
## Node = source node
## NodePath = property path
var auto_update_dict: Dictionary
var auto_update_enabled_arr: Array[NodeTypes]


func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	await get_tree().process_frame
	set_all_interface_nodes_from_scene()


func _process(delta: float):
	if not auto_update_enabled:
		return
	
	## Update every node in the enabled Array
	for node_type: NodeTypes in auto_update_enabled_arr:
		
		## Ensure it is set
		var auto_update_data: Array = auto_update_dict.get(node_type, [null, ""])
		if auto_update_data[0] == null or auto_update_data[1] == "":
			push_error("Auto update Array has not been properly set for type '{0}'. Data: {1}".format([node_type, str(auto_update_data)]))
			return
		
		var source_node: Node = auto_update_data[0]
		var prop_path: NodePath = auto_update_data[1]
		
		var value = source_node.get_indexed(prop_path)
			
		set_value_on_node(node_type, value)


func set_all_interface_nodes_from_scene():
	for type: NodeTypes in NodeTypes:
		var node: Node = get_interface_node_on_scene(type)
		set_interface_node(type, node)


func get_entity() -> Entity3D:
	return get_parent()
		
		
func set_autoupdate_for_type(node_type: NodeTypes, source_node: Node = null, property_path: NodePath = ""): 
	if source_node == null:
		auto_update_dict.erase(node_type)
	auto_update_dict[node_type] = [source_node, property_path]
	

func set_interface_node(node_type: NodeTypes, node: Node):
	if not node:
		set_autoupdate_for_type(node_type)
		
	interface_node_dict[node_type] = node


func set_value_on_node(node_type: NodeTypes, value):
	var node: Node = get_interface_node(node_type)
	
	if not node:
		return
	
	if node.get("text") is String:
		node.set("text", str(value)) 
	else:
		push_warning("Tried to set a value on interface node '{0}' but couldn't figure out how.")


func get_interface_node(node_type: NodeTypes) -> Node:
	var node: Node = interface_node_dict.get(node_type, null)
	
	if not node:
		push_error("Interface node '{0}' has not been set.".format([NodeTypes.find_key(node)]))
	
	return node
	
	
func get_interface_node_on_scene(node_type: NodeTypes) -> Node:
	var group_name: String = "UI_" + NodeTypes.find_key(node_type)
	var output: Node = get_tree().get_first_node_in_group(group_name)
	return output
		
