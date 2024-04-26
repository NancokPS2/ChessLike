extends ComponentActionResource

@export var meter_affected: String = "HEALTH"
@export var base_amount: int
@export var stat_bonuses: Array[ComponentStatus.StatKeys]
@export_range(-1,1,2) var stat_bonuses_sign: int = 1
@export var stat_bonuses_multiplier: float = 1

@export var target_stat_bonuses: Array[ComponentStatus.StatKeys]
@export_range(-1,1,2) var target_stat_bonuses_sign: int = 1
@export var target_stat_bonuses_multiplier: float = 1

func _affect_entity(entity: Entity3D):
	## Get stat bonus
	var comp_stat: ComponentStatus = action_log_cache.entity_source.get_component(ComponentStatus.COMPONENT_NAME)
	var stat_bonus: int
	for key: ComponentStatus.StatKeys in stat_bonuses:
		stat_bonus += comp_stat.get_stat(key)
	stat_bonus *= stat_bonuses_sign
	stat_bonus *= stat_bonuses_multiplier
	
	#Get other's stat bonus
	var comp_stat_other: ComponentStatus = entity.get_component(ComponentStatus.COMPONENT_NAME)
	var stat_bonus_other: int
	for key: ComponentStatus.StatKeys in target_stat_bonuses:
		stat_bonus_other += comp_stat_other.get_stat(key)
	stat_bonus_other *= stat_bonuses_sign
	stat_bonus_other *= target_stat_bonuses_multiplier
	
	## Get the status component of the target
	var comp_stat_target: ComponentStatus = action_log_cache.entity_source.get_component(ComponentStatus.COMPONENT_NAME)
	
	var final_change: int = base_amount + stat_bonus + stat_bonus_other
	
	## Apply the effect
	comp_stat_target.change_meter(meter_affected, final_change)
