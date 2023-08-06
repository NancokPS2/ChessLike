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

const TARGETING_SHAPE_FRONT:Array[Vector3i]=[Vector3i.FORWARD]
const TARGETING_SHAPE_LINE_TWO:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2]
const TARGETING_SHAPE_LINE_THREE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD*3]
const TARGETING_SHAPE_SELF:Array[Vector3i]=[Vector3i.ZERO]
const TARGETING_SHAPE_ADJACENT:Array[Vector3i]=[Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_ALL:Array[Vector3i]=[]
const TARGETING_SHAPE_STAR_ONE:Array[Vector3i]=[Vector3i.ZERO, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_CONE_ONE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]
const TARGETING_SHAPE_BARRIER:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]


static var callQueue:CallQueue

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
			push_error(str(user)+ " may not be a Unit or lacks a board.")
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
@export_group("Restrictions")
@export var classRestrictions:Array[String]

@export_group("Main values")
@export var customVals:Dictionary = {"power":1.0, "duration":1 as int}
@export var energyCost:int
@export var turnDelayCost:int
@export var triggerSignals:Dictionary #user.signal:self.method()
#Example: {"acted":"use"}
@export var abilityFlags:Array[AbilityFlags]
@export var actionCost:int = 1
@export var moveCost:int = 0

@export_group("Targeting")
@export var targetingShape:Array[Vector3i] = TARGETING_SHAPE_ADJACENT #The area which the user can target
@export var targetingAOEShape:Array[Vector3i] = TARGETING_SHAPE_SELF #The area relative to the targeted point that it will affect
@export var targetingRotates:bool = false #If true, the targetingShape will be rotated to match the user's facing.

@export var amountOfTargets:int = 1 #How many cells the user can target (the AOE will be applied to each one separately)
@export var targetingFilterNames:Array[StringName] = ["has_unit"]:
	set(val):
#		assert(not val.is_empty())
		if val.all( func(method:String): return method.is_valid_identifier() ): targetingFilterNames = val
#		elif not val is Array[String]: push_error("Invalid array type.")
		else: push_error("Invalid filter found in the array.")
		
@export_group("Visuals")
@export var animationDuration:float
		
var filters:Array[Callable]:
	get:
		for filter in targetingFilterNames:
			filters.append(Callable(Filters,filter))
		return filters


#func equip(newUser:Node):
func get_description():
	return description

func is_usable()->bool:
	var stats = user.attributes.stats
	
	if stats.actions < actionCost: return false
	elif stats.moves < moveCost: return false
	elif not _custom_can_use():  return false
	
	return true
	pass

func targeting_get_units_in_cells(cells:Array[Vector3i])->Array[Unit]:
	var targets:Array[Unit] 
	for cell in cells:
		targets.assign(user.board.gridMap.search_in_cell(cell, MovementGrid.Searches.UNIT, true))
	return targets
	
func targeting_get_relative_from_user(cellPos:Vector3i)->Vector3i:
	var userCell:Vector3i = user.get_current_cell()
	return cellPos - userCell
#	var manhattanDistance:int = abs(userCell.x - cellPos.x) + abs(userCell.y - cellPos.y) + abs(userCell.z - cellPos.z)
	

func targeting_get_rotated_to_cell(shape:Array[Vector3i], targetCell:Vector3i)->Array[Vector3i]:
	var relativeTarget:Vector3i = targeting_get_relative_from_user(targetCell)
	var targetShapeHolder:Array[Vector3i] = shape.duplicate()
	
	#LEFT OR RIGHT is prioritized for now, this problem should be prevented by design.
	if abs(relativeTarget.x) > abs(relativeTarget.z) or relativeTarget.x == relativeTarget.z:
		#LEFT
		if relativeTarget.sign().x == Vector3i.LEFT.x:
#			direction = Vector3i.LEFT
			for vec in targetingShape:
				var newVec:Vector3i = vec
				newVec.x = vec.z
				newVec.z = -vec.x
				targetShapeHolder.append(newVec)
		#RIGHT
		elif relativeTarget.sign().x == Vector3i.RIGHT.x:
#			direction = Vector3i.RIGHT
			for vec in targetingShape:
				var newVec:Vector3i = vec
				newVec.x = -vec.z
				newVec.z = vec.x
				targetShapeHolder.append(newVec)
	else:
		#BACK
		if relativeTarget.sign().z == Vector3i.BACK.z:
#			direction = Vector3i.BACK
			for vec in targetingShape:
				var newVec:Vector3i = vec
				newVec.z = -vec.z
				targetShapeHolder.append(newVec)
			
		elif relativeTarget.sign().z == Vector3i.FORWARD.z:
#			direction = Vector3i.FORWARD
			#Same as default, no rotation needed.
			pass
		
		else: push_error("No direction could be stablished!")
	
	return targetShapeHolder
	

