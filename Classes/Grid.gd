extends GridMap
class_name MovementGrid
#Provides methods for a game with grid based movement.
#Not suitable for using actual tiles as they are be overwritten with most methods present here

enum mapShapes{STAR,CONE,SINGLE,ALL}
enum objectTypes {UNITS,TILES,OBJECTS}
var cellDict:Dictionary = {
	0:{},
	1:{},
	2:{}
}

func get_all_of_type(type:int,location:bool=false):
	if location:#Get the cell they are located in
		return cellDict[type].keys()
	else:#Get the objects
		return cellDict[type].values()
	

func set_cellDict(type:int,value):
	cellDict[type] = value

func set_item_from_array(cells:PoolVector3Array,objetctID:int):#Sets all cells in the array to the chosen ID
	for pos in cells:
		set_cell_item(pos.x,pos.y,pos.z,objetctID)

func align_to_grid(object:Object):
	var gridPos:Vector3 = world_to_map(object.translation)
	object.translation = map_to_world(gridPos.x,gridPos.y,gridPos.z)

func get_cells_in_shape(validTiles:Array,origin:Vector3,size:int=1,shape:int=mapShapes.STAR)->Array:
	var returnedTiles:Array
	match shape:
		mapShapes.SINGLE:#Only return the origin
			returnedTiles.append(origin)
			
		mapShapes.STAR:#Return all within a certain tiled distance
			for tile in validTiles:
				if abs(tile.x - origin.x) + abs(tile.y - origin.y) + abs(tile.z - origin.z) <= size:
					returnedTiles.append(tile)
		
		mapShapes.ALL:#Return all valid tiles
			returnedTiles = validTiles
	return returnedTiles

#func get_square_area(upperLeftCorner:Vector2,lowerRightCorner:Vector2,tileId:int = 0)->Array:#Gets the tiles in a square area between the upperLeft and lowerRight coerners
#	clear()
#	var returnValue
#	var movingVector = upperLeftCorner #Start in the upper corner
#
#	while movingVector != lowerRightCorner:
#		set_cellv(movingVector,tileId)#Place tile
#		movingVector += Vector2.RIGHT#Move right
#		if movingVector.x > lowerRightCorner.x:#If gone too far right
#			movingVector += Vector2.DOWN#Move down
#			movingVector.x = upperLeftCorner.x#Go to the x of the original position
#	set_cellv(lowerRightCorner,tileId)#The while ends just before placing the last tile
#
#	returnValue = get_used_cells_by_id(tileId)
#	clear()
#	return returnValue
#
#	pass
#
#
#
#func move_trough_grid(object:Object,direction:Vector2,distance:int = 1):#direction must be a Vector2 enum, like Vector2.LEFT
#	var startingTile = get_coordinates_on_grid(object)#Get starting position
#
#	var destinationTile = startingTile + (direction * distance)
#	destinationTile = destinationTile.round()#Rounding as a failsafe
#
#	object.position = map_to_world(destinationTile)
#
#func get_distant_tile(startingPosition:Vector2,direction:Vector2,distance:int = 1) ->Vector2:#Like move_trough_tiles, but only returns the position#Get starting position
#
#	var destinationTile = startingPosition + (direction * distance)
#	destinationTile = destinationTile.round()#Rounding as a failsafe
#	return destinationTile
#
#func get_star_area(origin:Vector2,size:int = 1,tilesToAvoid:PoolVector2Array = []) ->PoolVector2Array:#Gets all tiles within a range in tiles
#	clear()
#	set_cellv_from_array(tilesToAvoid,300)#Populates the grid with tiles that will not be overwritten, useful for obstacles
#	var tilesToReturn:PoolVector2Array
#	var tilesQueued:PoolVector2Array
#	set_cellv(origin,1)#Mark the origin with ID 1
#
#	for _x in range(0,size+1):#This way, 0 still marks a tile
#		tilesQueued.resize(0)
#		tilesQueued = get_used_cells_by_id(1)#Get all cells with ID 1
#		for y in tilesQueued:
#			set_cellv(y,0)#This cell no longer needs to be queued
#			if get_cellv(y+Vector2.UP) == INVALID_CELL:#Ensure the cell is empty before placing
#				set_cellv(y+Vector2.UP, 1)
#
#			if get_cellv(y+Vector2.RIGHT) == INVALID_CELL:
#				set_cellv(y+Vector2.RIGHT,1 )
#
#			if get_cellv(y+Vector2.DOWN) == INVALID_CELL:
#				set_cellv(y+Vector2.DOWN,1 )
#
#			if get_cellv(y+Vector2.LEFT) == INVALID_CELL:
#				set_cellv(y+Vector2.LEFT,1 )
#	tilesToReturn = get_used_cells()#Store the marked tiles
#	clear()
#	return tilesToReturn
#
#func get_cone_area(origin:Vector2,direction:Vector2,size:int = 1,tilesToAvoid:PoolVector2Array = []) ->PoolVector2Array:#Gets all tiles within a range in tiles
#	clear()
#	set_cellv_from_array(tilesToAvoid,300)#Populates the grid with tiles that will not be overwritten, useful for obstacles
#	var tilesToReturn:PoolVector2Array
#	var tilesQueued:PoolVector2Array
#	var deviation1:Vector2
#	var deviation2:Vector2
#	if direction == Vector2.LEFT or direction == Vector2.RIGHT:
#		deviation1 = Vector2.UP
#		deviation2 = Vector2.DOWN
#	elif direction == Vector2.UP or direction == Vector2.DOWN:
#		deviation1 = Vector2.LEFT
#		deviation2 = Vector2.RIGHT
#	set_cellv(origin,1)#Mark the origin with ID 1
#
#	for _x in range(0,size+1):#This way, 0 still marks the origin tile
#		tilesQueued.resize(0)
#		tilesQueued = get_used_cells_by_id(1)#Get all cells with ID 1
#		for y in tilesQueued:
#			set_cellv(y,0)#This cell no longer needs to be queued
#			if get_cellv(y+direction) == INVALID_CELL:#Ensure the cell is empty before placing
#				set_cellv(y+direction,1)
#				set_cellv(y+direction+deviation1,1)
#				set_cellv(y+direction+deviation2,1)
#
#	tilesToReturn = get_used_cells()#Store the marked tiles
#	clear()
#	return tilesToReturn
#	pass
						#Combat Stuff
	#-----------------------------------------------------------
	#-----------------------------------------------------------
	#-----------------------------------------------------------
	


