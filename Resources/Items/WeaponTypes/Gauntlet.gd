extends WeaponEquipment
class_name WeaponEquipmentGauntlet

func _init() -> void:
	super._init()
	compatibleSlots = [Const.equipmentSlots.L_HAND, Const.equipmentSlots.R_HAND]
