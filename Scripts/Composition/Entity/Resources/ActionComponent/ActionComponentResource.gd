extends Resource
class_name ComponentActionResource



@export var identifier: String 
@export var effects: Array[ComponentActionResourceEffect]

@export var turn_cost_type: ComponentAction.ActionCostType

@export var flags_action: Array[ComponentAction.ActionFlags]
@export var flags_targeting: Array[ComponentAction.TargetingFlags]
@export var flags_hit: Array[ComponentAction.TargetingFlags]
@export var flags_entity_hit: Array[ComponentAction.EntityHitFlags]

@export var repetition_conditions: Array[ComponentAction.RepetitionConditions]
@export var repetition_arguments: Array
@export var repetition_flags: Array[ComponentAction.RepetitionActionFlags]
@export var repetition_count: int
@export var repetition_consumption_conditions: Array[ComponentAction.RepetitionConditions]

@export var shape_targeting: ComponentAction.TargetingShape
@export var shape_targeting_size: int = 1
@export var shape_hit: ComponentAction.TargetingShape
@export var shape_hit_size: int = 1



func _to_string() -> String:
	return (
		"<ComponentActionResource#{3}> | Identifier: {0} | Repetitions: {1} | \nEffects: {2}\n"
		.format([identifier, str(repetition_count), str(effects), str(get_instance_id())])
	)
