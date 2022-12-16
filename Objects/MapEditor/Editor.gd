extends Node2D



func new_button_pressed() -> void:
	ResourceSaver.save(Const.dirMaps + "EMPTY.tres",Map.new())

func save_button_pressed() -> void:
	var mapToSave:Map = $Grid.get_map_resource()
	
	$CanvasLayer/FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$CanvasLayer/FileDialog.popup()
	
	var path = yield(get_node("CanvasLayer/FileDialog"),"file_selected")#Get the path of the file
	if !path.ends_with(".tres"):#Ensure it has the .tres termination
		path += ".tres"
	
	mapToSave.displayName = $CanvasLayer/MapName.text
	ResourceSaver.save(path,mapToSave)

func load_button_pressed() -> void:
	$CanvasLayer/FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$CanvasLayer/FileDialog.popup()
	
	var mapLoadPath = yield(get_node("CanvasLayer/FileDialog"),"file_selected")#Get the path of the file
	var loadedMap = ResourceLoader.load(mapLoadPath).duplicate()
	$Grid.load_map(loadedMap)
	
	var mapInUse = $Grid.currentMap
	$CanvasLayer/MapName.text = mapInUse.displayName#Update displayed name
	
	if mapInUse.tileSet != null:#Ensure it has a tile list
		push_error("The map lacks a tileset, generating...")
		mapInUse.tileSet = TileSet.new()
	
	
	for e in $CanvasLayer/TileLists.get_children():#Setup tile list
		e.queue_free()
		
	
		
	setup_tile_layers()
		
var tileSelectedID = 0
func _process(delta: float) -> void:
	if Input.is_action_pressed("primary_click"):
		$Grid/Terrain.set_cellv( $Grid.world_to_map(get_local_mouse_position()), tileSelectedID )
		pass

func setup_tile_layers():#Sets up each layer of terrain
	var list = preload("res://Objects/MapEditor/TileList.tscn")#Add the base terrain
	list.set_name("Terrain")
	$CanvasLayer/TileLists.add_child( list.instance() )#Add a tile list
	populate_tile_list("Terrain")
	
	for x in $Grid.currentMap.extraLayers:#Add all other layers
		var itemList = preload("res://Objects/MapEditor/TileList.tscn")
		itemList.set_name(x)
		$CanvasLayer/TileLists.add_child( itemList.instance() )#Add a tile list
		populate_tile_list(x)#Fill it
		
		var terrainLayer = preload("res://Objects/MapEditor/TerrainTemplate.tscn")#Add the terrain layer
		terrainLayer.set_name(x)
		$Grid/Terrain.add_child(terrainLayer)
		
		
		
	
	for x in $CanvasLayer/TileLists.get_children():#Connect all tile lists to the Editor
		x.connect("item_selected",self,"tile_list_clicked")
	pass

func populate_tile_list(layerName:String):
	for x in $Grid.get_node(layerName).get_tileset().get_tiles_ids():
		$CanvasLayer/TileLists.get_node(layerName).add_item($Grid.get_node(layerName).get_tileset().tile_get_name(x), $Grid.get_node(layerName).get_tileset().tile_get_texture(x))

func tile_list_clicked(index: int) -> void:
	tileSelectedID = index
