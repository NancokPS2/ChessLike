extends Resource
class_name Cell

@export var position:Vector3i
@export var tags:Array[String]
@export var terrainID:int
var contents:Array[Node]


static func find_cell_with_position(cells:Array[Cell], wantedPos:Vector3i)->Cell:
	for cell in cells:
		if cell.position == wantedPos: return cell
	return null
