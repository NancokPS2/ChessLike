extends Node
class_name ComponentCapability

enum Types {
	RACE,
	CLASS,
}

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Resources/CapabilityComponent/", "user://Data/Composition/Resources/CapabilityComponent/"]

const COMPONENT_NAME: StringName = "ENTITY_CAPABILITY"

static var capability_resource_dict: Dictionary

## The limit for each type of capability, Types value = index
var capability_current_limit: Array[int] = [1,2]

var capability_current_res_arr: Array[String]
		
func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
	
	
func add_capability(identifier: String):
	var capability_to_add: ComponentCapabilityResource = ComponentCapability.get_capability_resource_by_identifier(identifier)
	if not capability_to_add:
		return
		
	var current_same_type: Array[ComponentCapabilityResource] = get_current_capability_resources(capability_to_add.type)
	
	if current_same_type.size() >= capability_current_limit[capability_to_add.type]:
		push_warning("Limit reached, cannot add another capability of type {0}.".format([Types.find_key(capability_to_add.type)]))
		return
	
	capability_current_res_arr.append(identifier)


func remove_capability(identifier: String) -> bool:
	for res_ident: String in capability_current_res_arr:
		if res_ident == identifier:
			capability_current_res_arr.erase(res_ident)
			return true
	
	push_warning("Could not find capability with that identifier in the current ones.")
	return false
	
	
func clear_capabilities():
	capability_current_res_arr.clear()
	
	
static func get_capability_resource_by_identifier(identifier: String) -> ComponentCapabilityResource:
	if capability_resource_dict.is_empty():
		ComponentCapability.cache_all_resources()
		
	var capability_res: ComponentCapabilityResource = capability_resource_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return capability_res

	
func get_current_capability_resources(type: Types) -> Array[ComponentCapabilityResource]:
	var output: Array[ComponentCapabilityResource] = []
	
	for res_ident: String in capability_current_res_arr:
		var res: ComponentCapabilityResource = ComponentCapability.get_capability_resource_by_identifier(res_ident)
		if res.type == type:
			output.append(res)
	
	return output

	
func get_stat_bonus(stat: ComponentStats.Keys) -> int:
	var output: int = 0
	for res_ident: String in capability_current_res_arr:
		var res: ComponentCapabilityResource = ComponentCapability.get_capability_resource_by_identifier(res_ident)
		output += res.get_stat_bonus(stat)
	return output
	

func get_stat_modifier(stat: ComponentStats.Keys) -> float:
	var output: int = 1
	for res_ident: String in capability_current_res_arr:
		var res: ComponentCapabilityResource = ComponentCapability.get_capability_resource_by_identifier(res_ident)
		output *= res.get_stat_modifier(stat)
	return output
	
	
func get_movement_type() -> ComponentMovement.Types:
	for cap_res: ComponentCapabilityResource in get_current_capability_resources(Types.RACE):
		if cap_res.movement_type != ComponentMovement.Types.UNDEFINED:
			return cap_res.movement_type
	
	return ComponentMovement.Types.UNDEFINED
	
static func cache_all_resources():
	capability_resource_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentCapabilityResource:
				capability_resource_dict[res.identifier] = res
	
