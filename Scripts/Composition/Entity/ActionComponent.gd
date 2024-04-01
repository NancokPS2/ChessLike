extends Node3D
class_name ComponentAction

## ENT: Affects entities
## CELL: Affects cells
enum EffectTypes {
	CUSTOM, # Expects the functionality to be set from the script of the action resource
	METER_CHANGE, # ENT: Changes the meter of the target entity, the amount can be based on the stats of the user. If more than one stat is defined, the average is used.
	STEAL_METER, # ENT: Changes the meter of the target entity and changes the meter of the owner by the opposite amount, the amount can be based on the stats of the user. If more than one stat is defined, the average is used.
	METER_CHANGE_USE_TARGET_STAT, # ENT: Same as METER_CHANGE, but the stat alterations are drawn from the target
	LAUNCH_ENTITY, # ENT: Moves an entity in a given DIRECTION
	CELL_FLAG_CHANGE, # CELL: Changes the flag of a cell, adding it or removing it
	STAT_BONUS_ADD, # ENT: Adds a bonus to the stats of the target
	STAT_MODIFIER_ADD, # ENT: Adds a modifier to the stats of the target
}
enum Params {
	DIRECTION, # Vector3i: Defaults to the direction from the entity to the targeted cell
	METER_NAME, # String: From ComponentStatus
	AMOUNT, # int: A simple numeric value
	AMOUNT_F, # float: A simple numeric value, as a float
	AMOUNT_SIGN, # int: The sign of the number provided is used to change the amount
	STAT_KEYS, # Array[ComponentStatus.StatKeys]: Modifies an AMOUNT by the given stats, additively
	STAT_KEYS_TARGET, #  Array[ComponentStatus.StatKeys]: Modifies an AMOUNT by the given stats of the target, additively
	TIME_DURATION, # int: Used to define how long an effect may last
	CELL_FLAGS, # Array[Board.CellFlags]: Which flags of a cell to affect
	BOOLEAN, # bool: A simply true or false
	
}
const ParamsForTypesDict: Dictionary = {
	EffectTypes.CUSTOM : [],
	EffectTypes.METER_CHANGE : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS],
	EffectTypes.STEAL_METER : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS],
	EffectTypes.METER_CHANGE_USE_TARGET_STAT : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS_TARGET],
	EffectTypes.LAUNCH_ENTITY : [Params.DIRECTION],
	EffectTypes.CELL_FLAG_CHANGE : [Params.CELL_FLAGS, Params.BOOLEAN, Params.TIME_DURATION],
}
## Affects how others react to this action
enum ActionFlags { 
	HURTS, #Causes pain animations
	HOSTILE, #Affects reactions
	FRIENDLY, #Affects reactions
	METER_MIN_ONE, #If it affects meters, the meters affected cannot go below 1
}
## Used both to define targetable and hittable cells. By default any cell within range is valid
enum TargetingFlags {
	NEED_ENTITY, # The cell cannot be selected if it does not have a valid entity. Recommended for single target actions.
	NEED_VISION, # The action cannot go trough walls. Use Vision component.
	IGNORE_COVER, # Will not be stopped by COVER flags
}
## What entities are affected.
enum EntityHitFlags {
	SELF,
	HOSTILE,
	FRIENDLY,
}
## The shape to use.
enum TargetingShape {
	SINGLE,
	FLOOD,
}
## Action flag examples:
########################
## Fire projectile
## ActionFlags: HURTS, HOSTILE
## TargetingFlags: NEED_VISION
## EntityHitFlags: HOSTILE, FRIENDLY
## TargetingShape: SINGLE
########################
## Steal health
## ActionFlags: HURTS, HOSTILE
## TargetingFlags: NEED_ENTITY
## EntityHitFlags: HOSTILE, FRIENDLY
## TargetingShape: SINGLE
########################
## Area heal
## ActionFlags: FRIENDLY
## TargetingFlags: IGNORE_COVER
## EntityHitFlags: SELF, HOSTILE, FRIENDLY
## TargetingShape: FLOOD
########################

