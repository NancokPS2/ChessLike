extends TurnManager

var perUnitDisplay:PackedScene = load("res://Objects/TurnDisplay/PerUnitDisplay.tscn")
var unitList:Array #Holds units in play

func _ready():
	unitList = get_participants_from_group("UNIT")
	pass
	
func update_list():

	for i in get_children():
		i.queue_free()
		
	for x in unitList:
		var display = perUnitDisplay.instance()
		display.get_node("UnitName").text = x.attributes.unitName
		display.get_node("UnitDelay").text = str(x.attributes.delayRemaining)
		add_child(display)


func _turn_finished():#Temporary testing
	end_turn(get_participant_with_lowest_delay(unitList),unitList)
	update_list()
	pass # Replace with function body.
