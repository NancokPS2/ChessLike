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
	Events.connect("COMBAT_FACING_exit",self,"end_turn")
	Events.connect( "COMBAT_enter", Ref, "set", ["unitInAction", Ref.unitsInBattle[0]])#Set the current unit in action

func populate_list(units:Array=Ref.unitsInBattle):#Puts a display of each unit inside
	for i in get_children():
		i.queue_free()
		
	reorder_array_by_turn_delay(units)
	
	for unit in units:
		var display = unitDisplay.instance()
		display.load_unit(unit)
		add_child(display)
	
func get_unit_with_lowest_delay(unitList:Array=Ref.unitsInBattle):#Returns the participant with the lowest delay
	var tempHolder = unitList
	reorder_array_by_turn_delay(tempHolder)
	return tempHolder[0]

func are_participants_valid(units:Array):#Returns false if any units are missing their attributes
	for x in units:
		if x.attributes == null: 
			push_error("Unit " + x.name + " doesn't have the required attributes!")
			return false
	return true

func reorder_array_by_turn_delay(unitList:Array = Ref.unitsInBattle):#Puts those with a lower delay earlier in the array
	unitList.sort_custom(TurnDelaySorting,"sort")
	
func end_turn(turnOwner:Node=Ref.unitInAction, unitList:Array=Ref.unitsInBattle):#Advances all turn delays and resets the current unit to their base, returns the new turn owner
	var delayFromOwner = turnOwner.attributes.turnDelayRemaining#Get the delay before it's lowered
	
	for x in unitList:#Lower the delay of all units, time advance
		x.attributes.lower_turn_delay_remaining(delayFromOwner)
	
	turnOwner.attributes.reset_turn_delay()#Whoever's turn just ended, reset their delay'
	reorder_array_by_turn_delay(unitList)#Reorder the list
	
	turnOwner
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
