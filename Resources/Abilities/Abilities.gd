extends Resource
class_name Ability

signal ability_finalized

var displayedName:String

var description:String

var user:Node

var internalName:String = ""

var combatHidden:bool #Whether it should appear in the menus during combat

var triggerSignals:Dictionary #Upon equipping, the key will be used as the signal to connect from it's owner to a method with the same name as it's value
#Example: {"acted":"use"}

#export (MovementGrid.mapShapes) var targetingShape
var targetingShape:int
var areaSize:int = 1 #Does nothing if the targetingShape does not support it, disables targeting if 0

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
	"NO_TILE_WITH_OBJECT":1<<8,#Does not target tiles with objects
	"NO_TILE_WITH_UNIT":1<<9,#Does not target tiles with units
	"TARGET_TILES":1<<10,#This ability targets tiles instead of Units or objects
}

#export (Array,String) var classRestrictions #If not empty, only characters with the given class can use it
var classRestrictions:Array

var parametersReq:int = 0
const ParametersReq = {
	"TARGET_UNIT":1<<0,
	"USED_WEAPON":1<<1
}

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
		
		var errorCode = user.connect(signa,self,triggerSignals[signa])
		assert(errorCode == OK, str(errorCode))
		
func use( params={} ):
	Events.emit_signal("COMBAT_ACTING_abilitychosen",self)
	
	if not params.has("flags"):#Ensure they exist
		params["flags"] = 0
	
	#---Populating with optional parameters---
	var yieldMenu = Ref.UITree.get_node("ActionsMenu")
	assert(yieldMenu != null)
	var optionSelected #Not necessarily used
	if yieldMenu != null:
		
		for option in miscOptions:#Populate with options
			yieldMenu.add_option(option, miscOptions[option])
		
		if not miscOptions.empty():
			optionSelected = yield(yieldMenu,"button_pressed")
		
	else:
		push_error( "ActionsMenu returned class is wrong: " + yieldMenu.get_class() )
		return
		
	params["optionSelected"] = optionSelected
	#---------

	
	_use(params)
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
