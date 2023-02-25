extends WeaponEquipment
class_name WeaponEquipmentGun


func _init() -> void:
	super._init()
	attackFlagList = [Const.attackFlags.FALL_OFF]
	compatibleSlots = [Const.equipmentSlots.L_HAND, Const.equipmentSlots.R_HAND]
