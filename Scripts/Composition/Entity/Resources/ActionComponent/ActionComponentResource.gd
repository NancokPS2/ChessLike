extends Resource
class_name ComponentActionResource

@export var identifier: String 

@export var effects: Array[ComponentActionResourceEffect]

@export var flags_action: Array[ComponentAction.ActionFlags]

@export var flags_targeting: Array[ComponentAction.TargetingFlags]
@export var flags_hit: Array[ComponentAction.TargetingFlags]

@export var flags_entity_hit: Array[ComponentAction.EntityHitFlags]

@export var shape_targeting: ComponentAction.TargetingShape
@export var shape_targeting_size: int = 1
@export var shape_hit: ComponentAction.TargetingShape
@export var shape_hit_size: int = 1
