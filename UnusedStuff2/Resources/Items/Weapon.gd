extends Equipment
class_name EquipmentWeapon

enum WeaponTypes{OTHER, GUN, BOW, CROSSBOW, CANNON, THROW, DAGGER, SWORD, HAMMER, AXE, SPEAR, GAUNTLET, STAFF, ROD, FOCUS}

@export var weaponType:WeaponTypes
@export var twoHanded:bool
@export var damage:int
@export_range(0,32) var weaponRange:int

	
func _init():
	itemType = ItemTypes.WEAPON
	
	pass
	

