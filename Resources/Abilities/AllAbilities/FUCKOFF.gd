extends Ability

func _init():
	displayedName = "ACTION_FUCKOFF_NAME"
	internalName = "FUCKOFF"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0
	abilityFlags += AbilityFlags.HOSTILE
	parametersReq += ParametersReq.TARGET_UNIT


func _use(params:Dictionary):
	var target = params["target"]
	target.change_stat("health",-target.stats.health)
	emit_signal("ability_finalized")
	return self
