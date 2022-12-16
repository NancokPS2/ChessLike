extends Panel



func _process(delta):
	$UnitName.text = Globalvars.st_UnitName + ", " + Globalvars.st_UnitClass #Returns the class name based on the provided id int
	$HealthBar/Health.text = "Health: " + str(Globalvars.st_UnitHealth)
	$EnergyBar/Energy.text = "Energy: " + str(Globalvars.st_UnitEnergy)
	$UnitEvasion.text = "Evasion: " + str(Globalvars.st_UnitEvasion)
	$EnemyName.text = "DumbEnemy"
	$EnemyHealth/Health.text = "Health: " + str(SavedUnits.enemyList[Globalvars.fieldPanelChosenEnemy][3])
#	$EnemyEnergy/Energy.text = "Energy: " + str(enemyStat[3])
	pass


func _on_Slot1_button_down():
	Globalvars.fieldPanelChosenUnit = 0
	Globalvars.friendlyTarget = true
	pass # Replace with function body.


func _on_Slot2_button_down():
	Globalvars.fieldPanelChosenUnit = 1
	Globalvars.friendlyTarget = true
	pass # Replace with function body.


func _on_Slot3_button_down():
	Globalvars.fieldPanelChosenUnit = 2
	Globalvars.friendlyTarget = true
	pass # Replace with function body.


func _on_Slot4_button_down():
	Globalvars.fieldPanelChosenUnit = 3
	Globalvars.friendlyTarget = true
	pass # Replace with function body.


func _on_Enemy1_button_down():
	Globalvars.fieldPanelChosenEnemy = 0
	Globalvars.friendlyTarget = false
	pass # Replace with function body.


func _on_UnitList_item_selected(index):
	Globalvars.UnitForPlacement = index
	Globalvars.st_UnitName = str(SavedUnits.unitList[index][0])
	Globalvars.st_UnitClass = str(Globalrole.classList[SavedUnits.unitList[index][2]][2])
	Globalvars.st_UnitHealth = str(SavedUnits.unitList[index][3])
	Globalvars.st_UnitEnergy = str(SavedUnits.unitList[index][6])
	pass
