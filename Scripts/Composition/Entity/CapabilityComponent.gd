extends Node
class_name ComponentCapability

enum Types {
	RACE,
	CLASS,
}

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Resources/CapabilityComponent/", "user://Data/Composition/Resources/CapabilityComponent/"]

const COMPONENT_NAME: StringName = "ENTITY_CAPABILITY"

static var capability_resource_dict: Dictionary

var capability_current_res_arr: Array[ComponentCapabilityResource]
		
func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
	
	
func add_capability(identifier: String):
	capability_current_res_arr.append(ComponentCapability.get_capability_resource_by_identifier(identifier))


func remove_capability(identifier: String) -> bool:
	for res: ComponentCapabilityResource in capability_current_res_arr:
		if res.identifier == identifier:
			capability_current_res_arr.erase(res)
			res.queue_free()
			return true
	
	push_warning("Could not find capability with that identifier.")
	return false
	
	
static func get_capability_resource_by_identifier(identifier: String) -> ComponentCapabilityResource:
	if capability_resource_dict.is_empty():
		ComponentCapability.cache_all_resources()
		
	var capability_res: ComponentCapabilityResource = capability_resource_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with that identifier.")
	
	return capability_res

	
func get_current_capabilities(type: Types) -> Array[ComponentCapabilityResource]:
	var output: Array[ComponentCapabilityResource] = []
	
	for res: ComponentCapabilityResource in capability_current_res_arr:
		if res.type == type:
			output.append(res)
	
	return output

	
func get_stat_bonus(stat: ComponentStats.Keys) -> int:
	var output: int = 0
	for res: ComponentCapabilityResource in capability_current_res_arr:
		output += res.get_stat_bonus(stat)
	return output
	

func get_stat_modifier(stat: ComponentStats.Keys) -> float:
	var output: int = 1
	for res: ComponentCapabilityResource in capability_current_res_arr:
		output *= res.get_stat_modifier(stat)
	return output
	
	
static func cache_all_resources():
	capability_resource_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentCapabilityResource:
				capability_resource_dict[res.identifier] = res
	
