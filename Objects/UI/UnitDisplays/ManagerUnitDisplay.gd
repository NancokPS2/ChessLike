extends Control
class_name UnitDisplayManager

signal unit_selected

const MINI_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/MiniUnitDisplay.tscn")
const SMALL_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/SmallUnitDisplay.tscn")
const BIG_DISPLAY:PackedScene = preload("res://Objects/UI/UnitDisplays/BigUnitDisplay.tscn")

const NO_FACTION_FILTER:StringName = ""

@export_enum("MINI_DISPLAY","SMALL_DISPLAY","BIG_DISPLAY") var displayUsed:String ="MINI_DISPLAY"

var unitSelected:Unit
		
		
func set_unit_selected(unit:Unit):
	unitSelected = unit
	refresh_units()
#	unit_selected.emit(unit)
#	Events.UPDATE_UNIT_INFO.emit()
	print(unitSelected)

func refresh_units(units:Array[Unit] = Ref.board.get_units(false, "PLAYER"), factionFilter:StringName = NO_FACTION_FILTER):
	assert(not units.is_empty())
	for child in get_children(): child.queue_free()
	for unit in units:
		#Check if the filter is active and if the unit fulfills it.
		if factionFilter != NO_FACTION_FILTER and unit.attributes.get_faction().internalName != factionFilter:
			continue
			
		var newDisplay:UnitDisplay = get(displayUsed).instantiate()
		newDisplay.unitRef = unit
		newDisplay.custom_minimum_size = Vector2(size.y*2, size.y)
		newDisplay.clicked_unit.connect(set_unit_selected)
		add_child(newDisplay)
		newDisplay.refresh_ui(true)
		
		pass
