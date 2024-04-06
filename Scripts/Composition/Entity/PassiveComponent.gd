extends Node
class_name ComponentPassive

enum ActivationConditions {
	APPLIED,# No parameters
	TIME_PASSED,# Turn ticks: int
	TURN_ENDED,# No parameters
	SUFFERED_DAMAGE,# Minimum damage: int
	TARGETED_BY_ACTION,# Flags required: Array[ComponentAction.ActionFlags]
	ACTION_USED,#
}
enum Flags {
	TARGET_CULPRIT,# If the passive was triggered by an action, add the source's cell of the action
	TARGET_SELF, # Add self's cell to the list of targets
	TARGET_EVERYONE, # Add every cell with an entity to the list
}
enum MetaKeys {
	DURATION,
}

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Resources/StatusComponents/", "user://Data/Composition/Resources/StatusComponents/"]
const COMPONENT_NAME: StringName = "ENTITY_PASSIVE"

static var pasive_effect_resource_cache_dict: Dictionary

var passive_effects_applied: Array[ComponentPassiveResource]
var passive_effect_meta_dict: Dictionary

func _ready() -> void:
	Event.ENTITY_COMPONENT_STACK_ADDED.connect(on_event_stack_added)
	assert(get_parent() is Entity3D)

	
func get_entity() -> Entity3D:
	return get_parent()


static func cache_all_resources():
	pasive_effect_resource_cache_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentPassiveResource:
				pasive_effect_resource_cache_dict[res.identifier] = res


func add_passive_activation_to_stack(passive: ComponentPassive):
	ComponentStack


func add_passive_applied(passive_effect: ComponentPassiveResource):
	passive_effects_applied.append(passive_effect)

	
## Removes invalid passive effects
func clean_passive_applied():
	for passive: ComponentPassiveResource in passive_effects_applied:
		if not is_instance_valid(passive):
			remove_passive_applied.call_deferred(passive)

	
func remove_passive_applied(passive: ComponentPassiveResource):
	passive_effects_applied.erase(passive)
	

func set_passive_meta(passive: ComponentPassiveResource, key: MetaKeys, value):
	passive_effect_meta_dict[key] = value

	
func clear_passive_meta(passive: ComponentPassiveResource):
	var succes: bool = passive_effect_meta_dict.erase(passive)
	if not succes:
		push_warning("{0} not present".format([passive.identifier]))


func get_passive_meta(passive: ComponentPassiveResource, key: MetaKeys) -> Variant:
	return passive_effect_meta_dict.get(key, null)
	
	
static func get_passive_resource_by_identifier(identifier: String) -> ComponentPassiveResource:
	if pasive_effect_resource_cache_dict.is_empty():
		ComponentPassive.cache_all_resources()
		
	var pasive_effect_res: ComponentPassiveResource = pasive_effect_resource_cache_dict.get(identifier, null)
	if not pasive_effect_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return pasive_effect_res.duplicate(true)


func on_event_stack_added(stack_object: ComponentStack.StackObject):
	var source_component: Node = stack_object.function.get_object()
	
	if not source_component is ComponentAction:
		return
		
	var action: ComponentActionResource = stack_object.get_metadata("action")
	var target_cells: Array[Vector3i] = stack_object.get_metadata("target_cells")
	var enitity_source: Entity3D = source_component.get_entity()
	var object_index: int = ComponentStack.get_object_index(stack_object)
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var action_comp: ComponentAction = get_entity().get_component(ComponentAction.COMPONENT_NAME)
	
	for passive: ComponentPassiveResource in passive_effects_applied:
		
		## Must be a passive that can activate when targeted
		if not ActivationConditions.TARGETED_BY_ACTION in passive.activation_flags:
			continue
		
		## Must have targeted this entity
		if not move_comp.get_position_in_board() in target_cells:
			continue
		
		
