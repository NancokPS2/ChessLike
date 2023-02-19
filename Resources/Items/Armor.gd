extends Equipment
class_name ArmorEquipment

func setup() -> void:
	internalName = "DummyArmor"
	equipmentType = Types.ARMOR
	compatibleSlots.append("ARMOR") 
	
