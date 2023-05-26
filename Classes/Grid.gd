extends GridMap
class_name MovementGrid
#Provides methods for a game with grid based movement.
#Not suitable for using actual tiles as they are be overwritten with most methods present here

signal cell_clicked(cellPos:Vector3i)
signal marked_cell_clicked(cellPos:Vector3i)

const TargetingMesh:MeshLibrary = preload("res://Assets/CellMesh/Base/TargetingMesh.tres")
const Directionsi:Array[Vector3i]=[Vector3i.UP,Vector3i.DOWN,Vector3i.BACK,Vector3i.FORWARD,Vector3i.LEFT,Vector3i.RIGHT]
const Directions:Array[Vector3]=[Vector3.UP,Vector3.DOWN,Vector3.BACK,Vector3.FORWARD,Vector3.LEFT,Vector3.RIGHT]
const DefaultCellTags = Map.DefaultCellTags

enum CellIDs {BLUE, TRANSPARENT, ORANGE, YELLOW}
enum Searches {UNIT, OBSTACLE, ANYTHING, TAG}
enum MapShapes{STAR,CONE,SINGLE,ALL}

var cellDict:Dictionary = {}
var objectPicker:=Picker3D.new()
var pathing:GridPathing

@export var subGridMap:GridMap = GridMap.new():
	set(val):
		if subGridMap is GridMap: subGridMap.queue_free()
		else: push_error("Null subGridMap"); return
		subGridMap = val
		add_child(subGridMap)
		subGridMap.cell_size = cell_size
		subGridMap.y = Vector3.UP * (cell_size.y * 0.3)
		subGridMap.collision_layer = 0
		subGridMap.collision_mask = 0
		subGridMap.mesh_library = TargetingMesh



func _init() -> void:
	Ref.grid = self
	cell_clicked.connect(printer)

func _ready() -> void:
	objectPicker.debugPath = true
	objectPicker.user = self

## Updates all cells and object positions
func update_grid(map:Map):
	#TODO: This should not take ALL used cells (?)
	initialize_cells(map)
	pathing = GridPathing.new(self,get_typed_cellDict_array())
	register_all_objects_to_cells()

func register_all_objects_to_cells():
	assert(not cellDict.is_empty())
	var allValidNodes:Array = []
	for group in Const.Groups: allValidNodes += get_tree().get_nodes_in_group(Const.Groups[group])
	
	for node in allValidNodes:
		assert(node.get("position")!=null)
		var cellPos:Vector3i = local_to_map(node.position)
		
		if not cellDict.has(cellPos): push_error("The object is outside the grid!")
		else: cellDict[cellPos].append(node)

## Returns all cells in cellDict as Array[Vector3i]
func get_typed_cellDict_array(array:Array = cellDict.keys())->Array[Vector3i]:
	var returnal:Array[Vector3i]
	returnal.assign(array)
	return returnal

func get_top_of_cell(cell:Vector3i)->Vector3:
	return map_to_local(cell) + Vector3.UP * cell_size.y

func printer(variant):
	print(variant)
	pathing.update_individual_visual_meshes(map_to_local(Vector3i.ZERO),map_to_local(variant))


	
func mark_cells(cells:Array[Vector3i], tileID:CellIDs = CellIDs.ORANGE):
	subGridMap.clear()
	for cell in cells:
		subGridMap.set_cell_item(cell,tileID)
		
func get_marked_cells():
	return subGridMap.get_used_cells()
	
func is_cell_marked(cellPos:Vector3i):
	return subGridMap.get_cell_item(cellPos) != INVALID_CELL_ITEM 

## Puts tags on the cells, if override is true, it resets any previously defined cell
func initialize_cells(map:Map, override:bool=false):
	var cellArrays = map.terrainCells
	for cell in map.get_all_cells():
		if not cellDict.has(cell) or override:
			var cellTags = map.get_all_cell_tags(cell)
			cellDict[cell] = map.get_all_cell_tags(cell)
			#print(cellDict[cell])
	

## Alias of search_in_tile(where:Vector3i, Searches.TAGS, true)
func get_cell_tags(cell:Vector3i, getAll:bool=true)->Array:
	return search_in_tile(cell, Searches.TAG, getAll)


