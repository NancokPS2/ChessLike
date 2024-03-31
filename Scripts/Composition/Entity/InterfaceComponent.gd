extends Node2D
class_name ComponentInterface
## In order to find a node, it's name must be "UI_NodeTypesKeyHere"
## Do not add to the group any nodes that are meant to display a different entity at the same time
## Only ONE node may be set to autoupdate at a time, setting one will unset the rest.

enum NodeTypes {
	HEALTH_MAX,
	HEALTH_CURRENT,
	ENERGY_MAX,
	ENERGY_CURRENT,
}

const UPDATE_RATE: float = 1 / 3 ## 3 times per second

const COMPONENT_NAME: StringName = "ENTITY_INTERFACE"

static var interface_node_reference_dict: Dictionary

var auto_update_enabled: bool = true
var interface_node_dict: Dictionary

## NodeTypes:[int, Node, NodePath]
## NodeTypes = enum used to fetch the interface node
## int = index
## Node = source node
## NodePath = property path
var auto_update_dict: Dictionary

var auto_update_enabled_arr: Array[NodeTypes]

var update_timer := Timer.new()

func _init() -> void:
	Event.ENTITY_COMPONENT_INTERFACE_AUTO_UPDATE_ENABLED.connect(on_interface_component_enabled)
	auto_update_enabled_arr.assign(NodeTypes.values())


func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	await get_tree().process_frame
	set_all_interface_nodes_from_scene()
	set_all_autoupdates()
	
	update_timer.timeout.connect(update)
	add_child(update_timer)
	update_timer.start(UPDATE_RATE)


func update():
	if not auto_update_enabled:
		return
	
	## Update every node in the enabled Array
	for node_type: NodeTypes in auto_update_enabled_arr:
		
		## Ensure it is set
		var auto_update_data: Array = auto_update_dict.get(node_type, [0, null, ^"", []])
		if auto_update_data[1] == null or auto_update_data[2] == ^"":
			push_error("Auto update Array has not been properly set for type '{0}'. Data: {1}".format([node_type, str(auto_update_data)]))
			return
		
		var index: int = auto_update_data[0]
		var source_node: Node = auto_update_data[1]
		var prop_path: NodePath = auto_update_data[2]
		
		var value = source_node.get_indexed(prop_path)
		## If a function was fetched, call it to get the actual value
		if value is Callable:
			var call_args: Array = auto_update_data[3]
			value = value.callv(call_args)
		
		set_value_on_node(node_type, index, value)


func get_entity() -> Entity3D:
	return get_parent()
		
		
func set_all_interface_nodes_from_scene():
	for type: NodeTypes in NodeTypes.values():
		var node: Node = get_interface_node_reference_on_scene(type)
		add_interface_node_reference(type, node)
		set_all_autoupdates()
		
		
func set_all_autoupdates():
	var stat_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	
	set_autoupdate_for_type(
		NodeTypes.HEALTH_MAX, 
		0, 
		stat_comp, 
		^"get_stat", 
		[ComponentStatus.StatKeys.HEALTH]
		)
	set_autoupdate_for_type(
		NodeTypes.HEALTH_CURRENT, 
		0, 
		stat_comp, 
		^"get_meter", 
		[ComponentStatus.MeterKeys.HEALTH]
		)
	set_autoupdate_for_type(
		NodeTypes.ENERGY_MAX, 
		0, 
		stat_comp, 
		^"get_stat", 
		[ComponentStatus.StatKeys.ENERGY]
		)
	set_autoupdate_for_type(
		NodeTypes.ENERGY_CURRENT, 
		0, 
		stat_comp, 
		^"get_meter", 
		[ComponentStatus.MeterKeys.ENERGY]
		)

func set_autoupdate_enabled(enabled: bool):
	auto_update_enabled = enabled
	update_timer.paused = !enabled
	if enabled:
		Event.ENTITY_COMPONENT_INTERFACE_AUTO_UPDATE_ENABLED.emit(self)
		
		
func set_autoupdate_for_type(node_type: NodeTypes, index: int = 0, source_node: Node = null, property_path: NodePath = ^"", call_args_opt: Array = []): 
	if source_node == null:
		auto_update_dict.erase(node_type)
		auto_update_enabled_arr.erase(node_type)
	auto_update_dict[node_type] = [index, source_node, property_path, call_args_opt]


func set_value_on_node(node_type: NodeTypes, index: int, value):
	var node: Node = get_interface_node_reference(node_type, index)
	
	if not node:
		return
	
	## Many control nodes like Buttons and Labels
	if node.get("text") is String:
		node.set("text", str(value)) 
	## Mostly Ranges
	elif node.get("value") is float or node.get("value") is int:
		node.set("value", value as float)
	else:
		push_warning("Tried to set a value on interface node '{0}' but couldn't figure out how.")


func add_interface_node_reference(node_type: NodeTypes, node: Node):
	interface_node_reference_dict[node_type] = interface_node_reference_dict.get(node_type, []) + [node]


func clear_interface_node_reference(node_type: NodeTypes):
	interface_node_reference_dict[node_type].clear()
	
	
func get_interface_node_reference(node_type: NodeTypes, index: int = 0) -> Node:
	var ref_arr: Array[Node] = []
	ref_arr.assign(interface_node_reference_dict.get(node_type, []))
	
	if not index < ref_arr.size():
		push_warning("Interface node out of bounds. Index: {0}".format([str(index)]))
		return null
	
	return ref_arr[index]



	
	
func get_interface_node_reference_on_scene(node_type: NodeTypes) -> Node:
	var group_name: String = "UI_" + NodeTypes.find_key(node_type)
	var output: Node = get_tree().get_first_node_in_group(group_name)
	return output
		


func on_interface_component_enabled(comp: ComponentInterface):
	
	if comp != self:
		set_autoupdate_enabled(false)
