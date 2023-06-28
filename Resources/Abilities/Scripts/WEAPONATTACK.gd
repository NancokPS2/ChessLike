extends Ability
class_name AbilityWeaponAttack

var weapon:EquipmentWeapon

func _use(targets:Array[Vector3i]):
	var _weapon = get_weapon()
	for target in get_units(targets):
		target.change_stat("health", -calculate_damage(target, _weapon))
	

func custom_can_use()->bool:
	return false if not (weapon is EquipmentWeapon or user.equipment["R_HAND"] or user.equipment["L_HAND"] ) else true

func get_weapon():
	if weapon is EquipmentWeapon: return weapon
	if user.equipment["R_HAND"]: return user.equipment["R_HAND"]
	else: return user.equipment["L_HAND"]

func calculate_damage(target:Unit, weapon:EquipmentWeapon)->int:
	return weapon.damage
	pass