const COMPONENT_NAME: StringName = "ENTITY_ACTION"

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Entity/Resources/ActionComponent", "user://Data/Composition/Resources/ActionComponent"]

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
	var action_meta: Dictionary
	
	## Get components
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var status_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	
	Event.ENTITY_COMPONENT_ACTION_TARGETED_CELL.emit(get_entity(), target_cells, action)
	
	## Select the cell to execute the effects on
	for cell: Vector3i in target_cells:	
		var entity_here: Entity3D = move_comp.get_entity_at_position_in_board(cell)
		
		## Execute the effect
		for effect: ComponentActionResourceEffect in action.effects:
			#var parameter_dict: Dictionary = get_parameter_dict_for_effect(effect)
			match effect.type:
			## Each effect should assert that the parameters are present and correctly set
				
				EffectTypes.METER_CHANGE:
					if not entity_here:
						push_warning("This effect cannot execute because it requires an entity and this cell doesn't have any.")
						continue
						
					assert(
						effect.parameters[0] is String and
						effect.parameters[1] is int and 
						effect.parameters[2] is int and 
						effect.parameters[3] is ComponentStatus.StatKeys
					)
					var meter_key: String = effect.parameters[0]
					var amount_sign: int = signi(effect.parameters[1])
					var base_amount: int = effect.parameters[2]
					var stat_key: ComponentStatus.StatKeys = effect.parameters[3]
					
					var stat_bonus: int = status_comp.get_stat(stat_key)
					var status_comp_target: ComponentStatus = entity_here.get_component(ComponentStatus.COMPONENT_NAME)
					
					status_comp_target.change_meter(ComponentStatus.MeterKeys.HEALTH, absi(base_amount + stat_bonus) * amount_sign)
	
	print_debug(
		"Used action {0} in cells {1}."
		.format([action.identifier, str(target_cells)])
		)
	Event.ENTITY_COMPONENT_ACTION_USED_ON_CELL.emit(get_entity(), target_cells, action)


## The cells that can be chosen as the target location for the action TODO
func get_targetable_cells_for_action(action: ComponentActionResource) -> Array[Vector3i]:
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var origin: Vector3i = move_comp.get_position_in_board()
	var cells_targetable: Array[Vector3i] = Board.get_cells_flood_custom(origin, action.shape_targeting_size, is_cell_valid_for_action.bind(action, false))
	
	return cells_targetable


## Which cells will be hit based on the target position TODO
func get_hit_cells_by_action(target_position: Vector3i, action: ComponentActionResource) -> Array[Vector3i]:
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var origin: Vector3i = move_comp.get_position_in_board()
	var cells_targetable: Array[Vector3i] = Board.get_cells_flood_custom(origin, action.shape_targeting_size, is_cell_valid_for_action.bind(action, true))
	
	return cells_targetable


## Get every parameter stored in the effect as a Dictionary. 
## Params : Variant
func get_parameter_dict_for_effect(effect: ComponentActionResourceEffect) -> Dictionary:
	var output: Dictionary = {}
	var parameter_keys_expected: Array[Params] = ParamsForTypesDict[effect.type]
	
	## Ensure it has enough parameters
	if not effect.parameters.size() == parameter_keys_expected.size():
		push_error("Not enough parameters on this effect. Expected: " + str(parameter_keys_expected))	
		return {}
		
	var index: int = 0
	for param_key: Params in parameter_keys_expected:

		output[param_key] = effect.parameters[index]
		
		index += 1
	return output
	
	
## Includes both hit and targetable flags from action based on [use_hit_flags].
func is_cell_valid_for_action(cell: Vector3i, action: ComponentActionResource, use_hit_flags: bool) -> bool:
	## Select which kind of flags to use
	var flags_used: Array[TargetingFlags] = []
	if use_hit_flags:
		flags_used = action.flags_hit
	else:
		flags_used = action.flags_targeting
	
	## Unless it ignores cover, check for it
	if not TargetingFlags.IGNORE_COVER in flags_used:
		if Board.is_flag_in_cell(cell, Board.CellFlags.COVER):
			return false
		
	## The cell must have an entity to be selectable
	if TargetingFlags.NEED_ENTITY in flags_used:
		var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
		if move_comp.get_entity_at_position_in_board(cell) == null:
			return false
		
	## The cell must be visible to be selectable
	if TargetingFlags.NEED_VISION in flags_used:
		var vision_comp: ComponentVision = get_entity().get_component(ComponentVision.COMPONENT_NAME)
		if not vision_comp.is_cell_visible(cell):
			return false
			
	return true


## Returns if the given entity can be affected by the action
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
	
	print(action_resource_cache_dict)
	
	var capability_res: ComponentActionResource = action_resource_cache_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return capability_res.duplicate(true)
