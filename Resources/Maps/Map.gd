extends Resource
class_name Map

const INVALID_CELL_COORDS:Vector3i = Vector3i.ONE * -2147483648

#const DefaultCellTags:Dictionary = {
	#WALKABLE="WALKABLE", ## All units (dirt, path)
	#EMPTY="EMPTY", ## Flying only (chasms)
	#LIQUID="LIQUID", ## All except non-swimming walkers (water)
	#UNSTABLE="UNSTABLE", ## All except heavy walkers (mud)
	#DENSE="DENSE", ## Only heavy walkers (water current, brambles)
	#HARD="HARD", ## Fall damage is increased on this kind of tile (rock)
	#SOFT="SOFT", ## Fall damage is negated on this kind of tile (slime, water, hay)
	#NO_AIR="NO_AIR", ## All but flying and hovering (strong wind)
	#ELEVATOR="ELEVATOR", ## Walkers ignore terrain differences (ladder)
	#UNTARGETABLE="UNTARGETABLE", ## Units may not willingly move into these (lava)
	#NO_ENTRY="NO_ENTRY", ## Impossible to enter
	#}

@export_category("Meta")
@export var display_name: String  
@export var internal_name: StringName
@export var description: String
@export var icon: Texture = preload("res://UnusedStuff/assets/tiles/grass.png")



@export_category("Tile Set")
#@export var tileSet:MapTileSet = preload("res://Resources/Maps/TileSets/Grassy.tres")
@export var meshLibrary:MeshLibrary = preload("res://Assets/Meshes/Map/MeshLibs/GrassyTiles.tres")
@export var tileSetTags:Dictionary = {0:["WALKABLE"],1:[""],2:[""],3:[""],4:[""],5:[""],6:[""],7:[""],8:[""],9:[""],10:[""],11:[""]} #cellID(int):CellTags(Array[String])
func get_default_tags_for_ID(ID:int)->Array[String]:
	var arr:Array[String]
	arr.assign(tileSetTags[ID])
	return arr
#	set(val): 
#		tileSet=val
#		if not get_all_IDs().all(func(cellID:int): return tileSet.meshLibrary.get_item_list().has(cellID)):
#			push_error("")
		
@export_category("Factions")		
@export var factions_present: Array[StringName]
@export var factions_spawn_locations: Array[Array] #Vector3i



@export_category("Misc Contents")		
@export var background:Texture

@export var cellArray:Array[Cell]


@export_group("Auto Generation")
@export var assignSpawns:bool
@export var generateTerrain:bool = false
@export var noiseName:StringName = "NOISE_DEFAULT"
@export var noiseSeed:int = 0
@export var wantedSize:Vector3i = Vector3i.ONE*15
@export_range(1,8) var maxFactions:int = 2
@export_range(1,10) var spawnsPerFaction:int = 6

var cellMapPos:Dictionary
var cellMapPos2D:Dictionary

	
