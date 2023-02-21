extends Ability

func _init():
	displayedName = "ACTION_FUCKOFF_NAME"
	internalName = "FUCKOFF"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0
	reach = 4
	targetingShape = MovementGrid.mapShapes.STAR
	abilityFlags = AbilityFlags.HOSTILE


func _use(params:Dictionary):
	var target = params["target"]
	target.change_stat("health",-target.stats.health,Const.attackFlags.IGNORE_ARMOR)
	emit_signal("ability_finalized")
	return self
