extends Equipment
class_name WeaponEquipment

enum WeaponTypes{GUN,BOW,CROSSBOW,CANNON,THROW,DAGGER,SWORD,HAMMER,AXE,SPEAR,GAUNTLET,STAFF,ROD,FOCUS}

@export var weaponType:WeaponTypes
@export var twoHanded:bool
@export var damage:int
@export_range(0,32) var weaponRange:int
@export var attackFlagList:Array = []

	
func _init():
	equipmentType = Const.equipmentTypes.WEAPON
	pass
	

