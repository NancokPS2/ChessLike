extends Resource
class_name Map

const INVALID_CELL_COORDS:Vector3i = Vector3i.ONE * -2147483648

const DefaultCellTags:Dictionary = {
	WALKABLE="WALKABLE", ## All units (dirt, path)
	EMPTY="EMPTY", ## Flying only (chasms)
	LIQUID="LIQUID", ## All except non-swimming walkers (water)
	UNSTABLE="UNSTABLE", ## All except heavy walkers (mud)
	DENSE="DENSE", ## Only heavy walkers (water current, brambles)
	HARD="HARD", ## Fall damage is increased on this kind of tile (rock)
	SOFT="SOFT", ## Fall damage is negated on this kind of tile (slime, water, hay)
	NO_AIR="NO_AIR", ## All but flying and hovering (strong wind)
	ELEVATOR="ELEVATOR", ## Walkers ignore terrain differences (ladder)
	UNTARGETABLE="UNTARGETABLE", ## Units may not willingly move into these (lava)
	NO_ENTRY="NO_ENTRY", ## Impossible to enter
	}

@export_category("Meta")
@export var displayName:String  
  
## Set to a Noise name to use that automatically.
@export var internalName:StringName
@export var description:String
@export var icon:Texture = preload("res://UnusedStuff/assets/tiles/grass.png")



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
@export var factionsPresent:Array[Faction] = [load("res://Resources/Characters/Factions/PLAYER.tres")]
@export var spawnLocations:Dictionary #faction:[spawns]


@export_category("Misc Contents")		
@export var background:Texture

@export var cellArray:Array[Cell]
# [
#	[0,Vector3i.ZERO,["WALKABLE"]],
#	[0,Vector3i.RIGHT,["WALKABLE"]],
#	[0,Vector3i.FORWARD,["WALKABLE"]],
#	[0,Vector3i.BACK,["WALKABLE"]],
#	[0,Vector3i.LEFT,["WALKABLE"]],
#	[0,Vector3i.LEFT*2,["WALKABLE"]],
#	[0,Vector3i(1,0,1),["WALKABLE"]],
#	[0,Vector3i(2,0,1),["WALKABLE"]]
#]



@export_group("Auto Generation")
@export var assignSpawns:bool
@export var generateTerrain:bool = false:
	set(val):
		generateTerrain = val
		auto_generation()
@export var noiseName:StringName = "NOISE_DEFAULT"
@export var noiseSeed:int = 0
@export var wantedSize:Vector3i = Vector3i.ONE*15
@export_range(1,8) var maxFactions:int = 2
@export_range(1,10) var spawnsPerFaction:int = 6

var cellMapPos:Dictionary
var cellMapPos2D:Dictionary


func update_cell_maps():
	cellMapPos.clear()
	cellMapPos2D.clear()
	for cell in cellArray:
		assert( cell is Cell and not cell.position in cellMapPos)
		
		cellMapPos[cell.position] = cell
		cellMapPos2D[Vector2i(cell.position.x, cell.position.z)] = cell
		
	assert(cellMapPos.size() == cellArray.size())
	assert(cellMapPos2D.size() == cellArray.size())
	assert(cellMapPos.values() == cellMapPos2D.values())
	var mappedCells:Array[Cell]
	mappedCells.assign(cellArray)
	
	if not ( all_cells_exist_in_2d( mappedCells ) or all_cells_exist( mappedCells ) ):
		push_error("Invalid cell detected!")
		breakpoint
#	assert(all_cells_exist_in_2d( mappedCells ))
#	assert(all_cells_exist( mappedCells ))
	
		
func get_cell_by_pos(vector:Vector3i)->Cell:
	return cellMapPos.get(vector, null)

func get_cell_by_pos_2d(vector:Vector2i)->Cell:
	return cellMapPos2D.get(vector, null)
	
func all_cells_exist(cells:Array[Cell])->bool:
	for cell in cells:
		if not get_cell_by_pos(cell.position) is Cell:
			push_error("Cell at position is not valid " + str(cell.position))
			return false
	return true
	
