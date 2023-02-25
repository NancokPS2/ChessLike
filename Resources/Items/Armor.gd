extends Equipment
class_name ArmorEquipment

func setup() -> void:
	internalName = "DummyArmor"
	equipmentType = EquipmentTypes.ARMOR
	compatibleSlots.append("ARMOR") 
	
