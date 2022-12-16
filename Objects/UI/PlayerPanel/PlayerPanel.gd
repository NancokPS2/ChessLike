extends UnitDisplay

func refresh_ui():
	if unitRef != null:
		$Name.text = info["nickName"]
		$Class.text = info["className"]
		$Health/HealthNumbers.text = str( stats["health"] ) + " / " + str( stats["healthMax"] )
		$Energy/EnergyNumbers.text = str( stats["energy"] ) + " / " + str( stats["energyMax"] )
		$Delay.text = str( "UNIT_DELAY" ) + ": " +  str( stats["delay"] ) 
