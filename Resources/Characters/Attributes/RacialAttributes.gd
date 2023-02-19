extends AttributesBase
class_name RacialAttributes

#Info
@export var description:String
@export var spriteFolder:String = "res://Assets/Units/characters/human/"
@export var sexWeight:Dictionary = {
	"Male":1,
	"Female":1,
	"Other":1,
	"Unknown":1
}


#Abilities
@export var abilityList:Array = ["WEAPONATTACK"]
