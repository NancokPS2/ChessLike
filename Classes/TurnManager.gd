extends HBoxContainer
class_name TurnManager
class TurnDelaySorting:#A sorting algorithm for turns
	static func sort(a, b):
		if a.attributes.turnDelayRemaining < b.attributes.turnDelayRemaining:
			return true
		return false

var unitDisplay = preload("res://Objects/UI/TurnDisplay/PerUnitDisplay.tscn")
var unitsInOrder:Array

func populate_list(units:Array):#Puts a display of each unit inside
	for i in get_children():
		i.queue_free()
		
	reorder_array_by_turn_delay(units)
	
	for x in units:
		var display = unitDisplay.instance()
		display.load_unit(x)
		add_child(display)
	
func get_participant_with_lowest_delay(participantList:Array):#Returns the participant with the lowest delay
	var tempHolder = participantList
	reorder_array_by_turn_delay(tempHolder)
	return tempHolder[0]

func are_participants_valid(units:Array):#Returns false if any units are missing their attributes
	for x in units:
		if x.attributes == null: 
			push_error("Unit " + x.name + " doesn't have the required attributes!")
			return false
	return true

func reorder_array_by_turn_delay(unitsParticipating:Array):#Puts those with a lower delay earlier in the array
	unitsParticipating.sort_custom(TurnDelaySorting,"sort")
	pass
	
func end_turn(turnOwner:Unit,participantList:Array)->Unit:#Advances all turn delays and resets the current unit to their base, returns the new turn owner
	var delayFromOwner = turnOwner.attributes.turnDelayRemaining#Get the delay before it's lowered
	
	for x in participantList:#Lower the delay of all units, time advance
		x.attributes.lower_turn_delay_remaining(delayFromOwner)
	
	turnOwner.attributes.reset_turn_delay()#Whoever's turn just ended, reset their delay'
	reorder_array_by_turn_delay(participantList)#Reorder the list
	
	return participantList[0]
	

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
