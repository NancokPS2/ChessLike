extends Resource
class_name Map



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

@export var displayName:String  
  
## Set to a Noise name to use that automatically.
@export var internalName:StringName
@export var description:String

@export var heightMap:Array = []

@export var meshLibrary:MeshLibrary:# = preload("res://Assets/Meshes/Map/MeshLibs/GrassyTiles.tres")
	get: return tileSet.meshLibrary
	
@export var tileSet:MapTileSet
#	set(val): 
#		tileSet=val
#		if not get_all_IDs().all(func(cellID:int): return tileSet.meshLibrary.get_item_list().has(cellID)):
#			push_error("")
		

@export var background:Texture

enum TerrainCellData {TILE_ID,TILE_POS,TAGS}
@export var terrainCells:Array[Array] 
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


@export var spawnLocations:Array[Array] = [
	[Vector3i(2,0,1)],
	[Vector3i.LEFT*2]
]

@export var unitsToGenerate:Array[Dictionary] = [
	{
		"unitName":"Human",
		"raceName":"HUMAN",
		"className":"CIVILIAN",
		"factionName":"DEFAULT",
		"positionInGrid":(Vector2(0,0))
	}
]

@export var initialUnits:Array[MapUnit]



@export_group("Auto Generation")
@export var generateTerrain:bool = false
@export var noiseName:StringName = "NOISE_DEFAULT"
@export var noiseSeed:int = 0
@export var wantedSize:Vector3i = Vector3i.ONE*15
@export_range(1,8) var maxFactions:int = 2


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
		else: push_error("Not a valid noise constant.")
		
	fix_initial_units(initialUnits)

## Should be ran after auto_generation. Fixes the height of the units and generates unfinished ones
func fix_initial_units(mapUnits:Array[MapUnit]):
	var cells:Array[Vector3i] = get_all_cells()
#	assert(not mapUnits.is_empty())
	if mapUnits.is_empty(): push_warning("No units defined in this map.")
	for unit in mapUnits:
		#The unit is placed at a different height from the map
		if not cells.has(unit.position):
			#Look for a viable height to place the unit in.
			for posY in range(wantedSize.y, 0, -1):
				if cells.has(Vector3i(unit.position.x, posY, unit.position.z)): unit.position.y = posY; break
				
## Uses the tags:Dictionary variable from the tileSet to assign IDs
func generate_tags_from_tile_set():
#	var tileSetTags:Dictionary = tileSet.tags
	for index in range(terrainCells.size()):
		var cellID:int = terrainCells[index][Map.TerrainCellData.TILE_ID]
		
#		var tagsToAdd:Array = tileSetTags.get(cellID,[])
		var tagsToAdd:Array = tileSet.get_tags_for_ID(cellID)
		terrainCells[index][Map.TerrainCellData.TAGS].append_array(tagsToAdd)
	


func add_terrain_cell(tileID:int, pos:Vector3i, tags:Array[String]):
	var cellArray:Array = [tileID, pos, tags]
	terrainCells.append(cellArray)

func remove_terrain_cell(cell:Vector3i):
	terrainCells = terrainCells.filter(func(cellArr:Array): return cellArr[1]!=cell)

func get_all_cell_tags(cell:Vector3i)->Array:
	var result:Array = terrainCells.filter(func(cellArr:Array): return cellArr[1]==cell)[0]
	assert(result.size()==3 and not result[2].is_empty())
	return result[2] as Array

func get_all_cells()->Array[Vector3i]:
	var cells:Array[Vector3i]
	for cellArr in terrainCells:
		cells.append(cellArr[TerrainCellData.TILE_POS])
	return cells

func get_all_IDs()->Array[int]:
	var IDs:Array[int]
	for cellArr in terrainCells:
		var currID:int = cellArr[TerrainCellData.TILE_ID]
		if not IDs.has(currID):
			IDs.append(currID)
	return IDs
		

func is_valid()->bool:
	
	var cellIDs:Array[int] = get_all_IDs()
	var cellPositions:Array[Vector3i] = get_all_cells()
	
	var cellMaxValue:int = meshLibrary.get_item_list().size()
	
	#Ensure that no cell defines a non existent TileID
	for ID in cellIDs:
		if ID >= cellMaxValue:
			push_error("Invalid mesh ID on terrainCells, maximum value for this meshLibrary is " + str(cellMaxValue) + ". The cell's ID is " + str(ID))
			return false
	
	#Check that all initial units are placed in a valid cell
	if not initialUnits.all(func(unit:MapUnit): return cellPositions.has(unit.position) ):
		push_error("At least one unit was placed outside the map. Ensure initialUnits positions match the cells defined in terrainCells.")
		return false

		
	return true

class TerrainGenerator extends RefCounted:
	const NOISE_DEFAULT:FastNoiseLite = preload("res://Other/DefaultTerrainNoise.tres")

#	func save_noise_texture(noise:FastNoiseLite, fileName:String="SampleName.png"):
#		var noiseTex:=NoiseTexture2D.new()
#		noiseTex.noise = noise
		
		
		
		

	func simple_noise_generation(mapUsed:Map, size:Vector3i, noiseUsed:FastNoiseLite, seed:int=0, tags:Dictionary={}):
		assert(mapUsed.terrainCells.is_empty(), "A map that expects generation should not have predefined cells.")
		mapUsed.terrainCells.clear()
		mapUsed.spawnLocations.clear()
		noiseUsed.seed
#		if tags == {}:
#			tags[0] = ["WALKABLE"]
		for x in size.x:
			for z in size.z:
				var tileID:int = 0
				var noisePos:=Vector2( size.x/max(x,1), size.z/max(z,1) )
				var noiseVal:float = noiseUsed.get_noise_2dv(noisePos)
				var height:int = abs(noiseVal)*mapUsed.wantedSize.y
				var tagsUsed:Array[String] 
#				tagsUsed.assign(tags[tileID])
				mapUsed.add_terrain_cell(tileID, Vector3i(x,height,z), [])
		
		mapUsed.generate_tags_from_tile_set()
		
		var copyOfTerrain:Array[Array] = mapUsed.terrainCells.duplicate(true)
		for faction in mapUsed.maxFactions:
			var thisFaction:Array = []
			thisFaction.append(copyOfTerrain.pop_back()[Map.TerrainCellData.TILE_POS])
			thisFaction.append(copyOfTerrain.pop_back()[Map.TerrainCellData.TILE_POS])
			mapUsed.spawnLocations.append(thisFaction)
			
		assert(mapUsed.terrainCells.size() >= size.x*size.z)
		



			
		pass