func all_cells_exist_in_2d(cells:Array[Cell]):
	for cell in cells:
		if not get_cell_by_pos_2d(Vector2i(cell.position.x, cell.position.z)) is Cell:
			push_error("Cell at position is not valid " + str(cell.position))
			return false
	return true
#func get_faction_spawns(factions:Array[Faction])->Dictionary:
#	if factions.size() > spawnLocations.size(): push_error("{0} factions where provided, but this map only has space for {1}.".format( str(factions.size()) + str(spawnLocations.size()) ) )
#	var spawns:Array[Array] = spawnLocations
#	var finalDict:Dictionary
#
#	for faction in factions:
#		finalDict[faction.internalName] = spawns.pop_back()
#
#	return finalDict
func auto_generation():
	if generateTerrain:
		var generator:=TerrainGenerator.new()
		if generator.get(noiseName) is FastNoiseLite:
			generator.simple_noise_generation(self, wantedSize, generator.get(noiseName), noiseSeed) 
		else: 
			push_error("Not a valid noise constant.")
		
		update_cell_maps()
		

## Should be ran after auto_generation. Fixes the height of the units and generates unfinished ones
#func fix_initial_units(mapUnits:Array[MapUnit]):
#	var cells:Array[Vector3i] = get_all_cell_positions()
##	assert(not mapUnits.is_empty())
#	if mapUnits.is_empty(): push_warning("No units defined in this map.")
#	for unit in mapUnits:
#		#The unit is placed at a different height from the map
#		if not cells.has(unit.position):
#			#Look for a viable height to place the unit in.
#			for posY in range(wantedSize.y, 0, -1):
#				if cells.has(Vector3i(unit.position.x, posY, unit.position.z)): unit.position.y = posY; break
				
## Uses the tags:Dictionary variable from the tileSet to assign IDs
func generate_tags_from_tile_set():
#	var tileSetTags:Dictionary = tileSet.tags
	for index in range(cellArray.size()):
		var cellID:int = cellArray[index].terrainID
		
#		var tagsToAdd:Array = tileSetTags.get(cellID,[])
		var tagsToAdd:Array = get_default_tags_for_ID(cellID)
		cellArray[index].add_tag_array(tagsToAdd)
	


func add_constructed_cell(tileID:int, pos:Vector3i, tags:Array[StringName]):
	var cell:=Cell.new()
	cell.position = pos
	cell.terrainID = tileID
	cell.add_tag_array(tags)
	cellArray.append(cell)

func add_cell(cell:Cell):
#	var newCell:=Cell.new()
#	newCell.position = pos
	cellArray.append(cell)
	pass

func remove_cell(cell:Cell):
	cellArray.erase(cell)

func remove_cell_by_pos(pos:Vector3i):
#	cellArray = cellArray.filter(func(cell:Cell): return cell.position!=pos)
	remove_cell( get_cell_by_pos(pos) )

func get_all_cell_tags_by_pos(pos:Vector3i)->Array:
	var cell:Cell = get_cell_by_pos(pos)
	if cell is Cell: return cell.tags
	else: push_error("Could not find a cell in that position."); return []
	
#	var result:Array = cellArray.filter(func(cellArr:Array): return cellArr[1]==cell)[0]

func get_all_cell_positions()->Array[Vector3i]:
	var cells:Array[Vector3i]
	for cell in cellArray:
		cells.append(cell.position)
	return cells

func get_all_tileIDs()->Array[int]:
	var IDs:Array[int]
	for cell in cellArray:
		var currID:int = cell.terrainID
		if not IDs.has(currID):
			IDs.append(currID)
	return IDs
		
func get_pos_to_cell_dictionary()->Dictionary:
	var dict:Dictionary
	for cell in cellArray:
		dict[cell.position] = cell
	return dict



func get_faction_spawns(faction:Faction)->Array[Vector3i]:
	assert(faction in factionsPresent, "This faction isn't present in this map!")
	if factionsPresent.is_empty(): push_error("No factions present in this map."); return []
	
	var factionIndex:int = factionsPresent.find(faction)
	if not spawnLocations.get(factionIndex,false): 
		push_error("No spawn location has been set for faction {0} at index {1}.".format([faction.internalName, factionIndex]) )
		return []
	
	var returnedSpawns:Array[Vector3i] = spawnLocations[factionIndex]
	
	return returnedSpawns