func connect_triggers():
	if not user is Unit:#Ensure someone has equipped it
		push_error("Tried to perform this ability's setup, but no one has equipped it yet."); return
		
	for signa in triggerSignals:
		var methodName:String = triggerSignals[signa]
		var errorCode = connect(signa, Callable(self, methodName))
		assert(errorCode == OK)


#func filter_targetable_cells(cells:Array[Vector3i], shape:TargetingShapes=targetingShape)->Array[Vector3i]:
#	var userCell:Vector3i = user.get_current_cell()
#	var filteredCells:Array[Vector3i] = []
#	match shape:
#		TargetingShapes.STAR:
#			for cell in cells:
#				var manhattanDistance:int = abs(userCell.x - cell.x) + abs(userCell.y - cell.y) + abs(userCell.z - cell.z)
#				if manhattanDistance <= targetingRange: filteredCells.append(cell)
#
#		TargetingShapes.ALL:
#			filteredCells = cells
#		_:
#			push_error("Invalid shape")
#	if filteredCells.is_empty(): push_error("No targets could be returned!")
#	print_debug("First pass yielded: "+str(filteredCells))
#	filteredCells = filter_targets(filteredCells)
#	print_debug("Second pass yielded: "+str(filteredCells))
#	return filteredCells
#
#func filter_targets(targets:Array[Vector3i])->Array:
#	assert(not targets.is_empty())
#	var newTargets:Array = targets.duplicate()
#
#
#
#	for filter in filters:
#		newTargets = newTargets.filter(filter)
#
#	return newTargets
			
		
#func get_tween(targets:Array[Vector3i])->Tween:
#	#Filter any unwanted targets.
#	targets = filter_targets(targets)
#	warn_units(targets)
#
#	#Create a tween for each attack
#	var tween:Tween = user.create_tween()
#	tween.tween_callback(use.bind(targets)).set_delay(0.2)
#	tween.pause()
#	return tween
func queue_call(targets:Array[Vector3i]):
	#Filter any unwanted targets.
	warn_units(targets)

	#Create call
	callQueue.add_queued(use)
	callQueue.set_queued_arguments([targets])
	callQueue.set_queued_post_wait(animationDuration)
	
## Checks for units in the cells and warns them of an upcoming attack.
func warn_units(targets:Array[Vector3i]):
	var units:Array[Unit]
	
	for target in targets:
		units.assign(board.gridMap.search_in_cell(target, MovementGrid.Searches.UNIT, true))
		
	for unit in units: unit.was_targeted.emit(self)
	
func use( targets:Array[Vector3i] ):
	user.attributes.stats.moves -= moveCost
	user.attributes.stats.actions -= actionCost
	user.attributes.stats.turnDelay += turnDelayCost
	
#	targets = filter_targets(targets)
	#The warning happens in get_tween(), no need for this.
#	for target in targets:
#		var possibleUnit:Unit = board.gridMap.search_in_cell(target, MovementGrid.Searches.UNIT)
#		if possibleUnit is Unit:
#			possibleUnit.was_targeted.emit(self)
			
	
	
	_use(targets)
	Events.UPDATE_UNIT_INFO.emit()
	Events.ABILITY_USED.emit(self)
	
func _use(target:Array[Vector3i]):
	print( user.info.nickName + " cannot punch. Because testing.")
	pass


func _custom_can_use() -> bool:#Virtual function, prevents usage if false
	return true

func _custom_filter(_target:Vector3i)->bool:
	return true

#const FilterNames:Dictionary = {HAS_UNIT = "has_unit", NOT_HAS_UNIT = "not_has_unit"} 
class Filters extends RefCounted:
	
	#True if there's a unit there
	static func has_unit(cell:Vector3i, _user:Unit): return true if Ref.grid.search_in_cell(cell,MovementGrid.Searches.UNIT) is Unit else false
	#True if there's not a unit
	static func not_has_unit(cell:Vector3i, _user:Unit): return false if Ref.grid.search_in_cell(cell,MovementGrid.Searches.UNIT) is Unit else true
	#True if the tile has nothing in it
	static func empty_tile(cell:Vector3i, _user:Unit): return true if Ref.grid.search_in_cell(cell,MovementGrid.Searches.ANYTHING) == null else false
	
	static func is_ally(cell:Vector3i, user:Unit): 
		var targetUnit:Unit = Ref.grid.search_int_tile(cell, MovementGrid.Searches.UNIT)
		if targetUnit is Unit and user.attributes.get_faction().is_friendly_with(targetUnit.attributes.get_faction()):
			return true
		elif not targetUnit is Unit: 
			push_error("There is no unit here! has_unit should have been called first!")
			return false
		else:
			return false
	
	static func has_self(cell:Vector3i, user:Unit): return true if Ref.grid.search_in_cell(cell,MovementGrid.Searches.UNIT,true).has(user) else false
	
	static func not_has_self(cell:Vector3i, user:Unit): return false if Ref.grid.search_in_cell(cell,MovementGrid.Searches.UNIT,true).has(user) else true

class Effects extends RefCounted:
	
	func deal_damage(targets:Array[Unit]):
		
		pass
	pass
