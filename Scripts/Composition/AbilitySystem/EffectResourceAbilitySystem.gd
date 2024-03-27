extends Resource
class_name AbilityEffect

#@export var abilityOverrides:Dictionary = {
#	"targetingShape":_targeting_shape_override
#	}
#
#func _targeting_shape_override(ability:Ability)->Array[Vector3i]:
#	return []

func use(targetingInfo:AbilityTargetingInfo):
	_graphical_effect_general(targetingInfo)
	_use(targetingInfo)
	
	for unitTargeted in targetingInfo.unitsTargeted:
		_unit_effect(unitTargeted)
		_graphical_effect_unit(unitTargeted)
		
	for cellTargeted in targetingInfo.cellsTargeted:
		_cell_effect(cellTargeted)
		_graphical_effect_cell(cellTargeted)
		
func _use(targetingInfo:AbilityTargetingInfo):
	pass
	
func _unit_effect(unit:Unit):
	print_debug("Unit targeted: "+str(unit))
	pass
	
func _cell_effect(cell:Vector3i):
	print_debug( "Cell targeted: "+str(cell) )
	pass

func _get_description()->String:
	return "Description not implemented for this effect."
	
func _graphical_effect_general(targetingInfo:AbilityTargetingInfo):
	print_debug(targetingInfo.user.get_name())
	pass

func _graphical_effect_unit(unit:Unit):
	var tween:= unit.create_tween()
	tween.tween_property(unit.bodyNode,"scale", Vector3.ONE * 1.5, 0.5)
	tween.tween_property(unit.bodyNode, "scale", Vector3.ONE, 0.5)
	tween.play()
	
func _graphical_effect_cell(cell:Vector3i):
	pass
