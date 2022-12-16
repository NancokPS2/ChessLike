extends Resource
class_name Ability

signal ability_finalized

var displayedName

var user:Node

export (String) var internalName = ""

export (bool) var combatHidden #Whether it should appear in the menus during combat

export (Dictionary) var triggerSignals #Upon equipping, the key will be used as the signal to connect from it's owner to a method with the same name as it's value
#Example: {"acted":"use"}

export (MovementGrid.mapShapes) var targetingShape
export (int) var areaSize = 1 #Does nothing if the targetingShape does not support it

export (int) var abilityFlags = 0
const AbilityFlags = {
	"PASSIVE":1<<0,#Ability should not be selectable during combat
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

export (Array,String) var classRestrictions #If not empty, only characters with the given class can use it

export (int) var parametersReq = 0
const ParametersReq = {
	"TARGET_UNIT":1<<0,
	"USED_WEAPON":1<<1
}

export (int) var energyCost

export (int) var turnDelayCost

export (int) var abilityRange#Distance in tiles from the player which it can target


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
	
func use(params):
	_use(params)
	pass
	
func _use(params):
	pass

