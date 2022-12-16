extends Equipment
class_name WeaponEquipment

enum WeaponTypes{GUN,BOW,CROSSBOW,CANNON,THROW,DAGGER,SWORD,HAMMER,AXE,SPEAR,GAUNTLET,STAFF,ROD,FOCUS}

export (WeaponTypes) var weaponType
export (bool)var twoHanded
export (int,9999) var damage
export (int,32) var weaponRange
export (Array) var attackFlagList = []

	
func _init():
	equipmentType = Const.equipmentTypes.WEAPON
	pass
	

