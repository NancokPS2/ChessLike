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

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Entity/Resources/InterfaceComponent/"]

const COMPONENT_NAME: StringName = "ENTITY_INTERFACE"

const UPDATE_RATE: float = 1 / 3 ## 3 times per second

static var interface_scene_dict: Dictionary

## TODO: The scenes already take care of updating their data from the provided entity, just handle the call timings from here
func set_entity_on_interface_node(entity: Entity3D, interface_node: ComponentInterfaceScene):
	interface_node.update_interface(entity)


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





