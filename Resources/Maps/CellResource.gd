extends Resource
class_name Cell

const NOT_SPAWN:int = -1

@export var position:Vector3i
@export var tags:Array[StringName]
@export var terrainID:int = 0 ## What item from the library mesh will be used.
@export var factionSpawnID:int = NOT_SPAWN ## Which faction in an array will get a spawn point here
@export var specificUnitSpawn:Unit ## If set, a unit will be stored and spawned during the loading process

var spawnForFaction:Faction
var contents:Array[Node]
var tileID:int

@export_category("Set Unit")
#@export var unitGenerate:bool
@export var unitAttributes:CharAttributes
#@export var racialAttrib:RacialAttributes
#@export var classAttrib:ClassAttributes



func add_tag(tagName:StringName):
	tags.append(tagName)
	
func add_tag_array(arr:Array[StringName]):
	tags.append_array(arr)

static func find_cell_with_position(cells:Array[Cell], wantedPos:Vector3i)->Cell:
	for cell in cells:
		if cell.position == wantedPos: return cell
	return null