func set_faction_spawns(index:int, cells:Array[Vector3i]):
	spawnLocations[index] = cells

func is_valid()->bool:
	
	#Ensure there are no duplicates
	if has_duplicated_positions(): return false
	
	#Ensure that no cell uses a non existent tileID for the meshLibrary
	var cellIDs:Array[int] = get_all_tileIDs()
	var cellPositions:Array[Vector3i] = get_all_cell_positions()
	var cellMaxValue:int = meshLibrary.get_item_list().size()
	for ID in cellIDs:
		if ID >= cellMaxValue:
			push_error("Invalid mesh ID on cellArray, maximum value for this meshLibrary is " + str(cellMaxValue) + ". The cell's ID is " + str(ID))
			return false

		
	return true

func has_duplicated_positions()->bool:
	var foundPos:Array[Vector3i]
	for cell in cellArray:
		if not foundPos.has(cell.position): foundPos.append(cell.position)
		else: push_error("Found duplicate position!"); return true
	return false

class TerrainGenerator extends RefCounted:
	const NOISE_DEFAULT:FastNoiseLite = preload("res://Other/DefaultTerrainNoise.tres")

#	func save_noise_texture(noise:FastNoiseLite, fileName:String="SampleName.png"):
#		var noiseTex:=NoiseTexture2D.new()
#		noiseTex.noise = noise
		
		
		
		

	func simple_noise_generation(mapUsed:Map, size:Vector3i, noiseUsed:FastNoiseLite, seed:int=0):
#		assert(mapUsed.cellArray.is_empty(), "A map that expects generation should not have predefined cells.")
		mapUsed.cellArray.clear()
		mapUsed.spawnLocations.clear()
		noiseUsed.seed = seed
		
		var spawnPosDict:Dictionary = {#factionIndex:[positions]
			0:[],
			1:[]
			
		} 
#		if tags == {}:
#			tags[0] = ["WALKABLE"]
		for x in size.x:
			for z in size.z:
				var newCell:=Cell.new()
				newCell.tileID = 0
				
				var noisePos:=Vector2( size.x/max(x,1), size.z/max(z,1) )
				var noiseVal:float = noiseUsed.get_noise_2dv(noisePos)
				var height:int = abs(noiseVal) * mapUsed.wantedSize.y
				newCell.position = Vector3i(x, height, z)
				
				var tagsUsed:Array[StringName] = [DefaultCellTags.WALKABLE]
				
				#Add tags
				newCell.add_tag_array(tagsUsed)
				#Add the cell
				mapUsed.add_cell(newCell)
				
#				tagsUsed.assign(tags[tileID])
#				mapUsed.add_cell(tileID, Vector3i(x,height,z), tagsUsed)
		
		var cellDict:Dictionary = mapUsed.get_pos_to_cell_dictionary()
	
			
		
		#Spawn positions
		var copyOfCells:Array[Cell] = mapUsed.cellArray.duplicate()
		var index:int=0
		for faction in mapUsed.maxFactions:
			var thisFaction:Array[Vector3i]
			for x in mapUsed.spawnsPerFaction:
				thisFaction.append(copyOfCells.pop_back().position)
			mapUsed.set_faction_spawns(index, thisFaction)
			index += 1
		
		assert(mapUsed.spawnLocations.size() == mapUsed.maxFactions, "The should be as many sets of spawn tiles as there are factions.")	
		assert(mapUsed.cellArray.size() >= size.x*size.z)
		



			

	
static func get_manhattan_distance(posA:Vector3i, posB:Vector3i)->int:
	var manhattanDistance:int = abs(posA.x - posB.x) + abs(posA.y - posB.y) + abs(posA.z - posB.z)
	return manhattanDistance
	
static func get_mahattan_distance_2d(posA:Vector3i, posB:Vector3i)->int:
	var manhattanDistance:int = abs(posA.x - posB.x) + abs(posA.z - posB.z)
	return manhattanDistance
