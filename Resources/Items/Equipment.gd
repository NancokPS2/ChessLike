extends Item
class_name Equipment



enum equipmentTypes{WEAPON,CONSUMABLE,ARMOR,ACCESSORY}
export (equipmentTypes) var equipmentType
export (Array,String) var compatibleSlots

export (Dictionary) var statBonuses = {
	"defense":0,
	"strength":0,
	"agility":0,
	"mind":0,
	"special":0,
	"healthMax":0,
	"energyMax":0
}

export (Array) var abilityList
	
func take_item(taker:Object):
	if taker.inventory == null:
		print_debug(taker.get_name() + " does not have an inventory to hold " + displayName)
	else:
		taker.inventory.add_item(self)
