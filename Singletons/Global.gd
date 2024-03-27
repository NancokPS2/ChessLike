extends Node


#Constants
enum EntityBodyParts {HEAD,TORSO,
UPP_ARM_R,UPP_ARM_L,
LOW_ARM_R,LOW_ARM_L,
HAND_R,HAND_L,
UPP_LEG_R,UPP_LEG_L,
LOW_LEG_R,LOW_LEG_L,
FOOT_R,FOOT_L}


enum EntityEquipmentSlots {
	ARMOR,
	L_HAND,
	R_HAND, 
	ACC1, 
	ACC2, 
	ACC3
	}

#enum equipmentTypes{WEAPON,CONSUMABLE,ARMOR,ACCESSORY}

enum EntityMovementTypes{IGNORE,WALK,FLY,TELEPORT} #IGNORE is only meant to be used by races and classes, it will prevent them from overriding movement

enum AbilityTypes{ATTACK,HEAL,DEBUFF,BUFF,INNATE,ENERGY_USE,ACTIVE}

enum AbilityParameters{TARGET_UNIT,TARGET_CONE,CHOOSE_WEAPON}

enum AbilityAttackFlags{HALF_ARMOR,IGNORE_ARMOR,WEAK_VS_ARMOR,CANNOT_COUNTER,FALL_OFF}


enum areaShapes{STAR,CONE,LINE,CROSS}

enum genders{MALE,FEMALE,OTHER,UNKNOWN}

enum races{HUMAN,POXT,VIVISTAR,MANTADA}

const ObjectGroups:Dictionary = {
	UNIT="UNIT",
	OBSTACLES="OBSTACLES",
}

#Directories
const dirSaves = "user://GameData/Saves/"

const dirMaps = "res://GameData/Maps/"

const dirChars = "res://Resources/Characters/UniqueCharacters/"


#Balance
#balanceAttackDelayCost = 20


