extends Ability


func _init():
	displayedName = "PASSIVE_EXPENSIVE"
	internalName = "EXPENSIVE"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 9999
	abilityFlags = AbilityFlags.PASSIVE

func _use(parameters:Dictionary):
	print("I'm rich bitch")
	emit_signal("ability_finalized")
	return self

