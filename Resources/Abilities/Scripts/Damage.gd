extends Ability
class_name AbilityDamage

	
func _use(targets:Array[Vector3i]):
	for target in targets:
		var unit:Unit = user.board.gridMap.search_in_tile(target, MovementGrid.Searches.UNIT)
		unit.attributes.stats.health -= 10

#func use(target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
