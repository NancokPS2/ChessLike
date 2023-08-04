extends Node3D
class_name MapEditor

signal map_loaded(map:Map)
signal map_saved(map:Map)

signal cell_hovered(cell:Cell)
signal pos_hovered(pos:Vector3i)

const DEFAULT_MAP_FOLDER:String = "user://SavedMaps/"

@export_category("References")
@export var gridMap:GridMap
@export var picker:Picker3D
@export var cellEditor:CellDataEditor
@export var floorColl:StaticBody3D
@export var itemList:ItemList
@export var instructions:Label
@export var savePath:LineEdit

@export var hoveredCellMarker:MeshInstance3D
@export var firstMarker:MeshInstance3D
@export var secondMarker:MeshInstance3D

@export_category("Others")
@export var mapLoaded:Map = Map.new()
@export var actions:Dictionary = {
	"UP":"editor_up",
	"DOWN":"editor_down",
	"RIGHT":"ui_right",
	"LEFT":"ui_left",
	"FORWARD":"ui_up",
	"BACKWARD":"ui_down",
	"PLACE":"primary_click",
	"REMOVE":"secondary_click",
	"INSPECT":"inspect",
	"MARKER_ONE":"editor_place_marker_one",
	"MARKER_TWO":"editor_place_marker_two",
	"APPLY":"apply"
}


var currentFloor:int

var currentItemID:int:
	set(val):
		if not gridMap.mesh_library is MeshLibrary: push_error("No mesh_library set."); return
		if gridMap.mesh_library.get_item_list().is_empty(): push_error("The mesh_library has no items."); return
		
		currentItemID = clamp(val,0,gridMap.mesh_library.get_item_list().size()-1)

var cellPosHovered:=Vector3i.ZERO:
	set(val):
		if val is Vector3i:
			hoveredCellMarker.position = gridMap.map_to_local(val)
			pos_hovered.emit(val)
			if cellPosHovered != val:
				var cellHovered:Cell = mapLoaded.get_cell_by_pos(val)
#				cellEditor.load_cell( cellHovered )
				if cellHovered is Cell: cell_hovered.emit(cellHovered)
			
		cellPosHovered = val
		
			


func _ready() -> void:
	var changeItemSelected:Callable = func(itemID:int):
		currentItemID = itemID
		
	itemList.item_selected.connect(changeItemSelected)
	update_item_list()
	
	picker.user = self
	picker.forcedCamera = $PivotCamera3D.get_camera()
	
	update_instructions_list()
	

func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseMotion:
#		var posReturned = picker.get_from_mouse(Picker3D.QueriedInfo.POSITION)
#
#		if posReturned is Vector3i: 
#			cellPosHovered = gridMap.local_to_map( posReturned )
	
	#Movement
	if event.is_action_pressed(actions.FORWARD):
		cellPosHovered += Vector3i.FORWARD
	elif event.is_action_pressed(actions.BACKWARD):
		cellPosHovered += Vector3i.BACK
	elif event.is_action_pressed(actions.RIGHT):
		cellPosHovered += Vector3i.RIGHT
	elif event.is_action_pressed(actions.LEFT):
		cellPosHovered += Vector3i.LEFT
	
	#Height
	elif event.is_action_pressed(actions.UP):
		change_floor(currentFloor+1)
	elif event.is_action_pressed(actions.DOWN):
		change_floor(currentFloor-1)
	
	#Cell interaction
	elif cellPosHovered is Vector3i:
		var cellHovered:Cell = mapLoaded.get_cell_by_pos(cellPosHovered)
		#Cell addition and removal
		if event.is_action_pressed(actions.PLACE):
			add_cell(cellPosHovered)
			cellPosHovered = cellPosHovered
			
		elif event.is_action_pressed(actions.REMOVE):
			remove_cell(cellPosHovered)
			cellPosHovered = cellPosHovered
			
		#Markers
		elif event.is_action_pressed(actions.MARKER_ONE):
			place_marker(cellPosHovered, true)
		elif event.is_action_pressed(actions.MARKER_TWO):
			place_marker(cellPosHovered, false)
		
		
		elif cellHovered is Cell:
			if event.is_action_pressed(actions.INSPECT):
				cellPosHovered = cellPosHovered
				
			elif event.is_action_pressed(actions.APPLY):
				apply_changes_to_selected_cells()
				
			
		
