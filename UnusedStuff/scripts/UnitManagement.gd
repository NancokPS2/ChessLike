extends Node2D

var amountOfStats = UnitStats.unitStatNames.size()


func _process(delta):
	var selUnit = Globalvars.selectedUnit
	var unit = SavedUnits.unitList[selUnit]
	var roleName = Globalrole.classList[unit[2]][2]
	
	$UnitName.text = str(SavedUnits.unitList[selUnit][0]) + ", " + str(Globalrole.classList[unit[2]][2])
	$UnitStats.text = "Health: " + str(unit[3])
	$UnitStats2.text = "Attack: " + str(unit[4])
	$UnitStats3.text = "Defense: " + str(unit[5])
	$UnitStats4.text = "Energy: " + str(unit[6])
	print(Globalvars.selectedUnit)
	pass
	


func _on_Prev_Unit_button_down():
	if Globalvars.selectedUnit > 0:
		Globalvars.selectedUnit += -1
	pass # Replace with function body.


func _on_Next_Unit_button_down():
	if Globalvars.selectedUnit < SavedUnits.unitList.size() - 1:
		Globalvars.selectedUnit += 1
	pass # Replace with function body.
