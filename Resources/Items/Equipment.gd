extends Item
class_name Equipment



enum EquipmentTypes{WEAPON,CONSUMABLE,ARMOR,ACCESSORY}
@export var equipmentType:EquipmentTypes
@export var compatibleSlots:Array[String]

@export var statBonuses:Dictionary = {
	"defense":0,
	"strength":0,
	"agility":0,
	"mind":0,
	"special":0,
	"healthMax":0,
	"energyMax":0
}

@export var abilityList:Array[String]
	
func take_item(taker:Object):
	if taker.inventory == null:
		print_debug(taker.get_name() + " does not have an inventory to hold " + displayName)
	else:
		taker.inventory.add_item(self)
