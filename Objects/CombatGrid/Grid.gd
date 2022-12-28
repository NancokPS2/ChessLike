extends MovementGrid

#Constants
const defaultMeshLib = preload("res://Assets/CellMesh/Base/DefaultTiles.tres")
const defaultCellSize = Vector3(0.32,0.16,0.32)

#Vars
var currentMap:Map = Map.new()

var hoveredCell:Vector3#Stores the currently hovered cell

var currentAbility:Ability

onready var terrain = Terrain.new(currentMap)
onready var targeting = Targeting.new()

var abilityHolder
func _ready() -> void:
	
	cell_size = defaultCellSize
	
	register_tiles(currentMap)#Store each tile in cellDict, WIP
	add_child(terrain)#Adds the terrain so it can generate itself
	

func register_tiles(map:Map):#WIP?
	for tile in currentMap.terrainTiles:#Place all tiles in the map
		var pos = tile[Map.TerrainTileData.TILE_POS]
		var ID = tile[Map.TerrainTileData.TILE_ID]
		cellDict[objectTypes.TILES][pos]=ID


func place_object(object:Node,location:Vector3,type:int=objectTypes.UNITS,forcePlacement:bool=false):
	assert(object is Node)
	
	if object.get_parent() != $MapObjs: #If it is not in the map yet, add it
		$MapObjs.add_child(object)
	
	if object.has_meta("mapPos"):#If it already had a position set previously, remove it first
		var originalPos = object.get_meta("mapPos")
		assert(originalPos is Vector3)
		
		if cellDict[type][originalPos] != object:#Ensure the original location indeed contains the unit, handle it otherwise
			push_error("Uh oh. Metadata points to the wrong location in the grid. Attempting to fix for location: " + str(originalPos))
			var fixed=false
			
			for location in cellDict[type]:
				if cellDict[type][location] == object:
					cellDict[type].erase(location)
					fixed = true
					push_warning("Managed to fix the metadata, all clear.")
			if not fixed:
				push_error("Couldn't fix metadata! PANIC!")
				return
		
		if cellDict[type].get(location,null) != null and forcePlacement == false:#If it is occupied and there has been no instruction to force it
			return
		
		cellDict[type].erase(originalPos)#Remove it from the location
		object.set_meta("mapPos",null)#Remove it's metadata
		
	cellDict[type][location] = object#Set it's new location
	
	object.translation = map_to_world(location.x,location.y+defaultCellSize.y,location.z)#Update it's position
	
	object.set_meta("mapPos",location)#Store a reference to a new position on the object

func remove_object(object:Node,type:int=objectTypes.UNITS):
	assert(object is Node and type is int)
	var objPos = object.get_meta("mapPos",null)
	
	assert(objPos is Vector3)
	
	cellDict[type].erase(objPos)#Remove it from the dict
	object.set_meta("mapPos",null)
	object.get_parent().remove_child(object)#Remove it from the scene

#func position_verification(object:Node,location:Vector3,type:int):

func _input(event: InputEvent) -> void:
	if not CVars.settingUsingController:#While not using a controller, keep tabs on the current mouse hovered tile
		hoveredCell = world_to_map( Ref.mainNode.get_hovered(Ref.mainNode.typesOfInfo.POSITION) )#Keep track of the currently hovered tile
	if CVars.settingDebugMode:
		$DebugHoveredTile.text = str( hoveredCell )#Debug
	hover_visual(hoveredCell)#Relocate the visual
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("primary_click"):
		Events.emit_signal("GRID_TILE_CLICKED",hoveredCell)
		pass
	
func get_cell_occupant(cell:Vector3,type:int=objectTypes.UNITS):
	return cellDict[type].get(cell,null)
	
func hover_visual(gridLoc:Vector3):#Called by _input to update the marker's location
	if cellDict[objectTypes.TILES].has(gridLoc):#Ensure it is a valid tile
		$ChosenCellVisual.translation = map_to_world(gridLoc.x,gridLoc.y,gridLoc.z)+Vector3(0,defaultCellSize.y,0) #Relocate the visual
	
