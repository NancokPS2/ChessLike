extends Resource
class_name TerrainCell
 
@export var display_name: String
@export var flags: Array[PositionGrid.CellFlags]
@export var mesh: Mesh = ImmediateMesh.new()
@export var shape: Shape3D
 
static func has_flag(flag: PositionGrid.CellFlags, flags_to_check: Array[PositionGrid.CellFlags]) -> bool:
	return flag in flags_to_check
