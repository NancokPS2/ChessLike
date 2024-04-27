extends Node3D
class_name ComponentAction

enum ActionCategories {
	UNKNOWN, ALL, MAIN, MOVEMENT, ITEM
}

enum ActionCostType {
	SINGLE, #Action point
	BONUS, #Bonus action, one per turn
	MOVEMENT, #Movement point
}

## Affects how others react to this action
enum ActionFlags { 
	HURTS, #Causes pain animations
	HOSTILE, #Affects reactions
	FRIENDLY, #Affects reactions
	METER_MIN_ONE, #If it affects meters, the meters affected cannot go below 1
	TRACK_ENTITIES, #Skips the update of entities hit of the log when using it, keeps targeting the original entities regardless of their new positions
}
enum PassiveFlags {
	NO_INITIAL_ACTIVATION, #This won't activate on use, instead, it will activate when its repetition condition triggers, if it has no repetitions set, throw an error
	TRACK_ENTITIES, #Any entities deemed valid at the time of activation will keep being targeted on each repetition by targeting their cells	
	TARGET_CULPRIT,
}
## When the condition is fulfilled, the action will perform its effect again.
enum PassiveConditions {
	TIME_PASSED,# Turn ticks: int
	SELF_TURN_STARTED,# Turn Component: ComponentTurn
	SELF_TURN_ENDED,# Turn Component: ComponentTurn
	SUFFERED_DAMAGE,# Minimum damage: int
	CELL_TARGETED_BY_ACTION, #Flags required: Array[ComponentAction.ActionFlags]
	TARGETED_BY_ACTION,# Flags required: Array[ComponentAction.ActionFlags]
	ACTION_USED,# Flags required: Array[ComponentAction.ActionFlags]
}
## Used both to define targetable and hittable cells. By default any cell within range is valid
enum TargetingFlags {
	NEED_ENTITY, # The cell cannot be selected if it does not have a valid entity. Recommended for single target actions.
	NEED_VISION, # The action cannot go trough walls. Use Vision component.
	IGNORE_COVER, # Will not be stopped by COVER flags
}
## What entities are affected.
enum EntityHitFlags {
	SELF, # Important for DoT effects as they usually target self
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

const RESOURCE_FOLDERS: Array[String] = ["res://Scripts/Composition/Entity/Resources/ActionComponent/Actions", "user://Data/Composition/Resources/ActionComponent"]

static var action_resource_cache_dict: Dictionary

static var action_log_queue_arr: Array[ComponentActionLog]

var action_available_arr: Array[ComponentActionResource]

var action_source_dict: Dictionary

## Stores temporary data like turns passed of actions that are repeating
var action_repeating_arr: Array[ComponentActionLog]

var points_left: int = 1
var points_move_left: int = 1
var points_bonus_left: int = 1

func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	update_actions_available()
	print(get_actions_available(ActionCategories.ALL))


func get_entity() -> Entity3D:
	return get_parent()
	
	Event.ENTITY_ACTION_QUEUED_LOGS.connect(on_action_logs_queued)
	Event.ENTITY_TURN_TIME_PASSED.connect(on_turn_time_passed)
	Event.ENTITY_TURN_STARTED.connect(on_turn_started)
	Event.ENTITY_TURN_ENDED.connect(on_turn_ended)


static func cache_all_resources():
	action_resource_cache_dict.clear()
	
	for folder: String in RESOURCE_FOLDERS:
		DirAccess.make_dir_recursive_absolute(folder)
		var res_arr: Array[Resource] = Utility.LoadFuncs.get_all_resources_in_folder(folder)
	
		for res: Resource in res_arr:
			if res is ComponentActionResource:
				action_resource_cache_dict[res.identifier] = res
				
	print(action_resource_cache_dict)


func create_log_for_action(action: ComponentActionResource) -> ComponentActionLog:
	var new_log := ComponentActionLog.new()
	new_log.entity_source = get_entity()
	new_log.component_source = self
	new_log.action = action
		
	return new_log


## Adds an action log without triggering it, then awaits for it to activate on its own
func passive_action_add(action_log: ComponentActionLog):
	if action_log.passive_duration == 0:
		push_error("Cannot add this action as a passive, it has no duration.")
		return 
	if action_log.passive_condition_arguments.is_empty():
		push_error("There are no arguments for this passive's condition. It was not properly setup for being a passive.")
		return
	
	## The passive will be automatically triggered while in this array
	action_repeating_arr.append(action_log)


func passive_action_remove(action_log: ComponentActionLog):
	action_repeating_arr.erase(action_log)


## Whenever a repetition condition is triggered, check if any of the repeating actions would be triggered
func passive_action_parse_all(condition_triggered: PassiveConditions, arguments: Array = []):
	## Check every action.
	for action_log: ComponentActionLog in action_repeating_arr:
		assert(action_log.repetitions_left > 0)
		var action: ComponentActionResource = action_log.action
		
