extends WeaponEquipment
class_name WeaponEquipmentDagger

func _init() -> void:
	._init()
	compatibleSlots = [Const.equipmentSlots.L_HAND, Const.equipmentSlots.R_HAND]
