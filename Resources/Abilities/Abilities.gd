extends Resource
class_name Ability

signal ability_finalized
#const AbilityFlags = {
#	"PASSIVE":1<<16,#Ability should not be selectable during combat
#	"HOSTILE":1<<1,#Attacks and other ill intended abilities
#	"FRIENDLY":1<<2,#Healing and buffs or otherwise helpful abilities
#	"INDIRECT":1<<3,#Indirect abilities should not trigger reactions that target the user
#	"HEALING":1<<4,#Recovers health
#	"NO_HIT_OBSTACLE":1<<5,#Does not affect objects
#	"NO_HIT_FRIENDLY":1<<6,#Does not affect allies
#	"NO_HIT_ENEMY":1<<7,#Does not affect enemies
#	"NO_HIT_UNIT":1<<6 + 1<<7,#No friendlies nor allies
#	"ONLY_HIT_TILES":1<<5 + 1<<6 + 1<<7,#Combine all other NO_HIT flags
#
#}

enum AbilityFlags {
	PASSIVE,#Ability should not be selectable during combat
	HOSTILE,#Attacks and other ill intended abilities
	FRIENDLY,#Healing and buffs or otherwise helpful abilities
	INDIRECT,#Indirect abilities should not trigger reactions that target the user
	HEALING,#Recovers health
	NO_HIT_OBSTACLE,#Does not affect objects
	NO_HIT_FRIENDLY,#Does not affect allies
	NO_HIT_ENEMY,#Does not affect enemies
	NO_HIT_UNIT,#No friendlies nor allies
	ONLY_HIT_TILES,#Combine all other NO_HIT flags
}

enum AbilityTypes {MOVEMENT, OBJECT, SKILL, SPECIAL, PASSIVE}

var user:Unit:
	set(val):
		if user is Unit:
			Utility.SignalFuncs.disconnect_signals_from(self, user)
			user = val
			connect_triggers()
		else: user = val

var board:GameBoard = Ref.gameBoard

#@export var mainValue:float
@export_group("Identification")
@export var internalName:String = ""
@export var displayedName:String
@export var type:AbilityTypes #Where it should appear in the menus
@export_multiline var description:String
#@export (MovementGrid.mapShapes) var targetingShape

var miscOptions:Dictionary#Used to get extra parameters from the player
#Example: {"Head":Const.bodyParts.HEAD}

#@export (Array,String) var classRestrictions #If not empty, only characters with the given class can use it


@export_group("Main values")
@export var energyCost:int
@export var turnDelayCost:int
@export var classRestrictions:Array
@export var triggerSignals:Dictionary #user.signal:self.method()
#Example: {"acted":"use"}
@export var abilityFlags:Array[AbilityFlags]

@export_group("Targeting")
@export var targetingShape:int
@export var areaSize:int = 1 #Does nothing if the targetingShape does not support it, disables targeting if 0
@export var reach:int
@export var abilityRange:int#Distance in tiles from the player which it can target



signal finalized

#func equip(newUser:Node):


func connect_triggers():
	if user == null:#Ensure someone has equipped it
		push_error("Tried to perform this ability's setup, but no one has equipped it yet.")
		return
		
	for signa in triggerSignals:
		var methodName:String = triggerSignals[signa]
		var errorCode = connect(signa, Callable(self, methodName))
		assert(errorCode == OK)

func filter_targets(targets:Array[Vector3i])->Array:
	assert(not targets.is_empty())
	var newTargets:Array = targets
	
#	for target in newTargets:
#		if abilityFlags.has(AbilityFlags.NO_HIT_FRIENDLY):
		
#		if abilityFlags && AbilityFlags.NO_HIT_FRIENDLY and target.get("isUnit"):
#			if target.faction.internalName != user.faction.internalName:#If it is from it's faction
#				newTargets.erase(target)#Remove it
#
#		elif abilityFlags && AbilityFlags.NO_HIT_UNIT and target.get("isUnit"):
#			if target.faction.internalName != user.faction.internalName:#If it isn't from it's faction
#				newTargets.erase(target)#Remove it
		
	return newTargets
			
func is_target_ok(targets:Array)->bool:#Check if any target is valid
	var result:Array = filter_targets(targets)
	if result.size() > 0:
		return true
	else:
		return false
		
func use( params:Dictionary ):
	assert(params != null)
	user.stats.turnDelay += turnDelayCost


	
	_use(params)
	Events.emit_signal("UPDATE_UNIT_INFO")
	pass
	
func _use(params):
	print( user.info.nickName + " does jack shit!")
	pass
	
enum AvailabilityStatus {OK,CUSTOM_FALSE,NOT_ENOUGH_ENERGY,OTHER}
func check_availability() -> int:  
	var errorCode:int = 0
	if _check_availability() == false:  
		errorCode += AvailabilityStatus.CUSTOM_FALSE
		
	if user.stats["energy"] < energyCost:
		errorCode += AvailabilityStatus.NOT_ENOUGH_ENERGY
		
	return errorCode

func _check_availability() -> bool:#Virtual function, prevents usage if false
	return true

