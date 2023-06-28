extends Control

@export var statList:DecoratedList
@export var unitDisplay:UnitDisplayManager
@export var camera:PivotCamera3D

var loadedUnits:Array[Unit]

func _ready() -> void:
	unitDisplay.unit_selected.connect(update_list)
	update_display_manager()

func update_display_manager():
	loadedUnits.clear()
	
	#Add every unit from the player's faction
	for attribs in Ref.get_player_faction().existingUnits:
		loadedUnits.append(Unit.Generator.build_from_attributes(attribs))
		print_debug(attribs.baseStats)
	
	for unit in loadedUnits:
		unit.attributes.combine_attributes_base_stats()
	
	#Show them in the UI
	unitDisplay.refresh_units(loadedUnits)

func update_list(unit:Unit):
	statList.defaultObject = unit
	statList.update_from_entries(unit)
	pass