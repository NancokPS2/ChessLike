extends AbilityEffect
class_name AbilityEffectTeleport

func _use(targeting:AbilityTargetingInfo):
	targeting.gridRef.position_object_3D(targeting.cellsTargeted.pick_random(), targeting.user)
	pass
