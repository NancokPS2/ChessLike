extends UnitDisplay

#func _ready() -> void:
#	Events.connect("GRID_UNIT_HOVERED",self,"hover_load_unit")
#	Events.connect("GRID_UNIT_CLICKED",self,"load_unit")
#	pass
#
#func hover_load_unit(unit):
#	if Ref.unitSelected == null:
#		load_unit(unit)
	

func refresh_ui():
	if unitRef != null:
		$Name.text = info["nickName"]
		$Class.text = info["className"]
		$Health/HealthNumbers.text = str( stats["health"] ) + " / " + str( stats["healthMax"] )
		$Energy/EnergyNumbers.text = str( stats["energy"] ) + " / " + str( stats["energyMax"] )
		$Delay.text = str( "UNIT_DELAY" ) + ": " +  str( stats["delay"] ) 
