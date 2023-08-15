extends Resource
class_name AbilityEffect


func use(targetingInfo:AbilityTargetingInfo):
	graphical_effect_general(targetingInfo)
	
	for unitTargeted in targetingInfo.unitsTargeted:
		unit_effect(unitTargeted)
		graphical_effect_unit(unitTargeted)
		
	for cellTargeted in targetingInfo.cellsTargeted:
		cell_effect(cellTargeted)
		graphical_effect_cell(cellTargeted)
	
	
		
func unit_effect(unit:Unit):
	print_debug("Unit targeted: "+str(unit))
	pass
	
func cell_effect(cell:Vector3i):
	print_debug( "Cell targeted: "+str(cell) )
	pass

func get_description()->String:
	return "Description not implemented for this effect."
	
func graphical_effect_general(targetingInfo:AbilityTargetingInfo):
	print_debug(targetingInfo.user.get_name())
	pass

func graphical_effect_unit(unit:Unit):
	var tween:= unit.create_tween()
	tween.tween_property(unit.bodyNode,"scale", Vector3.ONE * 1.5, 0.5)
	tween.tween_property(unit.bodyNode, "scale", Vector3.ONE, 0.5)
	tween.play()
	
func graphical_effect_cell(cell:Vector3i):
	pass
