extends Node
class_name AbilitySystemUsable

enum UsabilityStatuses {
	OK,
	INSUFFICIENT_ACTIONS,
	INSUFFICIENT_MOVES,
	INSUFFICIENT_ENERGY,
	CUSTOM_FAILED
}

enum AbilityFlags {
	PASSIVE,#Ability should not be selectable during combat
	ATTACK,
	HOSTILE,#Attacks and other ill intended abilities
	FRIENDLY,#Healing and buffs or otherwise helpful abilities
	INDIRECT,#Indirect abilities should not trigger reactions that target the user
	HEALING,#Recovers health
	IS_REACTION,#To avoid infinite loops, reactions should not trigger reactions.
	AFFECT_UNITS,
	AFFECT_TILES,
#	NO_HIT_OBSTACLE,#Does not affect objects
#	NO_HIT_FRIENDLY,#Does not affect allies
#	NO_HIT_ENEMY,#Does not affect enemies
#	NO_HIT_UNIT,#No friendlies nor allies
#	ONLY_HIT_TILES,#Combine all other NO_HIT flags
}

enum AbilityTypes {MOVEMENT, OBJECT, SKILL, SPECIAL, PASSIVE}

@export_group("Identification")
@export var internalName:String = ""
@export var displayedName:String
@export var type:AbilityTypes #Where it should appear in the menus
@export_multiline var description:String:
	get = get_description

@export_group("Effects")
@export var abilityFlags:Array[AbilityFlags]
@export var effects:Array[AbilityEffect]

@export_group("Restrictions")
@export var classRestrictions:Array[String]

@export_group("Costs")
@export var energyCost:int
@export var turnDelayCost:int
@export var actionCost:int = 1
@export var moveCost:int = 0

@export_group("Targeting")
@export var targetingShape:Array[Vector3i] = TARGETING_SHAPE_STAR_ONE:
	get = get_targeting_shape #The area which the user can target
	
@export var targetingAOEShape:Array[Vector3i] = TARGETING_SHAPE_SELF #The area relative to the targeted point that it will affect
@export var targetingRotates:bool = false #If true, the targetingShape will be rotated to match the user's facing.


@export var amountOfTargets:int = 1 #How many cells the user can target (the AOE will be applied to each one separately)
@export var targetingFilterNames:Array[StringName] = ["has_unit"]:
	set(val):
		if val.all( func(method:String): return method.is_valid_identifier() ): targetingFilterNames = val
		else: push_error("Invalid filter found in the array.")
		
@export_group("Visuals")
@export var animationDuration:float

func _enter_tree() -> void:
	if not get_parent() is Unit:
		push_error("Non-unit parent!")
	
	add_to_group(AbilitySystem.COMP_ABILITY_USABLE)
