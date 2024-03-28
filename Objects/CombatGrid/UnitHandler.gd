extends Node
class_name UnitHandler

signal added_unit_to_list(unit:Unit)
signal removed_unit_from_list(unit:Unit)
signal updated_combat_roster(unitList:Array[Unit])

signal unit_acting(unit:Unit)
signal selected_unit(unit:Unit)

signal put_unit_in_combat(unit:Unit)
signal put_unit_in_benched(unit:Unit)
signal put_unit_in_removed(unit:Unit)

signal unit_entered_the_Board(unit:Unit)



enum UnitStates {BENCHED, COMBAT, REMOVED}

enum UnitDataFields {STATE}
const DEFAULT_UNIT_DATA:Array = [UnitStates.REMOVED, null, null, null]

@export_category("References")
@export var unitDisplayManager:UnitDisplayManager
@export var endTurnButton:Button

var actingUnit:Unit:
	set(val):
		actingUnit = val
		unit_acting.emit(actingUnit)
		

var selectedUnit:Unit:
	set = select_unit

var unitDict:Dictionary #Unit:Data
#var unitDict:Array[Unit]

func add_unit(unit:Unit, state:UnitStates = UnitStates.REMOVED):
	if not unitDict.has(unit): 
		unitDict[unit] = DEFAULT_UNIT_DATA.duplicate() as Array
		print(unitDict)
		var unitData:Array = unitDict[unit]
		unitData[UnitDataFields.STATE] = state
		assert(unitDict[unit][UnitDataFields.STATE] == state)
		added_unit_to_list.emit(unit)
	
	else: push_error("This unit is already in the list.")
	
func spawn_unit(unit:Unit, where:Vector3i):
	assert( unitDict.has(unit), "This unit was not added trough add_unit()" )
	assert( unit.get_parent() == self or unit.get_parent() == null, "Units should only be a child of this node." )
	
	
	set_unit_state(unit, UnitStates.COMBAT)
	Board.gridMap.position_object_3D(where, unit)
	add_child(unit)
	
	#Update the gridMap
	Board.gridMap.update_cell_contents()
	
	unit_entered_the_Board.emit(unit)
	
func select_unit(unit:Unit):
	selectedUnit = unit
	selected_unit.emit(unit)

func remove_unit(unit:Unit):
	if unitDict.has(unit):
		unitDict.erase(unit)
		removed_unit_from_list.emit(unit)
	pass

func set_unit_state(unit:Unit, state:UnitStates):
	unitDict[unit][UnitDataFields.STATE] = state
	
	match state:
		UnitStates.REMOVED: 
#			unit.get_parent().remove_child(unit)
			put_unit_in_removed.emit(unit)
			
		UnitStates.BENCHED: 
#			if unit.get_parent() == self: remove_child(unit)
#			elif unit.get_parent() != null: push_error("This unit was added as a child of some other node!")
			put_unit_in_benched.emit(unit)
			
		UnitStates.COMBAT: 
			put_unit_in_combat.emit(unit)

func get_unit_state(unit:Unit):
	return unitDict[unit][UnitDataFields.STATE]


func get_all_units()->Array[Unit]:
	var returnal:Array[Unit]
	returnal.assign(unitDict.keys())
	return returnal
	
func get_all_factions()->Array[Faction]:
	var factionList:Array[Faction]
	for unit in get_all_units():
		var faction:Faction = unit.attributes.get_faction()
		if not factionList.has(faction): 
			factionList.append(faction)
	return factionList
	
func filter_units_by_state(state:UnitStates=UnitStates.COMBAT, units:Array[Unit] = get_all_units())->Array[Unit]:
#	var filteredArr:Array[Unit]
#	for unit in units:
#		var unitState:UnitStates = unitDict[unit][UnitDataFields.STATE]
#		if unitState == state: filteredArr.append(unit)
#
#	return filteredArr
	return units.filter(
		func(unit:Unit): 
			return unitDict[unit][UnitDataFields.STATE] == state
			)
	
func filter_units_by_faction(faction:Faction, units:Array[Unit] = get_all_units()):
	units.filter(
		func(unit:Unit):
			return unit.attributes.get_faction() == faction
			)




class UnitFilters extends RefCounted:
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

class SpawnHandler extends Node:
	var factions:Array[Faction]
	var spawnPos
	pass
	
