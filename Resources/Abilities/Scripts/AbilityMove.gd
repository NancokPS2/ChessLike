extends Ability

const USER_JUMP:int = -2147483648
const TARGETABLE_FROM_METHOD:Array[Vector3i] = []


@export var jumpHeight:int = USER_JUMP
@export var passableTags:Array[String] = [Map.DefaultCellTags.WALKABLE]
@export var impassableTags:Array[String] = [Map.DefaultCellTags.NO_ENTRY, Map.DefaultCellTags.UNTARGETABLE]
@export var movementBonus:int = 0

static var debugMode:bool = true
var aStar:GridPathing


#func get_targeting_shape()->Array[Vector3i]:
#	return get_reachable_cells()
#	if not readied: 
#		return targetingShape
#	else: 
#		assert(user is Unit)
#		return get_reachable_cells()

func _user_ready():
	user.turn_started.connect(update_targeting_shape)
	aStar = GridPathing.new(board.gridMap, board.currentMap, debugMode)
	if jumpHeight == USER_JUMP: jumpHeight = user.attributes.get_stat(AttributesBase.StatNames.JUMP_HEIGHT)	
	
func update_targeting_shape():
	var cells:Array[Cell] = board.gridMap.get_cells_in_expansive(
		user.get_current_cell(),
		user.attributes.get_stat(AttributesBase.StatNames.MOVE_DISTANCE),
		user.attributes.get_stat(AttributesBase.StatNames.JUMP_HEIGHT),
		passableTags,
		impassableTags
		)
	
	print_debug(targetingShape)
	targetingShape.clear()
	targetingShape.assign(cells.map(func(cell:Cell): return cell.position)) 
	assert(targetingShape.all(func(vec:Vector3i): board.gridMap.has_cell(vec)), "This shape includes on-existent cells.")
	print_debug(targetingShape)
		
	
#func get_reachable_cells()->Array[Vector3i]:
#	if not user or not is_ready(): return []
#	var userCell:Vector3i = user.get_current_cell()
#	var moveDistance:int = user.attributes.get_stat(AttributesBase.StatNames.MOVE_DISTANCE) + movementBonus
#
#	var reachableCells:Array[Vector3i] = [userCell]
#	for step in range(moveDistance):
#		for cell in reachableCells:
#			#Get nearby adjacent and valid cells
#			var roundOfCells:Array[Vector3i] = filter_cells_by_tags( get_adjacent_to(cell, jumpHeight) )
#
#			#Add any that have not been added before.
#			for foundCell in roundOfCells:
#				if not reachableCells.has(foundCell): 
#					reachableCells.append(foundCell)
#
#
#	return reachableCells
#
#
### Gets cells that are considered adjacent with a height tolerance.
#func get_adjacent_to(cellPos:Vector3i, maxHeightDifference:int)->Array[Vector3i]:
#	var cellPosArray:Array[Vector3i] = []
#	var cells:Array[Cell]
#	cells.append( board.gridMap.get_cell_by_vec_2d(Vector2i(cellPos.x-1, cellPos.z)) )
#	cells.append( board.gridMap.get_cell_by_vec_2d(Vector2i(cellPos.x+1, cellPos.z)) )
#	cells.append( board.gridMap.get_cell_by_vec_2d(Vector2i(cellPos.x, cellPos.z+1)) )
#	cells.append( board.gridMap.get_cell_by_vec_2d(Vector2i(cellPos.x, cellPos.z-1)) )
#
#	for cell in cells:
#		if cell is Cell and abs(cell.position.y - cellPos.y) <= maxHeightDifference: 
#			cellPosArray.append(cell.position)
#
#	return cellPosArray
#
#
###Filter by tags
#func filter_cells_by_tags(cellsToFilter:Array[Vector3i])->Array[Vector3i]:
#	var cells:Array[Vector3i] = cellsToFilter.duplicate()
#
##	cells.filter(func(x:Cell): return x is Cell)
#	assert(not null in cells)
#
#	#Filter from tags
#	cells.filter(func(x:Cell): 
#		return x.tags.any( func(tag:String): 
#			return tag in passableTags and not tag in impassableTags
#			)
#		)
#	return cells
	
	

	
class GridPathing extends AStar3D:
	
	var debugMode:bool
	var gridRef:MovementGrid
	var visualPathMeshInst:=MeshInstance3D.new() #UNUSED
	var individualVisualMeshes:Array[MeshInstance3D]
	var allowedTags:Array[String]
	
	func _init(_gridRef:MovementGrid, map:Map, _debugMode:bool=true):
		debugMode = _debugMode
		gridRef = _gridRef
#		add_points_from_movement_grid()
		gridRef.add_child(visualPathMeshInst)
		
	func get_cells_in_path(startCell:Vector3i,endCell:Vector3i)->Array[Vector3i]:
		var pointA:int = get_closest_point(gridRef.map_to_local(startCell)) 
		var pointB:int = get_closest_point(gridRef.map_to_local(endCell))
		var pointPaths:PackedVector3Array = get_point_path(pointA,pointB)
		
		var cellsPathing:Array[Vector3i]
		for point in pointPaths:
			cellsPathing.append(gridRef.local_to_map(point))
			
		return cellsPathing
	
	
	## Creates and connects all points for pathing
	func add_points_from_movement_grid(map:Map, pathableCellTags:Array[String]=allowedTags):
		#Will not work if it has less than 2 points or the dimensions are different.
		if gridRef.cellDict.size() < 2: push_error("The cellDict of the MovementGrid has less than 2 points. Cannot generate pathing."); return
		if not (gridRef.cell_size.x == gridRef.cell_size.z and gridRef.cell_size.z == gridRef.cell_size.y ): push_error("Adding points to non-cubic GridMaps has not been implemented"); return
		
		#For optimization
		if get_point_capacity() < gridRef.cellDict.size(): reserve_space(gridRef.cellDict.size())
		
		#Create the points
		for cell in map.cellArray:
			var itemID:int = cell.tileID
			
			var point:Vector3i = cell.position
			var pointLocal:Vector3 = gridRef.map_to_local(point)
			var pointID:int = get_available_point_id()
			add_point(pointID, pointLocal)
#			Utility.VisualFuncs.place_sphere_3d(gridRef, pointLocal, 0.1)
		print_debug("Added {0} points for pathing.".format( [get_point_count()] ))
			
		#Connect them

		var connectionDict:Dictionary
		for pointID in get_point_ids():
			var cellPos:Vector3i = gridRef.local_to_map(get_point_position(pointID))
			for dir in MovementGrid.Directionsi:
				var otherPointID = get_closest_point(gridRef.map_to_local(cellPos+dir))
				
				if pointID != otherPointID:
					connect_points(pointID, otherPointID)
						
		
	
	func get_point_from_pos(point:Vector3i)->int:
		var pointRet:int = get_closest_point(gridRef.map_to_local(point))
		return pointRet
	
	func get_unit_path(unit:Unit, startPoint:Vector3, endPoint:Vector3, color:=Color.RED)->Array[Vector3i]:
		for mesh in individualVisualMeshes: mesh.queue_free()
		individualVisualMeshes.clear()
		
		var startPointID:int = get_point_from_pos(startPoint)
		var endPointID:int = get_point_from_pos(endPoint)
		var points:PackedVector3Array = get_point_path(startPointID, endPointID)
		var returnedPoints:Array[Vector3i]; returnedPoints.assign(points)
#		assert(aStarUsed.are_points_connected(startPointID,endPointID))
		assert(not points.is_empty())
			
		return returnedPoints

	func get_targetable_cells():
		
		pass