		## Skip those that do not trigger under this condition
		if not condition_triggered in action.passive_conditions:
			continue
		
		## Make a second check for conditions that need arguments
		var valid: bool = true
		match condition_triggered:
			PassiveConditions.TIME_PASSED:
				assert(arguments[0] is int)
				var time_required: int = action.passive_condition_arguments[0]
			
			PassiveConditions.SUFFERED_DAMAGE:
				assert(arguments[0] is int)
				var damage_required: int = action.passive_condition_arguments[0]
				if arguments[0] < damage_required:
					valid = false
				
			PassiveConditions.TARGETED_BY_ACTION:
				assert(arguments[0] is Array[ActionFlags])
				var flags_required: Array[ActionFlags] = action.passive_condition_arguments[0]
				for flag: ActionFlags in flags_required:
					if not arguments[0].has(flag):
						valid = false
						break
				
			PassiveConditions.ACTION_USED:
				assert(arguments[0] is Array[ActionFlags])
				var flags_required: Array[ActionFlags] = action.passive_condition_arguments[0]
				for flag: ActionFlags in flags_required:
					if not arguments[0].has(flag):
						valid = false
						break
			_:
				## If the condition does not require parameters, pass
				pass
			
		if not valid:
			continue
		
		## Set the action to execute
		action_logs_add_to_queue([action_log])
		
		## Update repeats left
		if action_log.passive_duration != -1:
			action_log.repetitions_left -= 1
		
		## If below 1, remove it.
		if action_log.repetitions_left < 1:
			passive_action_remove(action_log)


static func action_logs_add_to_queue(action_logs: Array[ComponentActionLog], index: int = -1):
	if index < 0:
		index = action_log_queue_arr.size()
	
	for log: ComponentActionLog in action_logs:
		action_log_queue_arr.insert(index, log)
		index += 1
		
	Event.ENTITY_ACTION_QUEUED_LOGS.emit(action_logs, index)


static func action_logs_insert_in_queue(new_log: ComponentActionLog, before_log: ComponentActionLog):
	var before_index: int = action_log_queue_arr.find(before_log)
	if before_index == -1:
		push_error("Could not find this log in the stack.")
		return
	ComponentAction.action_logs_add_to_queue([new_log], before_index)


func action_logs_send_queue_to_stack_component():
	var stack_obj_list: Array[ComponentStack.StackObject]
	for log: ComponentActionLog in action_log_queue_arr:
		var stack_obj := ComponentStack.create_stack_object(
			action_log_execute.bind(log),
			0,
			
		)
		stack_obj.set_metadata("log", log)
		ComponentStack.add_to_stack(stack_obj)
	action_log_queue_arr.clear()


## TODO
func action_log_execute(action_log: ComponentActionLog):
	var action_meta: Dictionary
	
	##Shortcut to log's data
	var action: ComponentActionResource = action_log.action
	var targeted_cells: Array[Vector3i] = action_log.targeted_cells
	var targeted_entities: Array[Entity3D] = action_log.targeted_entities
	
	## Get components
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var status_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	
	## Unless tracking the entities, update them
	if not ActionFlags.TRACK_ENTITIES in action.flags_action:
		action_log.targeted_entities = get_entities_hit_by_action_at_cells(action, targeted_cells)
		
	## Execute the effect	
	action.start(action_log)
	
	for cell: Vector3i in targeted_cells:
		action.affect_cell(cell)
		
	for entity: Entity3D in targeted_entities:
		action.affect_entity(entity)
	
	action.finish()
	
	print_debug(
		"Used action {0} in cells {1} with targets {2}."
		.format([action.identifier, str(targeted_cells), str(targeted_entities)])
		)


func get_action_duration() -> float:
	return 1.5

func update_actions_available():
	action_available_arr.clear()
	
	var capa_comp: ComponentCapability = get_entity().get_component(ComponentCapability.COMPONENT_NAME)
	for capa_resource: ComponentCapabilityResource in capa_comp.get_current_capability_resources(ComponentCapability.Types.ALL):
		for action_ident: StringName in capa_resource.action_identifier_arr:
			assert(action_ident != "")
			var action_res: ComponentActionResource = get_action_resource_by_identifier(action_ident)
			if action_res:
				action_available_arr.append(action_res)
				action_source_dict[action_res] = ActionCategories.MAIN
	
	
func get_actions_available(category: ActionCategories) -> Array[ComponentActionResource]:
	var output: Array[ComponentActionResource]
	
	for action: ComponentActionResource in action_available_arr:
		var action_category: ActionCategories = get_action_category(action)
		if action_category == category or action_category == ActionCategories.ALL:
			output.append(action)
			
