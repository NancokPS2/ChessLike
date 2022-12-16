extends TileMap

export(PackedScene) var tile_scene
var zoomAmount = Vector2(0.5,0.5)
var selectedUnit = FieldVars.selectedUnitID



func _physics_process(delta):
	$Debug.text = "Click ready: " + str(Globalvars.clickReady)
	if not FieldVars.turnOwnerReference == null:
		$Debug.text = $Debug.text + " | " + "Turn owner: " + FieldVars.turnOwnerReference.stats["name"]

func _process(delta):
	if Input.is_action_pressed("camera_left"):
		position.x += 5
	if Input.is_action_pressed("camera_right"):
		position.x -= 5
	if Input.is_action_pressed("camera_down"):
		position.y -= 5
	if Input.is_action_pressed("camera_up"):
		position.y += 5
		
	for x in get_tree().get_nodes_in_group("UNITS"):
		x.gridCoords = update_obj_coord_on_field(x)
		
	$HoveredTile.position = map_to_world(return_hovered_tile())
	if not FieldVars.selectedUnitReference == null:
		$HoveredUnit.position = FieldVars.selectedUnitReference.position

func _ready():
	$Targeting.copy_parent_shape() #set the shape of the targeting grid
	
	fill_map()#place tiles in the map
	
	$Units.spawnUnits()#create objects for each unit to spawn
	$Units.update_active_units()#update the list with references to each unit
	
	for x in FieldVars.fieldedUnitList:#update units stats
		x.set_pUnit_stats()
		update_unit_internal_coords()
	
	emit_signal("create_portraits")
	
	$Targeting.movement_marking(Vector2(2,1),4)
	pass # Replace with function body.
	
func _input(event):
	if event is InputEventMouseButton && Globalvars.clickReady == true:
		UniversalFunc.click_cooldown()
		
		if FieldVars.combatStage == 0: #Preparation stage
			if event.button_mask == 1:
				place_object_at_coords(FieldVars.selectedUnitReference,return_hovered_tile())
		
		if FieldVars.combatStage == 1: #During combat
			if event.button_mask == 1:
				if FieldVars.combatState == 1: #Attempting to move
					var used_tiles = $Targeting.get_used_cells_by_id(0)
					if used_tiles.find(return_hovered_tile()) != -1:
						place_object_at_coords(FieldVars.turnOwnerReference,return_hovered_tile())
						FieldVars.turnOwnerReference.remainingActs["moves"] =- 1
	
func place_object_at_coords(object:Object,coordinates:Vector2):
	object.position = map_to_world(coordinates)
	
func return_hovered_tile():
	return world_to_map(get_local_mouse_position())

func update_obj_coord_on_field(object):
	return world_to_map(object.position)

func move_unit_to_coords(unit,gridCoords):
	if not unit == null:
		place_object_at_coords(unit,unit.gridCoordinates)
		update_obj_coord_on_field(unit)

func fill_map():
	var mapID = Globalvars.chosenMap
	var loadedMap = Maps.mapList[mapID]
	var mapWidth = loadedMap["width"]
	var designateTileX = 0
	var designateTileY = 0
	for x in loadedMap["tileList"]:
		if designateTileX == mapWidth:
			designateTileX = 0
			designateTileY += 1
		set_cell(designateTileX,designateTileY,x)
		designateTileX += 1
	designateTileX = 0
	designateTileY = 0
	for x in loadedMap["objectList"]:
		if designateTileX == mapWidth:
			designateTileX = 0
			designateTileY += 1
		$Objects.set_cell(designateTileX,designateTileY,x)
		designateTileX += 1

func update_unit_internal_coords():
	for x in FieldVars.fieldedUnitList:
		x.gridCoords = world_to_map(x.position)

