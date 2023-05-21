extends GridMap
class_name MovementGrid
#Provides methods for a game with grid based movement.
#Not suitable for using actual tiles as they are be overwritten with most methods present here

signal cell_clicked(cellPos:Vector3i)
signal marked_cell_clicked(cellPos:Vector3i)

const TargetingMesh:MeshLibrary = preload("res://Assets/CellMesh/Base/TargetingMesh.tres")
enum TileIDs {BLUE, TRANSPARENT, ORANGE, YELLOW}

enum Searches {UNIT, OBSTACLE, ANYTHING}
enum MapShapes{STAR,CONE,SINGLE,ALL}
var cellDict:Dictionary = {}
var objectPicker:=Picker3D.new()

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

func printer(variant):
	print(variant)

func _ready() -> void:
	objectPicker.user = self
	
func mark_cells(cells:Array[Vector3i], tileID:TileIDs = TileIDs.ORANGE):
	subGridMap.clear()
	for cell in cells:
		subGridMap.set_cell_item(cell,tileID)
		
func get_marked_cells():
	return subGridMap.get_used_cells()
	
func is_cell_marked(cellPos:Vector3i):
	return subGridMap.get_cell_item(cellPos) != INVALID_CELL_ITEM 

func get_top_of_cell(cell:Vector3i)->Vector3:
	return map_to_local(cell) + Vector3.UP * cell_size.y

## Sets an initial value for every cell, if override is true, it resets any previously defined cell
func initialize_cells(cells:Array[Vector3i], override:bool=false):
	for cell in cells:
		if not cellDict.has(cell) or override:
			cellDict[cell] = []


func get_all_in_cells(targets:Array[Vector3i], what:Searches=Searches.UNIT)->Array:
	match what:
		Searches.UNIT:
			var units:Array
			for target in targets:
				var unitInCell:Unit = search_in_tile(target,Searches.UNIT)
			return units
	return []

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_click"):
		var mouseIntersect = objectPicker.get_from_mouse(Picker3D.QueriedInfo.POSITION)
		if not mouseIntersect is Vector3: 
			return
		else:
			mouseIntersect = local_to_map(mouseIntersect)
			emit_signal("cell_clicked", mouseIntersect)
			if is_cell_marked(mouseIntersect): emit_signal("marked_cell_clicked", mouseIntersect)
	
