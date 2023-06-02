extends Control
class_name UnitDisplayManager

const MINI_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/MiniUnitDisplay.tscn")
const SMALL_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/SmallUnitDisplay.tscn")
const BIG_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/BigUnitDisplay.tscn")

@export_enum("MINI_DISPLAY","SMALL_DISPLAY","BIG_DISPLAY") var displayUsed:String ="MINI_DISPLAY"

func refresh_units(units:Array[Unit]):
	for child in get_children(): child.queue_free()
	for unit in units:
		var newDisplay:UnitDisplay = get(displayUsed).instantiate()
		newDisplay.unitRef = unit
		newDisplay.custom_minimum_size
		add_child(newDisplay)
		pass