## Searches for something in the given tile, returns false if it can't find anything
func search_in_tile(where:Vector3i, what:Searches=Searches.UNIT, getAll:bool=false):
	if not cellDict.has(where): push_error(str(where) + " is not a valid cell.")
	match what:
		Searches.UNIT:
			if getAll:
				return cellDict[where].filter(func(obj): return true if obj is Unit else false)
			else:
				for obj in cellDict[where]: if obj is Unit: return obj
				
#		Searches.OBSTACLE:
#			if getAll:
#				return cellDict[where].filter(func(obj): return true if obj is null else false)
#				pass
#			for obj in cellDict[where]:
#				if obj is Object: return obj
				
		Searches.ANYTHING:
			if not cellDict[where].is_empty(): return cellDict[where][0]
		
		Searches.TAG:
			if getAll:
				return cellDict[where].filter(func(obj): return true if obj is String else false)
			else:
				for obj in cellDict[where]: if obj is String: return obj
				
		_: push_error("Invalid Search, OBSTACLE not yet implemented either.")
		
	return null


func set_items_from_array(cells:Array[Vector3],objetctID:int):#Sets all cells in the array to the chosen ID
	for pos in cells:
		set_cell_item(Vector3i(pos),objetctID)

func align_to_grid(object:Object):
	var gridPos:Vector3i = local_to_map(object.position)
	object.translation = map_to_local(gridPos)

func get_cells_in_shape(validTiles:Array,origin:Vector3,size:int=1,shape:int=MapShapes.STAR, facing:int=SIDE_TOP)->Array:
	var returnedTiles:Array
	match shape:
		MapShapes.SINGLE:#Only return the origin
			returnedTiles.append(origin)
			
		MapShapes.STAR:#Return all within a certain tiled distance
			for tile in validTiles:
				if abs(tile.x - origin.x) + abs(tile.y - origin.y) + abs(tile.z - origin.z) <= size:
					returnedTiles.append(tile)
		
		MapShapes.ALL:#Return all valid tiles
			returnedTiles = validTiles
	return returnedTiles



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_click"):
		var mouseIntersect = objectPicker.get_from_mouse(Picker3D.QueriedInfo.POSITION)
		if not mouseIntersect is Vector3: 
			return
		else:
			mouseIntersect = local_to_map(mouseIntersect)
			emit_signal("cell_clicked", mouseIntersect)
			if is_cell_marked(mouseIntersect): emit_signal("marked_cell_clicked", mouseIntersect)
	
class GridPathing extends Node:
	const VisualMeshRotations:Dictionary ={
		Vector3i.BACK:Vector3(-90,0,0),
		Vector3i.FORWARD:Vector3(-90,180,0),
		Vector3i.LEFT:Vector3(-90,-90,0),
		Vector3i.RIGHT:Vector3(-90,90,0),
		Vector3i.UP:Vector3(0,0,0),
		Vector3i.DOWN:Vector3(180,0,0),
		}
	const DEFAULT_LAYER:String = "all"
	const ALLOW_ALL_TILES:int = 0
	
	var aStarLayers:Dictionary #String:AStar3D
	var gridRef:MovementGrid
	var visualPathMeshInst:=MeshInstance3D.new() #UNUSED
	var individualVisualMeshes:Array[MeshInstance3D]
	var debugMode:bool
	
	func _init(_gridRef:MovementGrid, points:Array[Vector3i]=[], _debugMode:bool=true):
		debugMode = _debugMode
		gridRef = _gridRef
		add_points_from_cell_positions(points)
		gridRef.add_child(visualPathMeshInst)
		
	func get_cells_in_path(startCell:Vector3i,endCell:Vector3i, layer:String=DEFAULT_LAYER)->Array[Vector3i]:
		var thisAStar:AStar3D = aStarLayers[layer]
		var pointA:int = thisAStar.get_closest_point(gridRef.map_to_local(startCell)) 
		var pointB:int = thisAStar.get_closest_point(gridRef.map_to_local(endCell))
		var pointPaths:PackedVector3Array = thisAStar.get_point_path(pointA,pointB)
		
		var cellsPathing:Array[Vector3i]
		for point in pointPaths:
			cellsPathing.append(gridRef.local_to_map(point))
			
		return cellsPathing
	
	
	## Creates and connects all points for pathing
	func add_points_from_cell_positions(points:Array[Vector3i], layer:String=DEFAULT_LAYER, pathableCellIDs:int=ALLOW_ALL_TILES):
		#Will not work if it has less than 2 points or the dimensions are different.
		if gridRef.cellDict.size() < 2: push_error("The cellDict of the MovementGrid has less than 2 points. Cannot generate pathing."); return
		if not (gridRef.cell_size.x == gridRef.cell_size.z and gridRef.cell_size.z == gridRef.cell_size.y ): push_error("Adding points to non-cubic GridMaps has not been implemented"); return
		
		if not aStarLayers.has(layer): aStarLayers[layer]=AStar3D.new()
		var thisAStar:AStar3D = aStarLayers[layer]
		
		assert(aStarLayers[layer] == thisAStar)
		
		#For optimization
		if thisAStar.get_point_capacity() < gridRef.cellDict.size(): thisAStar.reserve_space(gridRef.cellDict.size())
		
		#Create the points
		for point in points:
			var pointLocal:Vector3 = gridRef.map_to_local(point)
			var pointID:int = thisAStar.get_available_point_id()
			thisAStar.add_point(pointID, pointLocal)
