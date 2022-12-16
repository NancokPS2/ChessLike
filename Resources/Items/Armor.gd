extends Equipment
class_name ArmorEquipment

func setup() -> void:
	internalName = "DummyArmor"
	equipmentType = equipmentTypes.ARMOR
	compatibleSlots.append("ARMOR") 
	
