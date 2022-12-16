extends Node2D

func _process(delta):
	$MouseCursor.position = get_local_mouse_position()

func _physics_process(delta):
	info_panel_update()
	


func info_panel_update(): #Updates the values of the lower panel
	if not FieldVars.selectedUnitReference == null:
		$InfoPanel/UnitName.text = FieldVars.selectedUnitReference.stats["name"] #Returns the class name based on the provided id int
		$InfoPanel/HealthBar/Health.text = "Health: " + str(FieldVars.selectedUnitReference.stats["HP"]) + "/" + str(FieldVars.selectedUnitReference.stats["HPMax"])
		$InfoPanel/EnergyBar/Energy.text = "Energy: " + str(FieldVars.selectedUnitReference.stats["energy"]) + "/" + str(FieldVars.selectedUnitReference.stats["energyMax"])
		$InfoPanel/SecondaryStats/UnitEvasion.text = "Eva. " + str(FieldVars.selectedUnitReference.stats["evasion"]) + "%"
		$InfoPanel/SecondaryStats/UnitAccuracy.text = "Acc. " + str(FieldVars.selectedUnitReference.stats["accuracy"]) + "%"
		$InfoPanel/SecondaryStats/UnitDelay.text = "TD: " + str(FieldVars.selectedUnitReference.stats["turnDelay"])
