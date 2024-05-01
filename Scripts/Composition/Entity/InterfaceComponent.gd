extends Node2D
class_name ComponentInterface

## In order to find a node, it's name must be "UI_NodeTypesKeyHere"
## Do not add to the group any nodes that are meant to display a different entity at the same time
## Only ONE node may be set to autoupdate at a time, setting one will unset the rest.

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Entity/Resources/InterfaceComponent/"]

const COMPONENT_NAME: StringName = "ENTITY_INTERFACE"

const INTERFACE_SCENE_GROUP: String = "COMPONENT_INTERFACE_SCENE_GROUP"

const UPDATE_RATE: float = 1 / 3 ## 3 times per second

static var interface_scene_dict: Dictionary

func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	Event.ENTITY_TURN_STARTED.connect(on_turn_started)


func get_entity() -> Entity3D:
	return get_parent()


## TODO: The scenes already take care of updating their data from the provided entity, just handle the call timings from here
func set_entity_on_interface_node(entity: Entity3D, interface_node: ComponentInterfaceScene, auto_update: bool = true):
	interface_node.update_interface(entity)
	if auto_update:
		interface_node.set_auto_update_target(entity)


func get_all_interface_instances()->Array[ComponentInterfaceScene]:
	var output: Array[ComponentInterfaceScene]
	for node: Node in get_tree().get_nodes_in_group(INTERFACE_SCENE_GROUP):
		if not node is ComponentInterfaceScene:
			push_warning("Non ComponentInterfaceScene found in the group.")
		output.append(node)
	return output


static func get_packed_scene_by_identifier(identifier: String) -> PackedScene:
	if interface_scene_dict.is_empty():
		ComponentAction.cache_all_resources()
	
	print(interface_scene_dict)
	
	var capability_res: PackedScene = interface_scene_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return capability_res.duplicate(true)


static func cache_all_packed_scenes():
	interface_scene_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is PackedScene:
				interface_scene_dict[res.identifier] = res


func on_turn_started(entity: Entity3D):
	if not entity == get_entity():
		return
		
	var interface: ComponentInterfaceScene = get_all_interface_instances().front()
	if not interface.is_node_ready():
		await interface.ready
	print(interface.identifier)
	print(interface.node_health_bar)
	set_entity_on_interface_node(entity, interface)

