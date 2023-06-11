extends Control
class_name UnitDisplayManager
const MINI_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/MiniUnitDisplay.tscn")
const SMALL_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/SmallUnitDisplay.tscn")
const BIG_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/BigUnitDisplay.tscn")

@export_enum("MINI_DISPLAY","SMALL_DISPLAY","BIG_DISPLAY") var displayUsed:String ="MINI_DISPLAY"

var unitSelected:Unit
		
func set_unit_selected(unit:Unit):
	unitSelected = unit
	Events.UPDATE_UNIT_INFO.emit()
	print(unitSelected)

func refresh_units(units:Array[Unit]):
	assert(not units.is_empty())
	for child in get_children(): child.queue_free()
	for unit in units:
		var newDisplay:UnitDisplay = get(displayUsed).instantiate()
		newDisplay.unitRef = unit
		newDisplay.custom_minimum_size = Vector2(size.y*2, size.y)
		newDisplay.clicked_unit.connect(set_unit_selected)
		add_child(newDisplay)
		
		pass
