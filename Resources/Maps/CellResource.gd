extends Resource
class_name Cell

const NOT_SPAWN:int = -1

@export var position: Vector3i
@export var tags: Array[StringName]
@export var terrainID: int = 0 ## What item from the library mesh will be used.
@export var factionSpawnID: int = NOT_SPAWN ## Which faction in an array will get a spawn point here
@export var preplacedUnit: CharAttributes ## If set, a unit will be stored and spawned during the loading process

func get_debug_text():
	var text:String
	text += str(position) + "\n"
	text += "Tags: " + str(tags) + "\n"
	return text
		
	
func add_tag(tagName:StringName):
	if tagName is StringName:
		tags.append(tagName)
	else:
		push_error("Null value ignored.")
		
func remove_tag(tagName:StringName):
	if tagName is StringName:
		tags.erase(tagName)
	else:
		push_error("Null value ignored.")	
	
	
func add_tag_array(arr:Array[StringName]):
	tags.append_array(arr)

static func find_cell_with_position(cells:Array[Cell], wantedPos:Vector3i)->Cell:
	for cell: Cell in cells:
		if cell.position == wantedPos: return cell
	return null

static func get_position_map(cellArr:Array[Cell])->Array[Vector3i]:
	var vecArr:Array[Vector3i]
	vecArr.assign(cellArr.map(func(cell:Cell): return cell.position))
	return vecArr
	pass
