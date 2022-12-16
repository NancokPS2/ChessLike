extends Ability

func _init():
	displayedName = "ACTION_FUCKOFF_NAME"
	internalName = "FUCKOFF"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0

func _ready():
	abilityFlags.append(AbilityFlags.HOSTILE)
	parametersReq += ParametersReq.TARGET_UNIT

func _use(parameters:Dictionary):
	parameters[ParametersReq.TARGET_UNIT].stats.health = 0
	emit_signal("ability_finalized")
	return self
