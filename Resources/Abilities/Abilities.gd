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
var board:GameBoard:
	get: 
		if user is Unit and user.board is GameBoard:
			return user.get("board")
		else:
			push_error(str(user)+ " may not be a Unit or lack a board.")
			return null

#@export var mainValue:float
@export_group("Identification")
@export var internalName:String = ""
@export var displayedName:String
@export var type:AbilityTypes #Where it should appear in the menus
@export_multiline var description:String:
	get = get_description
#@export (MovementGrid.mapShapes) var targetingShape

var miscOptions:Dictionary#Used to get extra parameters from the player
#Example: {"Head":Const.bodyParts.HEAD}

#@export (Array,String) var classRestrictions #If not empty, only characters with the given class can use it


@export_group("Main values")
@export var customVals:Dictionary = {"power":1.0, "duration":1 as int}
@export var energyCost:int
@export var turnDelayCost:int
@export var classRestrictions:Array[String]
@export var triggerSignals:Dictionary #user.signal:self.method()
#Example: {"acted":"use"}
@export var abilityFlags:Array[AbilityFlags]
@export var actionCost:int = 1
@export var moveCost:int = 0

@export_group("Targeting")
@export var targetingShape:TargetingShapes
@export var areaSize:int = 1 #Does nothing if the targetingShape does not support it
@export var abilityRange:int#Distance in tiles from the player which it can target
@export var amountOfTargets:int = 1
@export var filtersUsed:Array[String]:
	set(val):
		assert(not val.is_empty())
		if val.all( func(method:String): return method.is_valid_identifier() ): filtersUsed = val
		elif not val is Array[String]: push_error("Invalid array.")
		else: push_error("Invalid filter found in the array.")
		
var filters:Array[Callable]:
	get:
		for filter in filtersUsed:
			filters.append(Callable(Filters,filter).bind(user))
		return filters


#func equip(newUser:Node):
func get_description():
	return description

func is_usable()->bool:
	var stats = user.attributes.stats
	
	if stats.actions < actionCost: return false
	elif stats.moves < moveCost: return false
	elif not custom_can_use():  return false
	
	return true
	pass

func get_units(cells:Array[Vector3i])->Array[Unit]:
	var targets:Array[Unit] 
	for cell in cells:
		targets.assign(user.board.gridMap.search_in_tile(cell, MovementGrid.Searches.UNIT, true))
	return targets

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
	print_debug("First pass yielded: "+str(filteredCells))
	filteredCells = filter_targets(filteredCells)
	print_debug("Second pass yielded: "+str(filteredCells))
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
	tween.pause()
	return tween

	
## Checks for units in the cells and warns them of an upcoming attack.
func warn_units(targets:Array[Vector3i]):
	var units:Array[Unit]
	
	for target in targets:
		units.assign(board.gridMap.search_in_tile(target, MovementGrid.Searches.UNIT, true))
		
	for unit in units: unit.was_targeted.emit(self)
	
	
func use( targets:Array[Vector3i] ):	
	user.attributes.stats.moves -= moveCost
	user.attributes.stats.actions -= actionCost
	user.attributes.stats.turnDelay += turnDelayCost
	
	targets = filter_targets(targets)
	#The warning happens in get_tween(), no need for this.
#	for target in targets:
#		var possibleUnit:Unit = board.gridMap.search_in_tile(target, MovementGrid.Searches.UNIT)
#		if possibleUnit is Unit:
#			possibleUnit.was_targeted.emit(self)
			
	
	
	_use(targets)
	Events.UPDATE_UNIT_INFO.emit()
	Events.ABILITY_USED.emit(self)
	
func _use(target:Array[Vector3i]):
	print( user.info.nickName + " cannot punch. Because testing.")
	pass


func custom_can_use() -> bool:#Virtual function, prevents usage if false
	return true




#const FilterNames:Dictionary = {HAS_UNIT = "has_unit", NOT_HAS_UNIT = "not_has_unit"} 
class Filters extends RefCounted:
	
	#True if there's a unit there
	static func has_unit(cell:Vector3i, _user:Unit): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else false
	#True if there's not a unit
	static func not_has_unit(cell:Vector3i, _user:Unit): return false if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT) is Unit else true
	#True if the tile has nothing in it
	static func empty_tile(cell:Vector3i, _user:Unit): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.ANYTHING) == null else false
	
	static func is_ally(cell:Vector3i, user:Unit): 
		var targetUnit:Unit = Ref.grid.search_int_tile(cell, MovementGrid.Searches.UNIT)
		if targetUnit is Unit and user.attributes.faction.is_friendly_with(targetUnit.attributes.faction):
			return true
		elif not targetUnit is Unit: 
			push_error("There is no unit here! has_unit should have been called first!")
			return false
		else:
			return false
	
	static func has_self(cell:Vector3i, user:Unit): return true if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT,true).has(user) else false
	
	static func not_has_self(cell:Vector3i, user:Unit): return false if Ref.grid.search_in_tile(cell,MovementGrid.Searches.UNIT,true).has(user) else true