func change_floor(newFloor:int):
	currentFloor = newFloor
	var newY:float = currentFloor * gridMap.cell_size.y
	floorColl.position = Vector3(0, newY, 0)
	cellPosHovered.y = currentFloor
	
	pass

func add_cell(pos:Vector3i):
	#If already exists, update it.
	var cellFound:Cell = mapLoaded.get_cell_by_pos(pos)
	if cellFound is Cell:
		cellFound.tileID = currentItemID
		
	#Otherwise
	else:
		var newCell:=Cell.new()
		newCell.position = pos
		newCell.tileID = currentItemID
		newCell.tags = [Map.DefaultCellTags.WALKABLE]
		mapLoaded.add_cell(newCell)
		gridMap.set_cell_item(pos, currentItemID)
	
func remove_cell(pos:Vector3i):
	gridMap.set_cell_item(pos, GridMap.INVALID_CELL_ITEM)
	mapLoaded.cellArray.erase( mapLoaded.get_cell_by_pos(pos) )

func update_item_list():
	itemList.clear()
	print_debug( "Found these items: " + str(gridMap.mesh_library.get_item_list()) )
	for item in gridMap.mesh_library.get_item_list():
		var itemName:String = gridMap.mesh_library.get_item_name(item)
		if itemName == "": itemName = "UNNAMED WITH ID: " + str(item)
		itemList.add_item(itemName)

func place_marker(pos:Vector3i, first:bool, show:bool=true):
	if first:
		firstMarker.position = gridMap.map_to_local(pos)
		firstMarker.visible = show
	else:
		secondMarker.position = gridMap.map_to_local(pos)
		secondMarker.visible = show

func get_cells_from_markers()->Array[Vector3i]:
	var returnedCells:Array[Vector3i]
	var firstMarkerCell:Vector3i = gridMap.local_to_map(firstMarker.position)
	var secondMarkerCell:Vector3i = gridMap.local_to_map(firstMarker.position)
	for x in range(firstMarker.x, secondMarkerCell.x):
		for y in range(firstMarker.y, secondMarkerCell.y):
			for z in range(firstMarker.z, secondMarkerCell.z):
				returnedCells.append(Vector3i(x,y,z))
	return returnedCells
	pass

func update_instructions_list():
	for action in actions:
		instructions.text += action + ": " + str( InputMap.action_get_events(actions[action])[0].as_text() ) + "\n"

func apply_changes_to_selected_cells():
	
	var useMarkers:bool = get_node("%UseMarkers").button_pressed
	if useMarkers:
		for cell in get_cells_from_markers():
			var cellChosen:Cell = mapLoaded.get_cell_by_pos(cellPosHovered)
			if mapLoaded.get_cell_by_pos(cellPosHovered) is Cell:
				cellEditor.update_cell(cellChosen)
	else:
		var cellChosen:Cell = mapLoaded.get_cell_by_pos(cellPosHovered)
		if mapLoaded.get_cell_by_pos(cellPosHovered) is Cell:
			cellEditor.update_cell(cellChosen)
		pass

func save_map(path:String):#path:String=DEFAULT_MAP_FOLDER+"MAP"

	ResourceSaver.save(mapLoaded, path)
	map_saved.emit(mapLoaded)
	
func load_map(path:String):
	var mapToLoad:Map = load(path)
	
	if not mapToLoad is Map: push_error("Not a valid map."); return
	gridMap.clear()

	mapLoaded = mapToLoad
	for cell in mapLoaded.cellArray:
		gridMap.mesh_library = mapLoaded.meshLibrary
		gridMap.set_cell_item(cell.position, cell.tileID)
	map_loaded.emit(mapLoaded)
