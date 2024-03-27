extends GridMap
class_name PositionGrid
#Provides methods for a game with grid based movement.
#Not suitable for using actual tiles as they are be overwritten with most methods present here

signal cell_clicked(cellPos:Vector3i)
signal cell_clicked_empty(cellPos:Vector3i)
signal cell_clicked_with_unit(cellPos:Vector3i)
signal unit_clicked(unit:Unit)
signal marked_cell_clicked(cellPos:Vector3i)
signal cell_changed(cellPos:Vector3i)

signal placed_object(cell:Vector3i, object:Object)

const ADJACENT_CELLS: Array[Vector3i] = [Vector3i.UP, Vector3i.DOWN, Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
const DIAGONAL_CELLS: Array[Vector3i] = [
	Vector3i(1, 1, 1),
	Vector3i(1, 1, -1),
	Vector3i(-1, 1, -1),
	Vector3i(-1, 1, 1),
	Vector3i(1, -1, 1),
	Vector3i(1, -1, -1),
	Vector3i(-1, -1, -1),
	Vector3i(-1, -1, 1),
]

const INVALID_CELL_COORDS:Vector3i = Vector3i.ONE * -2147483648
const MAX_HEIGHT: int = 40
const CellDataKeys: Dictionary = {
	
}
const TargetingMesh: MeshLibrary = preload("res://Assets/Meshes/Map/MeshLibs/SubGridMeshLib.tres")
const DefaultCellTags = Map.DefaultCellTags

enum CellIDs {TARGETING, BLUE, YELLOW, GREEN, PINK, BROWN, SKYBLUE, GREY, RED}
enum Searches {UNIT, OBSTACLE, ANYTHING, TAG, ALL_OBJECTS}
enum AreaTypes {FLOOD, STAR, CONE, ALL}

var loaded_map: Map
var cell_data: Dictionary
var cell_hovered: Vector3i

func load_map():
	loaded_map.update_cell_maps()
	cell_data = loaded_map.cellMapPos
	mesh_library = loaded_map.meshLibrary


func data_set(coordinate: Vector3i, key: String, data):
	cell_data[coordinate] = cell_data.get(coordinate, {})
	cell_data[coordinate][key] = data

	
func data_get(coordinate: Vector3i, key: String):
	return cell_data.get(coordinate, {}).get(key, null)

	
func data_clear():
	cell_data.clear()


static func get_manhattan_distance(posA:Vector3i, posB:Vector3i)->int:
	var manhattanDistance:int = abs(posA.x - posB.x) + abs(posA.y - posB.y) + abs(posA.z - posB.z)
	return manhattanDistance
	
static func get_mahattan_distance_2d(posA:Vector3i, posB:Vector3i)->int:
	var manhattanDistance:int = abs(posA.x - posB.x) + abs(posA.z - posB.z)
	return manhattanDistance


func get_cell_by_vec(pos: Vector3i, search_height: bool = true) -> Cell:
#	var cell:Cell = cell_data.get(pos,null)
	var cell: Cell = loaded_map.get_cell_by_pos(pos)
	
	#If not found, check in the entire height region
	if cell == null and search_height:
		push_warning("Cell not found, looking per height.")
		for height: int in MAX_HEIGHT:
			cell = cell_data.get(pos + (Vector3i.UP * height), null)
			if cell is Cell: break
				
	assert(cell.position == pos)
	return cell
	
	
func get_cells_in_area(origin: Vector3i, type: AreaTypes, direction: Vector3i, size: int, height_tolerance: int = 0) -> Array[Vector3i]:
	assert(height_tolerance >= 0, "Tolerance cannot be negative.")
	assert(direction.length() <= 1, "Direction must be normalized.")
	var output: Array[Vector3i] 
	match type:
		AreaTypes.FLOOD:
			var to_expand: Array[Vector3i] = [origin]
			
			## Start from a cell
			for coord: Vector3i in to_expand:
				
				## Add the current coord to output
				if not coord in output:
					output.append(coord)
				
				## For every adjacent coord 
				for adjacent: Vector3i in ADJACENT_CELLS:
					## Only add those without an Array
					if not adjacent in output:
						to_expand.append(adjacent)
				
				## Remove cells already in the output from the expansion array
				for vector: Vector3i in to_expand:
					if vector in output:
						to_expand.erase(vector)
		
		AreaTypes.STAR:
			for x: int in range(origin.x - size, origin.x + size):
				for y: int in range(origin.y - size, origin.y + size):
					for z: int in range(origin.z - size, origin.z + size):
						var coord: Vector3i = Vector3i(x, y, z)
						
						## Reduce Z coordinate to account for tolerance.
						var adjusted_coord: Vector3i = coord
						adjusted_coord.z = move_toward(adjusted_coord.z, 0, height_tolerance)
						
						if get_manhattan_distance(adjusted_coord, origin) <= size:
							output.append(coord)
		
		AreaTypes.CONE:
			var expansion_origin: Vector3i = direction * size
			for x: int in range(origin.x + size + 1):
				for y: int in range(origin.y + size + 1):
					for z: int in range(origin.z + size + 1):
						var coord: Vector3i = Vector3i(x, y, z)
						
						## Reduce Z coordinate to account for tolerance.
						var adjusted_coord: Vector3i = coord
						adjusted_coord.z = move_toward(adjusted_coord.z, 0, height_tolerance)
						
						if get_manhattan_distance(expansion_origin, origin) <= size:
							output.append(coord)
						
	
	for vector: Vector3i in output:
		assert(output.count(vector) > 1, "Duplicate vector!")
			
	
	
	
	return output
	
	
func get_cells_in_expansive(origin:Vector3i, steps:int, maxHeightDifference:int, validTags:Array[String], invalidTags:Array[String])->Array[Cell]:
	#Preparation for first cell
	var cells:Array[Cell] = [get_cell_by_vec(origin)]
	var cellsToExpand:Array[Cell] = [ cells[0] ]
	cells[0].set_meta("_TO_EXPAND", true)
	
	#Each time it will expand
	for step in steps:
		
		#Check all cells found so far
		for cell in cells:
			
			#If this cell is not to be expanded, skip
			if not cell.get_meta("_TO_EXPAND", false): continue
			
			#Else get the cells to add
			var cellsToAdd:Array[Cell] = get_cells_adjacent_to(cell.position, maxHeightDifference) 
			for cellToAdd in cellsToAdd:
				#If it wasn't added already...
				if not cells.has(cellToAdd): 
					#Queue them for expansion
					cellToAdd.set_meta("_TO_EXPAND", true)
					#Add them to the Array
					cells.append(cellToAdd)
					
			#Remove the found cell from the expansion list
			cell.remove_meta("_TO_EXPAND")
			
	assert(cells.size()>2)
	assert(cells.all(
		func(cell:Cell): 
		if get_cell_by_vec(cell.position) is Cell:
			return true
		else:
			push_error("Cell at position is not valid " + str(cell.position))
			return false
		)
	)
	return cells
	#WIP
	#TODO
	
func get_cells_adjacent_to(origin:Vector3i, maxHeightDifference:int)->Array[Cell]:
	var cells:Array[Cell]
	cells.append( loaded_map.get_cell_by_pos_2d(Vector2i(origin.x+1, origin.z)) )
	cells.append( loaded_map.get_cell_by_pos_2d(Vector2i(origin.x-1, origin.z)) )
	cells.append( loaded_map.get_cell_by_pos_2d(Vector2i(origin.x, origin.z+1)) )
	cells.append( loaded_map.get_cell_by_pos_2d(Vector2i(origin.x, origin.z-1)) )
	
	
	#Filter by height difference
	cells = cells.filter(func(cell:Cell):
		return cell is Cell and abs(cell.position.y - origin.y) <= maxHeightDifference
		)
#	assert(cells.all(func(cell:Cell): get_cell_by_vec(cell.position) is Cell))
	assert(cells.all(
		func(cell:Cell): 
		if get_cell_by_vec(cell.position) is Cell:
			return true
		else:
			push_error("Cell at position is not valid " + str(cell.position))
			return false
		)
	)
	return cells
	
func has_cell(cell:Vector3i):
	if cell_data.has(cell):
		return true
	else:
		push_warning("Cell not found in " + str(cell))
		return false


func printer(variant):
	print(variant)


## Registers all cells in the map to it's cell_data as well as their tags. Override is true, it resets any previously defined cell
func set_cells_from_map(map:Map, override:bool=false):
	clear()
	for cell in map.cellArray:
		set_cell_item(cell.position, cell.tileID)

func set_cells_from_array(cells:Array[Vector3],objetctID:int):#Sets all cells in the array to the chosen ID
	for pos in cells:
		set_cell_item(Vector3i(pos),objetctID)

## Alias of search_in_cell(where:Vector3i, Searches.TAGS, true)
func get_cell_tags(cell:Vector3i)->Array:
	return get_cell_by_vec(cell).tags

func tag_cells(cells:Array[Vector3i], tag:String):
	for cell in cells:
		get_cell_by_vec(cell).add_tag(tag)
	

## Searches for something in the given tile, returns false if it can't find anything
func search_in_cell(where:Vector3i, what:Searches=Searches.UNIT, getAll:bool=false):
	if not cell_data.has(where): 
#		push_error(str(where) + " is not a valid cell.")
		return null
	match what:
		Searches.UNIT:
			if getAll:
				return cell_data[where].unitsContained as Array[Unit]
			else:
				return null if cell_data[where].unitsContained.is_empty() else cell_data[where].unitsContained.back() as Unit
				
		Searches.OBSTACLE:
			push_error("OBSTACLE searches are not implemented.")
			if getAll: 
#				return cell_data[where].filter(func(obj): return true if obj is null else false)
				return cell_data[where].obstaclesContained as Array[Obstacle]
			else: 
#				if obj is Object: return obj
				return null if cell_data[where].obstaclesContained.is_empty() else cell_data[where].obstaclesContained.back() as Obstacle
		
		Searches.TAG:
			if getAll:
				return cell_data[where].tags as Array[StringName]
			else:
				return null if cell_data[where].tags.is_empty() else cell_data[where].tags.back() as StringName
				
		Searches.ALL_OBJECTS:
			if getAll:
				return cell_data[where].unitsContained as Array[Unit] + cell_data[where].obstaclesContained as Array[Node3D]
			else:
				return null if cell_data[where].unitsContained.is_empty() and cell_data[where].obstaclesContained.is_empty() else (cell_data[where].unitsContained as Array[Unit] + cell_data[where].obstaclesContained as Array[Node3D]).back()
		_: push_error("Invalid Search, OBSTACLE not yet implemented either.")
	push_error("Unexpected error in search.")
	return null

func multi_search_in_cell(where:Array[Vector3i], what:Searches):
	var results = null
	for cell in where:
		if results == null:
			results = search_in_cell(cell, what, true)
		else:
			results.append( search_in_cell(cell, what, true) )
	return results


func align_to_grid(object:Object):
	var gridPos:Vector3i = local_to_map(object.position)
	object.translation = map_to_local(gridPos)

#func get_cells_in_shape(validTiles:Array,origin:Vector3,size:int=1,shape:int=MapShapes.STAR, facing:int=SIDE_TOP)->Array:
#	var returnedTiles:Array
#	match shape:
#		MapShapes.SINGLE:#Only return the origin
#			returnedTiles.append(origin)
#
#		MapShapes.STAR:#Return all within a certain tiled distance
#			for tile in validTiles:
#				if abs(tile.x - origin.x) + abs(tile.y - origin.y) + abs(tile.z - origin.z) <= size:
#					returnedTiles.append(tile)
#
#		MapShapes.ALL:#Return all valid tiles
#			returnedTiles = validTiles
#	return returnedTiles

func get_cell_debug_text(cellPos:Vector3i)->String:
	return get_cell_by_vec(cellPos).get_debug_text()
	
