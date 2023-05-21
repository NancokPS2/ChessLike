extends Ability

func _init():
	displayedName = "PASSIVE_REGENERATION_NAME"
	internalName = "REGENERATION"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0
	mainValue = 0.1
	triggerSignals = {"turn_started":"use"}
	abilityFlags += AbilityFlags.FRIENDLY + AbilityFlags.HEALING + AbilityFlags.PASSIVE
	
func _use(params):
	user.change_stat("health", user.stats["healthMax"]*mainValue)
	emit_signal("ability_finalized")

#func use(target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())