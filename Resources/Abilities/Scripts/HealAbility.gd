extends Ability
class_name AbilityHeal


func get_description():
	return "Heals for {0}% of max health of the target.".format([powers[0]])
	pass

func _use(targets:Array[Vector3i]):
	for target in targets:
		var unit:Unit = user.board.gridMap.search_in_tile(target, MovementGrid.Searches.UNIT)
		unit.attributes.stats.health += unit.attributes.stats.healthMax * powers[0]

#func use(target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
