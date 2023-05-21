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
	ATTACK,
	HOSTILE,#Attacks and other ill intended abilities
	FRIENDLY,#Healing and buffs or otherwise helpful abilities
	INDIRECT,#Indirect abilities should not trigger reactions that target the user
	HEALING,#Recovers health
#	NO_HIT_OBSTACLE,#Does not affect objects
#	NO_HIT_FRIENDLY,#Does not affect allies
#	NO_HIT_ENEMY,#Does not affect enemies
#	NO_HIT_UNIT,#No friendlies nor allies
#	ONLY_HIT_TILES,#Combine all other NO_HIT flags
}

enum AbilityTypes {MOVEMENT, OBJECT, SKILL, SPECIAL, PASSIVE}

enum TargetingShapes {ANY, STAR, CONE, ALL}

var user:Unit:
	set(val):
		if user is Unit:
			Utility.SignalFuncs.disconnect_signals_from(self, user)
			board = user.board
			user = val
			connect_triggers()
		else: user = val

## Set alongside it's unit
var board:GameBoard

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
@export var targetingShape:TargetingShapes
@export var areaSize:int = 1 #Does nothing if the targetingShape does not support it
@export var abilityRange:int#Distance in tiles from the player which it can target
@export var amountOfTargets:int = 1
@export var filtersUsed:Array[String]= ["has_unit"]:
	set(val):
		if filters.all( func(method): return method.is_valid() ): filtersUsed = val
		elif not val is Array[String]: push_error("Invalid array")
		else: push_error("Invalid filter found in the array.")
		
var filters:Array[Callable]:
	get:
		#If the size does not match, update it.
		if filters.size() != filtersUsed.size():
			for filter in filtersUsed:
				filters.append(Callable(Filters,filter).bind(user))
		return filters


#func equip(newUser:Node):


func connect_triggers():
	if not user is Unit:#Ensure someone has equipped it
		push_error("Tried to perform this ability's setup, but no one has equipped it yet."); return
		
	for signa in triggerSignals:
		var methodName:String = triggerSignals[signa]
		var errorCode = connect(signa, Callable(self, methodName))
		assert(errorCode == OK)

func filter_targetable_cells(cells:Array[Vector3i], shape:TargetingShapes=targetingShape)->Array[Vector3i]:
	var userCell:Vector3i = user.get_current_cell()
	var filteredCells:Array[Vector3i] = []
	match shape:
		TargetingShapes.STAR:
			for cell in cells:
				var manhattanDistance:int = abs(userCell.x - cell.x) + abs(userCell.y - cell.y) + abs(userCell.z - cell.z)
				if manhattanDistance <= abilityRange: filteredCells.append(cell)
		
		TargetingShapes.ALL:
			filteredCells = cells
		_:
			push_error("Invalid shape")
	if filteredCells.is_empty(): push_error("No targets could be returned!")
	return filteredCells

func filter_targets(targets:Array[Vector3i])->Array:
	assert(not targets.is_empty())
	var newTargets:Array = targets.duplicate()
	
	
	
	for filter in filters:
		newTargets = newTargets.filter(filter)
		
	return newTargets
			
func are_targets_ok(targets:Array)->bool:#Check if any target is valid
	var result:Array = filter_targets(targets)
	if result.size() > 0:
		return true
	else:
		return false
		
func get_tween(targets:Array[Vector3i])->Tween:
	#Filter any unwanted targets.
	targets = filter_targets(targets)
	warn_units(targets)
	
	#Create a tween for each attack
	var tween:Tween = user.create_tween()
	tween.tween_callback(use.bind(targets)).set_delay(0.2)
	return tween
	
## Checks for units in the cells and warns them of an upcoming attack.
func warn_units(targets:Array[Vector3i]):
	var units:Array[Unit] = board.gridMap.get_all_in_cells(targets, MovementGrid.Searches.UNIT)
	for unit in units: unit.emit_signal("was_targeted",self)
	
	
func use( targets:Array[Vector3i] ):
	user.stats.turnDelay += turnDelayCost
	targets = filter_targets(targets)
	for target in targets:
		var possibleUnit:Unit = board.gridMap.search_in_tile(target, MovementGrid.Searches.UNIT)
		if possibleUnit is Unit:
			possibleUnit.emit_signal("was_targeted",self)
			
	
	_use(targets)
	Events.emit_signal("UPDATE_UNIT_INFO")
	pass
	
func _use(target:Array[Vector3i]):
	print( user.info.nickName + " cannot punch. Because testing.")
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



const FilterNames:Dictionary = {HAS_UNIT = "has_unit", NOT_HAS_UNIT = "not_has_unit"} 
class Filters extends RefCounted:
	
	#True if there's a unit there
	static func has_unit(cell:Vector3i, user:Unit): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else false
	#True if there's not a unit
	static func not_has_unit(cell:Vector3i, user:Unit): return false if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else true
	#True if the tile has nothing in it
	static func empty_tile(cell:Vector3i, user:Unit): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.ANYTHING) == null else false
	
	static func is_ally(cell:Vector3i, user:Unit): 
		var targetUnit:Unit = Ref.grid.search_int_tile(cell, MovementGrid.Searches.UNIT)
		if targetUnit is Unit and user.attributes.faction.is_friendly_with(targetUnit.attributes.faction):
			return true
		elif not targetUnit is Unit: 
			push_error("There is no unit here! has_unit should have been called first!")
			return false
		else:
			return false
