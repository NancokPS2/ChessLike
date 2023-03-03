extends Resource
class_name Ability

signal ability_finalized

var displayedName:String

var description:String

var user:Unit

var mainValue:float

var internalName:String = ""

var combatHidden:bool #Whether it should appear in the menus during combat

var triggerSignals:Dictionary #Upon equipping, the key will be used as the signal to connect from it's owner to a method with the same name as it's value
#Example: {"acted":"use"}

#@export (MovementGrid.mapShapes) var targetingShape
var targetingShape:int
var areaSize:int = 1 #Does nothing if the targetingShape does not support it, disables targeting if 0
var reach:int

var abilityFlags:int = 0
const AbilityFlags = {
	"PASSIVE":1<<16,#Ability should not be selectable during combat
	"HOSTILE":1<<1,#Attacks and other ill intended abilities
	"FRIENDLY":1<<2,#Healing and buffs or otherwise helpful abilities
	"INDIRECT":1<<3,#Indirect abilities should not trigger reactions that target the user
	"HEALING":1<<4,#Recovers health
	"NO_HIT_OBSTACLE":1<<5,#Does not affect objects
	"NO_HIT_FRIENDLY":1<<6,#Does not affect allies
	"NO_HIT_ENEMY":1<<7,#Does not affect enemies
	"NO_HIT_UNIT":1<<6 + 1<<7,#No friendlies nor allies
	"ONLY_HIT_TILES":1<<5 + 1<<6 + 1<<7,#Combine all other NO_HIT flags
	
}

#@export (Array,String) var classRestrictions #If not empty, only characters with the given class can use it
var classRestrictions:Array

var energyCost:int

var turnDelayCost:int

var abilityRange:int#Distance in tiles from the player which it can target

var miscOptions:Dictionary#Used to get extra parameters from the player
#Example: {"Head":Const.bodyParts.HEAD}

var killSwitch:bool = false

signal finalized

func equip(newUser:Node):
	user = newUser
	connect_triggers()

func connect_triggers():
	assert(user!=null)
	if user == null:#Ensure someone has equipped it
		push_error("Tried to perform this ability's setup, but no one has equipped it yet.")
		return
		
	for signa in triggerSignals:
		
		var errorCode = user.signa.connect(triggerSignals[signa])
		assert(errorCode == OK)

func filter_targets(targets:Array)->Array:
	var newTargets:Array = targets
	assert(not targets.is_empty())
	
	for target in newTargets:
		
		if abilityFlags && AbilityFlags.NO_HIT_FRIENDLY and target.get("isUnit"):
			if target.faction.internalName != user.faction.internalName:#If it is from it's faction
				newTargets.erase(target)#Remove it
				
		elif abilityFlags && AbilityFlags.NO_HIT_UNIT and target.get("isUnit"):
			if target.faction.internalName != user.faction.internalName:#If it isn't from it's faction
				newTargets.erase(target)#Remove it
		
	return newTargets
			
func is_target_ok(targets:Array)->bool:#Check if any target is valid
	var result:Array = filter_targets(targets)
	if result.size() > 0:
		return true
	else:
		return false
		
func use( params:AbilityParameters ):
	assert(params != null)

	
	#---Populating with optional parameters---
#	var yieldMenu = Ref.UITree.get_node("ActionsMenu")
#	assert(yieldMenu != null)
#	var optionSelected #Not necessarily used
#	if yieldMenu != null:
#
#		for option in miscOptions:#Populate with options
#			yieldMenu.add_option(option, miscOptions[option])
#
#		if not miscOptions.empty():
#			optionSelected = yield(yieldMenu,"button_pressed")
#	else:
#		push_error( "ActionsMenu returned class is wrong: " + yieldMenu.get_class() )
#		return
		
	#---------

	
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

	
func kill_switch_on_check():
	if killSwitch:
		killSwitch = false
		return true

class AbilityParameters extends Resource:
	var abilityFlags:int = 0
	var targetTile:Vector3i
	
	
	var optional
