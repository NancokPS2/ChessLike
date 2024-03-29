extends Control

@export var statList:DecoratedList
@export var unitDisplay:UnitDisplayManager
@export var camera:PivotCamera3D
@export var viewport:Viewport
@export var modelNode:Node3D:
	get:
		if not modelNode is Node3D and viewport is Viewport:
			var foundNode:Node3D = viewport.get_child(0)
			return foundNode
		else: return modelNode

var loadedUnits:Array[Unit]

func _ready() -> void:
	unitDisplay.unit_selected.connect(on_unit_selected)
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

func on_unit_selected(unit:Unit):
	statList.defaultObject = unit
	statList.update_from_entries(unit)
	modelNode.replace_by(unit.attributes.model.instantiate())
	
	pass