#			Utility.VisualFuncs.place_sphere_3d(gridRef, pointLocal, 0.1)
		print_debug("Added {0} points for pathing.".format( [thisAStar.get_point_count()] ))
			
		#Connect them
		var connectionDict:Dictionary
		for pointID in thisAStar.get_point_ids():
			var cellPos:Vector3i = gridRef.local_to_map(thisAStar.get_point_position(pointID))
			for dir in MovementGrid.Directionsi:
				var otherPointID = thisAStar.get_closest_point(gridRef.map_to_local(cellPos+dir))
				
				if pointID != otherPointID:
					thisAStar.connect_points(pointID, otherPointID)
				
#			var pointID:int = connectionDict[pointPos]
#			var validPoints:Array = connectionDict.keys()
#			validPoints.filter(func(val:Vector3): return true if val.distance_to(pointPos) <= distanceToNeighbor else false)
#
#			for otherPointPos in validPoints:
#				thisAStar.connect_points(pointID,connectionDict[otherPointPos])
				
		
	
	func get_point_from_pos(point:Vector3, aStarLayer:String=DEFAULT_LAYER)->int:
		var aStarUsed:AStar3D = aStarLayers[aStarLayer]
		var pointRet:int = aStarUsed.get_closest_point(point)
		return pointRet
	
	func update_individual_visual_meshes(startPoint:Vector3, endPoint:Vector3, aStarLayer:String=DEFAULT_LAYER, color:=Color.RED):
		for mesh in individualVisualMeshes: mesh.queue_free()
		individualVisualMeshes.clear()
		
		var aStarUsed:AStar3D = aStarLayers[aStarLayer]
		var startPointID:int = get_point_from_pos(startPoint)
		var endPointID:int = get_point_from_pos(endPoint)
		var points:PackedVector3Array = aStarUsed.get_point_path(startPointID, endPointID)
#		assert(aStarUsed.are_points_connected(startPointID,endPointID))
		assert(not points.is_empty())
		
		print(points)
		for point in points:
			place_mesh_in_pos(point, VisualMeshRotations[Vector3i.RIGHT])

	
	func place_mesh_in_pos(pos:Vector3, orientation:Vector3i):
		var newMeshInst:=MeshInstance3D.new()
		newMeshInst.rotation = orientation
		newMeshInst.position = pos
		individualVisualMeshes.append(newMeshInst)
		
		
		#Set mesh
		var mesh:=PrismMesh.new()
		mesh.size = Vector3(0.3,0.3,0.3)
		newMeshInst.mesh = mesh
		gridRef.add_child(newMeshInst)
	
	func update_visual_path_mesh(startPoint:Vector3, endPoint:Vector3, aStarLayer:String="default", color:Color=Color.RED):
		var mesh:=ImmediateMesh.new()
		var aStarUsed:AStar3D = aStarLayers[aStarLayer]
		var startPointID:int = get_point_from_pos(startPoint)
		var endPointID:int = get_point_from_pos(endPoint)
		var points:PackedVector3Array = aStarUsed.get_point_path(startPointID, endPointID)
		assert(aStarUsed.are_points_connected(startPointID,endPointID))
		
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		for point in points:
			mesh.surface_set_color(color)
			mesh.surface_add_vertex(point)
		mesh.surface_end()
		visualPathMeshInst.mesh = mesh
		if visualPathMeshInst.get_parent() != gridRef: 
			gridRef.add_child(visualPathMeshInst)
		if debugMode:
			print_debug(ResourceSaver.save(mesh,"user://testPath.tres"))