func get_cells_in_area(origin:Vector3,size:int,shape:int,targetingFlags:int):#extension of get_tiles_in_shape
	var validTiles:Array#Which tiles will be considered go here
	#Start filtering
	if targetingFlags && Ability.AbilityFlags.NO_TILE_WITH_OBJECT:#Can't target tiles with objects
		for tile in cellDict[objectTypes.TILES].values():#Check all valid tiles
			if not cellDict[objectTypes.OBJECTS].has(tile): #If it is NOT occupied by an object, add it
				validTiles.append(tile)
				
	if targetingFlags && Ability.AbilityFlags.NO_TILE_WITH_UNIT:#Can't target tiles with units
		for tile in cellDict[objectTypes.TILES].values():#Check all valid tiles
			if not cellDict[objectTypes.UNITS].has(tile):#If it is NOT occupied by an Unit, add it
				validTiles.append(tile)
					
	if not (targetingFlags && Ability.AbilityFlags.NO_TILE_WITH_OBJECT and targetingFlags && Ability.AbilityFlags.NO_TILE_WITH_UNIT):
		validTiles = cellDict[objectTypes.TILES].values() #If no flags impact targeting, just validate all of them
	#Finish filtering
	return get_tiles_in_shape(validTiles,origin,size,shape)#Get all tiles targeted
	
func mark_cells_for_targeting(origin:Vector3,size:int,shape:int,targetingFlags:int):#Returns all targets
	var toMarkCells = get_cells_in_area(origin,size,shape,targetingFlags)
	
	targeting.highlight_tiles(toMarkCells)#Mark them
		
#	if targetingFlags && Ability.AbilityFlags.TARGET_TILES:#If it only targets tiles
#		return targetedTiles
#	else:#If it only targets units
#		var targetedUnits:Array
#		for tile in targetedTiles:#Check all targeted tiles
#			if cellDict[objectTypes.UNITS].has(tile):#If the dict has a unit in the tile
#				targetedUnits.append( cellDict[objectTypes.UNITS][tile] )#Add the unit to the list
#		return targetedUnits
	
class Terrain extends GridMap:
	var map:Map

	func _init(initMap) -> void:
		map = initMap
		
	var hoveredCell:Vector3#TEMP?
	func _process(delta: float) -> void:#This is already done above, seems redundant
		hoveredCell = world_to_map( Ref.mainNode.get_hovered(Ref.mainNode.typesOfInfo.POSITION) )
		
	func _ready() -> void:
		mesh_library = map.meshLibrary
		cell_size = defaultCellSize#Set size
		set_name("Terrain")#Rename itself
		load_tiles(map)
	
	func load_tiles(map:Map):
		for tile in map.terrainTiles:#Place all tiles in the map
			var pos = tile[Map.TerrainTileData.TILE_POS]
			var ID = tile[Map.TerrainTileData.TILE_ID]
			set_cell_item(pos.x,pos.y,pos.z,ID)


class Targeting extends GridMap:
	const targetingCell = preload("res://Objects/CombatGrid/ChosenCellMesh.tscn")
	
	
	
	const DataReq = {
		"origin":null,
		"shape":null,
		"size":null,
		"validTiles":null,
		"flags":null 
		}
	
	func _ready() -> void:
		mesh_library #TODO
		cell_size = defaultCellSize
		set_name("Targeting")
		Events.connect("COMBAT_TARGETING_exit",self,"clear")
		pass
			
	func highlight_tiles(tileArray:Array, removeOldTiles:bool = true):
		assert(tileArray[0] is Vector3)
		if removeOldTiles:#Clean before marking again
			$Targeting.clear()
		
		for tile in tileArray:
			$Targeting.set_cellv(tile,0)
	

	
	
		
		
