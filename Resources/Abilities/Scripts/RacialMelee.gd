extends Ability


func get_user_race():
	return user.attributes.raceAttributes.internalName
	pass
	
func _use(targets:Array[Vector3i]):
	for target in targeting_get_units_in_cells(targets):
#		var unit:Unit = user.board.gridMap.search_in_cell(target, MovementGrid.Searches.UNIT)
		target.attributes.stat_change("health", -10)


#func use(target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
