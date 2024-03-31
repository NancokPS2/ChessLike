extends AbilityEffect
class_name AbilityEffectHeal

@export var healAmount:float

func unit_effect(unit:Unit):
	unit.attributes.change_stat(AttributesBase.StatNames.HEALTH, healAmount)
