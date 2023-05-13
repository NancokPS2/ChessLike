extends GridMap
class_name MovementGrid
#Provides methods for a game with grid based movement.
#Not suitable for using actual tiles as they are be overwritten with most methods present here


enum Searches {UNIT, OBSTACLE, ANYTHING}
enum MapShapes{STAR,CONE,SINGLE,ALL}
var cellDict:Dictionary = {}

func _init() -> void:
	Ref.grid = self

func get_top_of_cell(cell:Vector3i)->Vector3:
	return map_to_local(cell) + Vector3.UP * cell_size.y

func initialize_cells(cells:Array[Vector3i], override:bool=false):
	for cell in cells:
		if not cellDict.has(cell) or override:
			cellDict[cell] = []

## Searches for something in the given tile, returns false if it can't find anything
func search_in_tile(where:Vector3i, what:Searches=Searches.UNIT):
	if not cellDict.has(where): push_error(str(where) + " is not a valid cell.")
	match what:
		Searches.UNIT:
			for obj in cellDict[where]:
				if obj is Unit: return obj
				
		Searches.OBSTACLE:
			#WIP
			return null
			for obj in cellDict[where]:
				if obj is Object: return obj
				
		Searches.ANYTHING:
			if not cellDict[where].is_empty(): return cellDict[where][0]
			
				
		_: push_error("Invalid Search")
		
	return null


func set_item_from_array(cells:Array[Vector3],objetctID:int):#Sets all cells in the array to the chosen ID
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


