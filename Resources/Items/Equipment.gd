extends Item
class_name Equipment

enum EquipSlots {ARMOR, L_HAND, R_HAND, ACC1, ACC2, ACC3} #CharAttributes.EquipSlots

@export var compatibleSlots:Array[EquipSlots]


@export var statBonuses:Dictionary = {
	"defense":0,
	"strength":0,
	"agility":0,
	"mind":0,
	"special":0,
	"healthMax":0,
	"energyMax":0
}


	



