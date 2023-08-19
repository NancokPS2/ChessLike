extends AbilityEffect
class_name AbilityEffectTemporaryStatMod

const META_STACK_IDENT:String = "__AbilityEffectTemporaryStat_STACK_IDENT"
#const META_STACKS:String = "AbilityEffectTemporaryStat_REF_SELF"

@export_group("Attributes Temp Mod")
@export var stat:String
@export var modifier:float
@export var offset:float
@export var types:Array[String]

@export_group("Other")
@export var stackIdentifier:String
@export var maxStacks:int


func unit_effect(unit:Unit):
	var stacksPresent:int = get_stacks(unit.attributes.tempModList)
	if stacksPresent >= maxStacks: return
	
	var tempMod:AttributesBase.AttributesBaseTemporaryMod = unit.attributes.set_stat_temporary_mod(stat, offset, modifier, types)
	

func get_stacks(tempModList:Array[AttributesBase.AttributesBaseTemporaryMod])->int:
	var counter:int
	for mod in tempModList:
		if mod.get_meta(META_STACK_IDENT, "") == stackIdentifier:
			counter+=1
	return counter
	
