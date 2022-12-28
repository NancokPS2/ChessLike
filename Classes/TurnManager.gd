extends HBoxContainer
class_name TurnManager

class TurnDelaySorting:#A sorting algorithm for turns
	static func sort(a, b):
		if a.stats["turnDelay"] < b.stats["turnDelay"]:
			return true
		return false

var unitDisplay = preload("res://Objects/UI/TurnDisplay/PerUnitDisplay.tscn")
var unitsInOrder:Array

func _ready() -> void:
	Events.connect( "SETUP_exit", self,"choose_new_acting_unit" )
	Events.connect( "SETUP_exit", self,"populate_list")#Update units shown above
	Events.connect( "COMBAT_FACING_exit", self, "end_turn" )


func choose_new_acting_unit(unitList:Array = Ref.unitsInBattle):
	reorder_array_by_turn_delay(unitList)
	Ref.unitInAction = unitList[0]
	

func populate_list(units:Array = Ref.unitsInBattle):#Updates the display to show units
	for i in get_children():
		i.queue_free()
		
	reorder_array_by_turn_delay(units)
	
	for unit in units:
		var display = unitDisplay.instance()
		display.load_unit(unit)
		add_child(display)
	
func get_unit_with_lowest_delay(unitList:Array=Ref.unitsInBattle):#Returns the participant with the lowest delay
	var tempHolder = unitList.duplicate()
	reorder_array_by_turn_delay(tempHolder)
	return tempHolder[0]

func are_participants_valid(units:Array):#Returns false if any units are missing their attributes
	for x in units:
		if x.attributes == null: 
			push_error("Unit " + x.name + " doesn't have the required attributes!")
			return false
	return true

static func reorder_array_by_turn_delay(unitList:Array = Ref.unitsInBattle):#Puts those with a lower delay earlier in the array
	unitList.sort_custom(TurnDelaySorting,"sort")
	
func end_turn(turnOwner:Node=Ref.unitInAction, unitList:Array=Ref.unitsInBattle):#Advances all turn delays and resets the current unit to their base, returns the new turn owner
	var delayFromOwner = turnOwner.stats.turnDelay#Get the delay before it's lowered
	
	for x in unitList:#Lower the delay of all units, time advance
		x.stats.turnDelay -= delayFromOwner
	
	turnOwner.stats.turnDelay = turnOwner.stats.turnDelayMax#Whoever's turn just ended, reset their delay'
	reorder_array_by_turn_delay(unitList)#Reorder the list
	
	Ref.unitInAction = unitList[0]#Set the new unit as the last 
	populate_list()
	

#func _ready():
#	var units: Array
#	var samepleUnit1 = Unit.new()
#	samepleUnit1.load_resources("res://Resources/UnitSamples/MarcoAttributes.tres")
#
#	var samepleUnit2 = Unit.new()
#	samepleUnit2.load_resources("res://Resources/UnitSamples/MishaAttributes.tres")
#
#	var samepleUnit3 = Unit.new()
#	samepleUnit3.load_resources("res://Resources/UnitSamples/MarcoAttributes.tres")
#
#	units.append(samepleUnit1)
#	units.append(samepleUnit2)
#	units.append(samepleUnit3)
#	reorder_array_by_turn_delay(units)
#	print(units)
#	end_turn(units)
#	print(units)