	return action_available_arr


func get_action_category(action_res: ComponentActionResource) -> ActionCategories:
	assert(action_res in action_available_arr, "This action is not from this component.")
	var category: ActionCategories = action_source_dict.get(action_res, ActionCategories.UNKNOWN)
	
	if category == ActionCategories.ALL:
		push_error("Invalid category ALL.")
		
	return category


## The cells that can be chosen as the target location for the action TODO
func get_targetable_cells_for_action(action: ComponentActionResource) -> Array[Vector3i]:
	var cells_targetable: Array[Vector3i]
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	
	match action.shape_targeting:
		ComponentAction.TargetingShape.SINGLE:
			cells_targetable = [move_comp.get_position_in_board()]
			
		ComponentAction.TargetingShape.FLOOD:
			var origin: Vector3i = move_comp.get_position_in_board()
			cells_targetable = Board.get_cells_flood_custom(origin, action.shape_targeting_size, is_cell_valid_for_action.bind(action, false))
	
	return cells_targetable


## Which cells will be hit based on the target position TODO
func get_hit_cells_by_action(target_position: Vector3i, action: ComponentActionResource) -> Array[Vector3i]:
	var cells_targetable: Array[Vector3i]
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	
	match action.shape_targeting:
		ComponentAction.TargetingShape.SINGLE:
			cells_targetable = [target_position]
			
		ComponentAction.TargetingShape.FLOOD:
			cells_targetable = Board.get_cells_flood_custom(target_position, action.shape_targeting_size, is_cell_valid_for_action.bind(action, true))
	
	return cells_targetable
	

func get_entities_hit_by_action_at_cells(action: ComponentActionResource, target_cells: Array[Vector3i]) -> Array[Entity3D]:
	var output: Array[Entity3D] = []
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	for cell: Vector3i in target_cells:
		var entity: Entity3D = move_comp.get_entity_at_position_in_board(cell)
		if not entity:
			continue
		
		if not is_entity_hit_by_action(entity, action):
			continue
			
		output.append(entity)
	
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
			return true
	
	if EntityHitFlags.HOSTILE in action.flags_entity_hit:
		if fact_comp.is_faction_hostile(other_fact_comp):
			return true
	
	if EntityHitFlags.FRIENDLY in action.flags_entity_hit:
		if fact_comp.is_faction_friendly(other_fact_comp):
			return true
	
	return false


static func get_action_resource_by_identifier(identifier: String) -> ComponentActionResource:
	if action_resource_cache_dict.is_empty():
		ComponentAction.cache_all_resources()
	
	print(action_resource_cache_dict)
	
	var capability_res: ComponentActionResource = action_resource_cache_dict.get(identifier, null)
	if not capability_res:
		push_error("Could not find cached resource with identifier '{0}'.".format([identifier]))
	
	return capability_res.duplicate(true)


func on_action_logs_queued(action_logs: Array[ComponentActionLog]):
	var move_comp: ComponentMovement = get_entity().get_component(ComponentMovement.COMPONENT_NAME)
	var own_cell: Vector3i = move_comp.get_position_in_board()
	for log: ComponentActionLog in action_logs:
		if own_cell in log.targeted_cells:
			passive_action_parse_all(PassiveConditions.CELL_TARGETED_BY_ACTION, log.action.flags_action)
		
		if get_entity() in log.targeted_entities:
			passive_action_parse_all(PassiveConditions.TARGETED_BY_ACTION, log.action.flags_action)
		
		passive_action_parse_all(PassiveConditions.ACTION_USED, log.action.flags_action)


func on_turn_time_passed(time: float):
	passive_action_parse_all(PassiveConditions.TIME_PASSED, [time])

	
## Does not require passing arguments, it is a given that the component is from self
func on_turn_started(comp: ComponentTurn):
	if get_entity().get_component(ComponentTurn.COMPONENT_NAME) == comp:
		passive_action_parse_all(PassiveConditions.SELF_TURN_STARTED)
		
		var stat_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
		points_left = stat_comp.get_stat(ComponentStatus.StatKeys.ACTION_POINTS)
		points_move_left = stat_comp.get_stat(ComponentStatus.StatKeys.MOVE_POINTS)
		points_bonus_left = 1


## Does not require passing arguments, it is a given that the component is from self
func on_turn_ended(comp: ComponentTurn):
	if get_entity().get_component(ComponentTurn.COMPONENT_NAME) == comp:
		passive_action_parse_all(PassiveConditions.SELF_TURN_ENDED)
		points_left = 0
		points_move_left = 0
		points_bonus_left = 0

class PassiveInstance extends RefCounted:
	var activations_left: int
	var conditions: Array[PassiveConditions]
	var action_res: ComponentActionResource
	var source_comp: ComponentAction
	
	func get_log()->ComponentActionLog:
		var action_log := ComponentActionLog.new()
		action_log.entity_source = source_comp.get_entity()
		action_log.component_source = source_comp
		return action_log
	
	
	
	
