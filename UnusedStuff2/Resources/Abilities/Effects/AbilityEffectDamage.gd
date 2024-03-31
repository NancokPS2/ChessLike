extends AbilityEffect
class_name AbilityEffectDamage

@export var damageAmount:float

func unit_effect(unit:Unit):
	unit.attributes.change_stat(AttributesBase.StatNames.HEALTH, -damageAmount)
