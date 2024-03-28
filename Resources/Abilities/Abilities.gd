extends Resource
class_name Ability

signal usability_status(code:int)
signal assigned_user(unit:Unit)


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

const TARGETING_SHAPE_FRONT:Array[Vector3i]=[Vector3i.FORWARD]
const TARGETING_SHAPE_LINE_TWO:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2]
const TARGETING_SHAPE_LINE_THREE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD*3]
const TARGETING_SHAPE_SELF:Array[Vector3i]=[Vector3i.ZERO]
const TARGETING_SHAPE_ADJACENT:Array[Vector3i]=[Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_ALL:Array[Vector3i]=[]
const TARGETING_SHAPE_STAR_ONE:Array[Vector3i]=[Vector3i.ZERO, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.BACK, Vector3i.FORWARD]
const TARGETING_SHAPE_CONE_ONE:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD*2, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]
const TARGETING_SHAPE_BARRIER:Array[Vector3i]=[Vector3i.FORWARD, Vector3i.FORWARD+Vector3i.LEFT, Vector3i.FORWARD+Vector3i.RIGHT]


const INFINITE_DURATION:int = -1

static var abilityHandler:AbilityHandler

var user:Unit:
	set(val):
		if user is Unit:
			user = val
			board = user.board
			if user.is_node_ready(): user_ready()
			else: user.ready.connect(user_ready)
		else: 
			user = val
			
		assigned_user.emit(user)
		
		

## Set alongside it's unit
var board:GameBoard
#
#		if user is Unit and user.board is GameBoard:
#			return user.get("board")
#		else:
#			push_error(str(user)+ " may not be a Unit or lacks a board.")
#			return null

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

		
var readied:bool=false:
	get = is_ready
		
var filters:Array[Callable]:
	get:
		for filter in targetingFilterNames:
			filters.append(Callable(Filters,filter))
		return filters

func _init() -> void:
	assigned_user.connect(_on_assigned_user)
	
func user_ready():
	readied = true

	_user_ready()
	
#Overridable
func _user_ready():
	print_debug("Not defined.")
	pass

func is_ready():
	return readied

#Overridable
func _on_assigned_user(who:Unit):
	pass

func get_description():
	var desc:String = description + "\n"
	for effect in effects:
		desc += effect._get_description() + "\n"
	return desc

func get_targeting_shape():
	return targetingShape

func is_usable()->bool:
	var stats:CharAttributes = user.attributes
	
	if stats.get_stat(stats.StatNames.ACTIONS) < actionCost:
		usability_status.emit(UsabilityStatuses.INSUFFICIENT_ACTIONS)
		return false
	elif stats.get_stat(stats.StatNames.MOVES) < moveCost: 
		usability_status.emit(UsabilityStatuses.INSUFFICIENT_MOVES)
		return false
	elif stats.get_stat(stats.StatNames.ENERGY) < energyCost:
		usability_status.emit(UsabilityStatuses.INSUFFICIENT_ENERGY)
		return false
	elif not _custom_can_use():  
		usability_status.emit(UsabilityStatuses.CUSTOM_FAILED)
		return false
	
	usability_status.emit(UsabilityStatuses.OK)
	return true
	pass

#func targeting_get_units_in_cells(cells:Array[Vector3i])->Array[Unit]:
	#var targets:Array[Unit] 
	#for cell in cells:
		#targets.assign(user.board.gridMap.search_in_cell(cell, Board.Searches.UNIT, true))
	#return targets
	
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

	
## Checks for units in the cells and warns them of an upcoming attack.
func warn_unit(unit:Unit):
#	var units:Array[Unit]
#
#	for target in targets:
#		units.assign(board.gridMap.search_in_cell(target, Board.Searches.UNIT, true))
		
	unit.was_targeted.emit(self)
	
func proc_costs():
	user.attributes.change_stat(AttributesBase.StatNames.MOVES, -moveCost)
	user.attributes.change_stat(AttributesBase.StatNames.ACTIONS, -actionCost)
	user.attributes.change_stat(AttributesBase.StatNames.ENERGY, -energyCost)
	user.attributes.change_stat(AttributesBase.StatNames.TURN_DELAY, -turnDelayCost)
	
func use( targetingInfo:AbilityTargetingInfo ):
	proc_costs()
	print_debug(user.attributes.info.nickName + " used " + displayedName + " on cells " + str(targetingInfo.cellsTargeted))
#	targets = filter_targets(targets)
	#The warning happens in get_tween(), no need for this.
#	for target in targets:
#		var possibleUnit:Unit = board.gridMap.search_in_cell(target, Board.Searches.UNIT)
#		if possibleUnit is Unit:
#			possibleUnit.was_targeted.emit(self)

	for effect in effects:
		effect.use(targetingInfo)
	
	_use(targetingInfo)

	
func _use(targetingInfo:=AbilityTargetingInfo.new()):
	print( user.attributes.get_info(CharAttributes.InfoNames.NICK_NAME) + " tried something. But it didn't do anything.")
	pass

#func get_unit_in_cell(cell:Vector3i)->Unit:
	#return board.gridMap.search_in_cell(cell, Board.Searches.UNIT)

func _custom_can_use() -> bool:#Virtual function, prevents usage if false
	return true

func _custom_filter(_target:Vector3i)->bool:
	return true

#const FilterNames:Dictionary = {HAS_UNIT = "has_unit", NOT_HAS_UNIT = "not_has_unit"} 
class Filters extends RefCounted:
	
	#True if there's a unit there
	static func has_unit(cell:Vector3i, _user:Unit): return true if Board.search_in_cell(cell,Board.Searches.UNIT) is Unit else false
	#True if there's not a unit
	static func not_has_unit(cell:Vector3i, _user:Unit): return false if Board.search_in_cell(cell,Board.Searches.UNIT) is Unit else true
	#True if the tile has nothing in it
	static func empty_tile(cell:Vector3i, _user:Unit): return true if Board.search_in_cell(cell,Board.Searches.ANYTHING) == null else false
	
	static func is_ally(cell:Vector3i, user:Unit): 
		var targetUnit:Unit = Board.search_int_tile(cell, Board.Searches.UNIT)
		if targetUnit is Unit and user.attributes.get_faction().is_friendly_with(targetUnit.attributes.get_faction()):
			return true
		elif not targetUnit is Unit: 
			push_error("There is no unit here! has_unit should have been called first!")
			return false
		else:
			return false
	
	static func has_self(cell:Vector3i, user:Unit): return true if Board.search_in_cell(cell,Board.Searches.UNIT,true).has(user) else false
	
	static func not_has_self(cell:Vector3i, user:Unit): return false if Board.search_in_cell(cell,Board.Searches.UNIT,true).has(user) else true

#class PassiveEffects extends RefCounted:
#	@export var triggeringSignals:Array[StringName]:
#		set(val):
#			triggeringSignals = val
#
#	@export var durationTick:int
#	@export var durationDelay:float
#	@export var tickSignal:StringName ##durationTick will advance whenever this is triggered
	
## Should be created by AbilityHandler
	
		
