extends Resource
class_name ComponentActionResourceEffect

enum Types {
	CUSTOM, # Expects the functionality to be set from the script of the action resource
	METER_CHANGE, # ENT: Changes the meter of the target entity, the amount can be based on the stats of the user. If more than one stat is defined, the average is used.
	STEAL_METER, # ENT: Changes the meter of the target entity and changes the meter of the owner by the opposite amount, the amount can be based on the stats of the user. If more than one stat is defined, the average is used.
	METER_CHANGE_USE_TARGET_STAT, # ENT: Same as METER_CHANGE, but the stat alterations are drawn from the target
	LAUNCH_ENTITY, # ENT: Moves an entity in a given DIRECTION
	CELL_FLAG_CHANGE, # CELL: Changes the flag of a cell, adding it or removing it
	STAT_BONUS_ADD, # ENT: Adds a bonus to the stats of the target
	STAT_MODIFIER_ADD, # ENT: Adds a modifier to the stats of the target
	ADD_REPEATING, # ENT: Adds a repeating action to the target, useful for adding damage over times.
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
	ACTION, # ComponentActionResource: A resource to apply on the target
}
const ParamsForTypesDict: Dictionary = {
	Types.CUSTOM : [],
	Types.METER_CHANGE : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS],
	Types.STEAL_METER : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS],
	Types.METER_CHANGE_USE_TARGET_STAT : [Params.METER_NAME, Params.AMOUNT_SIGN, Params.AMOUNT, Params.STAT_KEYS_TARGET],
	Types.LAUNCH_ENTITY : [Params.DIRECTION],
	Types.CELL_FLAG_CHANGE : [Params.CELL_FLAGS, Params.BOOLEAN, Params.TIME_DURATION],
	Types.STAT_BONUS_ADD : [Params.METER_NAME, Params.AMOUNT, Params.TIME_DURATION],
	Types.STAT_MODIFIER_ADD : [Params.METER_NAME, Params.AMOUNT_F, Params.TIME_DURATION],
	Types.ADD_REPEATING : [Params.ACTION, Params.AMOUNT]
}

@export var identifier: String

var action_log_cache: ComponentActionEffectLog

func start(action_log: ComponentActionEffectLog):
	assert(not action_log_cache)
	action_log_cache = action_log
	
	_start(action_log)

func _start(_action_log: ComponentActionEffectLog):
	pass


func affect_cell(cell: Vector3i):
	_affect_cell(cell)

func _affect_cell(_cell: Vector3i):
	pass


func affect_entity(entity: Entity3D):
	if not entity:
		return
		
	## Confirm if the entity is valid
	if not action_log_cache.component_source.is_entity_hit_by_action(entity, action_log_cache.action):
		return
	
	_affect_entity(entity)
	
func _affect_entity(_entity: Entity3D):
	pass


func finish():
	action_log_cache = null


func _finish():
	pass

