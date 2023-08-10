extends Ability
class_name AbilityHeal

@export var power:float = 0.25

func get_description():
	return "Heals for {0}% of max health of the target.".format([str(power*100)])

func _use(targets:Array[Vector3i]):
	for unit in targeting_get_units_in_cells(targets):
		unit.attributes.stats.health += unit.attributes.stats.healthMax * power

#func use(target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
