extends Resource
class_name Cell

const NOT_SPAWN:int = -1

enum ClearFlags {UNITS=1, OBSTACLES=2, TAGS=4}

@export var position:Vector3i
@export var tags:Array[StringName]
@export var terrainID:int = 0 ## What item from the library mesh will be used.
@export var factionSpawnID:int = NOT_SPAWN ## Which faction in an array will get a spawn point here
@export var preplacedUnit:CharAttributes ## If set, a unit will be stored and spawned during the loading process

var spawnForFaction:Faction

var unitsContained:Array[Node]
var obstaclesContained:Array[Node]
var tileID:int

func get_debug_text():
	var text:String
	text += str(position) + "\n"
	text += "Units: " + str(unitsContained) + "\n"
	text += "Obstacles: " + str(obstaclesContained) + "\n"
	text += "Tags: " + str(tags) + "\n"
	return text

func add_object(variant):
	if variant is Unit:
		add_unit(variant)
	elif variant is Obstacle:
		add_obstacle(variant)
	elif variant is String:
		add_tag(variant)

func remove_object(variant):
	if variant is Unit:
		remove_unit(variant)
	elif variant is Obstacle:
		remove_obstacle(variant)
	elif variant is String:
		remove_tag(variant)

func add_unit(unit:Unit):
	if unit is Unit:
		unitsContained.append(unit)
	else:
		push_error("Null value ignored.")

func remove_unit(unit:Unit):
	if unit is Unit:
		unitsContained.erase(unit)
	else:
		push_error("Null value ignored.")	

func add_obstacle(obstacle:Obstacle):
	print_debug("Obstacles have not been implemented yet!")
	if obstacle is Obstacle:
		obstaclesContained.append(obstacle)
	else:
		push_error("Null value ignored.")
		
func remove_obstacle(obstacle:Obstacle):
	print_debug("Obstacles have not been implemented yet!")
		
	
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

func clear(clearFlag:ClearFlags = ClearFlags.UNITS + ClearFlags.OBSTACLES):
	if clearFlag & ClearFlags.UNITS:
		unitsContained.clear()
	if clearFlag & ClearFlags.OBSTACLES:
		obstaclesContained.clear()
	if clearFlag & ClearFlags.TAGS:
		tags.clear()

static func find_cell_with_position(cells:Array[Cell], wantedPos:Vector3i)->Cell:
	for cell in cells:
		if cell.position == wantedPos: return cell
	return null

static func get_position_map(cellArr:Array[Cell])->Array[Vector3i]:
	var vecArr:Array[Vector3i]
	vecArr.assign(cellArr.map(func(cell:Cell): return cell.position))
	return vecArr
	pass
