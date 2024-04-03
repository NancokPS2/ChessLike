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

const COMPONENT_NAME: StringName = "ENTITY_INTERFACE"

const UPDATE_RATE: float = 1 / 3 ## 3 times per second

static var interface_scene_dict: Dictionary

## TODO: The scenes already take care of updating their data from the provided entity, just handle the call timings from here
func set_entity_on_interface_node(entity: Entity3D, interface_node: ComponentInterfaceScene):
	interface_node.update(entity)






