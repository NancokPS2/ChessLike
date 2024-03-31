extends Node3D
class_name ComponentAction

enum Types {
	CHANGE_METER, # Meter name, amount
	LAUNCH_ENTITY, # Vector
}
## Affects how others behave to this action
enum ActionFlags { 
	HURTS, #Causes pain animations
	HOSTILE, #Affects reactions
	FRIENDLY, #Affects reactions
}
## Defines what kind of cells can be selected to use the action on. By default any cell within range is valid
enum TargetingFlags {
	NEED_ENTITY, # The cell cannot be selected if it does not have a valid entity. Recommended for single target actions.
	NEED_VISION, # The action cannot go trough walls. Use Vision component.
}
## What entities are affected.
enum EntityHitFlags {
	SELF,
	FRIENDLY,
	HOSTILE,
}
## The shape to use.
enum TargetingShape {
	FLOOD
}

const COMPONENT_NAME: StringName = "ENTITY_ACTION"

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Resources/ActionComponent/", "user://Data/Composition/Resources/ActionComponent/"]

static var action_resource_cache_dict: Dictionary

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()


static func cache_all_resources():
	action_resource_cache_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentActionResource:
				action_resource_cache_dict[res.identifier] = res


## TODO
func use_action(action: ComponentActionResource, target_cells: Array[Vector3i]):
	## Used to check entity positions
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	
	## Execute the effects on a cell at a time
	for cell: Vector3i in target_cells:
		var entity_here: Entity3D = move_comp.get_entity_at_position_in_board(cell)
		Event.ENTITY_COMPONENT_ACTION_TARGETED_ENTITY.emit(get_entity(), cell, action)
		
		for effect: ComponentActionResourceEffect in action.effects:
			
			## Each effect should assert that the parameters are present and correctly set
			match effect.type:
				
				Types.CHANGE_METER:
					assert(effect.parameters[0] is String and effect.parameters[1] is int)
					var meter_key: String = effect.parameters[0]
					var amount: int = effect.parameters[1]
	
		Event.ENTITY_COMPONENT_ACITON_USED_ON_ENTITY.emit()


## TODO
func get_targetable_cells_for_action(action: ComponentActionResource) -> Array[Vector3i]:
	Board
	return [Vector3i.ZERO]


## TODO
func get_hit_cells_by_action() -> Array[Vector3i]:
	
	return [Vector3i.ZERO]


func is_cell_targetable_by_action(cell: Vector3i, action: ComponentActionResource) -> bool:
	## The cell must have an entity if true
	if TargetingFlags.NEED_ENTITY in action.flags_targeting:
		var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
		if move_comp.get_entity_at_position_in_board(cell) == null:
			return false
			
	## The cell must be visible if true
	if TargetingFlags.NEED_VISION:
		var vision_comp: ComponentVision = get_entity().get_component(ComponentVision.COMPONENT_NAME)
		if not vision_comp.is_cell_visible(cell):
			return false
			
	return true


func is_entity_hit_by_action(entity: Entity3D, action: ComponentActionResource) -> bool:
	if action.flags_entity_hit.is_empty():
		return false
	
	#var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	#var other_entity: Entity3D = move_comp.get_entity_at_position_in_board(cell)
	var fact_comp: ComponentFaction = get_entity().get_component(ComponentFaction.COMPONENT_NAME)
	var other_fact_comp: ComponentFaction = entity.get_component(ComponentFaction.COMPONENT_NAME)
	
	if EntityHitFlags.SELF in action.flags_entity_hit:
		if entity == get_entity():
			return false
	
	if EntityHitFlags.HOSTILE in action.flags_entity_hit:
		if not fact_comp.is_faction_hostile(other_fact_comp):
			return false
	
	if EntityHitFlags.FRIENDLY in action.flags_entity_hit:
		if not fact_comp.is_faction_friendly(other_fact_comp):
			return false
	
	return true


static func get_action_resource_by_identifier(identifier: String) -> ComponentActionResource:
	if action_resource_cache_dict.is_empty():
		ComponentAction.cache_all_resources()
		
	var capability_res: ComponentActionResource = action_resource_cache_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return capability_res.duplicate(true)
