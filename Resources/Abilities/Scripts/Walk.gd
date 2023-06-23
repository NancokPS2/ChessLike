extends Ability
class_name AbilityMovement

func get_cell_terrain_tags(cell:Vector3i)->Array[String]:
	var tags:Array[String] = board.gridMap.get_cell_tags(cell)
	return tags.filter(func(tag:String): return Map.DefaultCellTags.keys().has(tag))

func get_all_reachable_cells(movementType:AttributesBase.MovementTypes):
	match movementType:
		AttributesBase.MovementTypes.WALK:
			pass
	pass
