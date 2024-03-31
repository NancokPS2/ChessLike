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

enum CellDataKeys {
	EXISTS,
	FLAGS,
	FACTION_SPAWN_ID,
	DISPLAYED_NAME,
	SUB_MESH,
}
enum AreaTypes {FLOOD, STAR, CONE, ALL, FLOOD_2D}
enum CellIDs {TARGETING, BLUE, YELLOW, GREEN, PINK, BROWN, SKYBLUE, GREY, RED}
enum Searches {UNIT, OBSTACLE, ANYTHING, TAG, ALL_OBJECTS}

const DEFAULT_MAP_PATH: String = "res://Singletons/Board/DefaultMap.tres"

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

## Flags let other systems figure out how to react to each cell.
## If no flags are present, it should be treated as empty air to fly trough
## Examples of applications:
## Lava stream: UNPASSABLE, LIQUID, HOT x 10 (cannot move trough it, and you cannot stand on it either)
## Smoke: OPAQUE
## Grass: FOOTING, COVER, OPAQUE, IMPASSABLE, SOFT
## Webs: DENSE
## Giant webs: DENSE, UNSTABLE, SOFT
## Scattered pebbles: UNSTABLE, HARD
## Water: LIQUID, DENSE, SOFT
## Slime: IMPASSABLE, UNSTABLE, SOFT, FOOTING
enum CellFlags {
	FOOTING, #Can stand on TOP of this cell, without this flag the cell can still be jumped or flown across
	COVER, #Blocks direct targeting
	OPAQUE, #Blocks line of sight
	IMPASSABLE, #Blocks movement
	LIQUID, #Can swim trough it
	DENSE, #Cannot fly or hover trough it
	UNSTABLE, #Walking movement is slowed. Can be stacked. Affects entities on top
	HARD, #Affects fall damage. Affects entities standing on top
	SOFT, #Affects fall damage. Affects entities standing on top
	NOISY, #Stealthed character are revealed when traversing it
	HOT, #Deals fire damage. Can be stacked
	FROZEN, #Dals cold damage. Can be stacked
	HARMFUL, #Deals neutral damage. Can be stacked
}

const DEFAULT_GROUND_FLAGS: Array[CellFlags] = [
	CellFlags.FOOTING, CellFlags.OPAQUE, CellFlags.COVER, CellFlags.IMPASSABLE
]

## Stores references to objects added to the GridMap
var cell_object_dict: Dictionary
## Stores metadata of cells
var cell_data: Dictionary

## Forcefully disables inputs if false
var input_enabled: bool = true
## Last cell that was selected
var cell_hovered_cache: Vector3i = INVALID_CELL_COORDS

func _ready() -> void:
	var map_to_use: Map = load(DEFAULT_MAP_PATH)
	assert(map_to_use is Map)
	build_from_map(map_to_use)

			
func _unhandled_input(event: InputEvent) -> void:
	## The cursor moved, try to get a new cell from it
	if event is InputEventMouseMotion:
		var camera: Camera3D = get_viewport().get_camera_3d()
		var ray_params := PhysicsRayQueryParameters3D.create(camera.global_position, camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000)
		var pos: Vector3 = get_world_3d().direct_space_state.intersect_ray(ray_params).get("position", Vector3(INVALID_CELL_COORDS))
		var new_cell: Vector3i = local_to_map(pos)
		
		## If an impassble cell was hovered, select the one on top.
		if is_flag_in_cell(new_cell, CellFlags.IMPASSABLE):
			new_cell += Vector3i.UP
		
		## Stop if it is the same as before
		if new_cell == cell_hovered_cache:
			return
		
		## Report only if this cell is valid
		if is_cell_in_board(new_cell):
			cell_hovered_cache = new_cell
			Event.BOARD_CELL_HOVERED.emit(cell_hovered_cache)
	
	## A click was done, the last hovered cell is "selected" with index 0
	elif event.is_action_pressed("primary_click"):	
		if is_cell_in_board(cell_hovered_cache):
			Event.BOARD_CELL_SELECTED.emit( cell_hovered_cache, 0 )
	
	## A secondary click was done, the last hovered cell is "selected" with index 1
	elif event.is_action_pressed("secondary_click"):
		if is_cell_in_board(cell_hovered_cache):
			Event.BOARD_CELL_SELECTED.emit( cell_hovered_cache, 1 )
	
	## If it was a "button" input, check if a new direction has been given.
	elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:	
		var input_dir := Vector3(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_down", "move_up"),
			Input.get_axis("move_forward", "move_back")
		)
		if not input_dir.is_zero_approx():
			var new_cell: Vector3i = cell_hovered_cache + Vector3i(input_dir)
			
			## Stop if it is the same as before
			if new_cell == cell_hovered_cache:
				return
			
			## Report only if this cell is valid
			if is_cell_in_board(new_cell):
				cell_hovered_cache = new_cell
				Event.BOARD_CELL_HOVERED.emit(cell_hovered_cache)


func build_from_map(map: Map):
	## Ensure there are enough IDs, rebuild the mesh_library otherwise
	if not map.mesh_library_cache or map.mesh_library_cache.get_item_list().size() != map.cell_terrain_resources.size():
		map.update_mesh_library()
	mesh_library = map.mesh_library_cache
		
	## Place the items and set the TerrainCell data
	for cell_def: Vector4i in map.cell_positions:
		var cell_pos := Vector3i(cell_def.x, cell_def.y, cell_def.z)
		var terrain: TerrainCell = map.get_terrain_cell_at_pos(cell_pos)
		
		data_set(cell_pos, CellDataKeys.EXISTS, true)
		data_set(cell_pos, CellDataKeys.FLAGS, terrain.flags)
		data_set(cell_pos, CellDataKeys.DISPLAYED_NAME, terrain.display_name)
		
		## Due to the use a MeshLibrary, the mesh is fetched trough the ID of the terrain in the Map
		var terrain_index: int = cell_def.w
		set_cell_item_node(cell_pos, terrain_index)
		
		
		
	
	## Place spawns
	if not map.is_faction_spawns_valid():
		push_error("The spawns are not properly set up.")
	for spawn: Vector4i in map.cell_faction_spawn:
		var spawn_pos := Vector3i(spawn.x, spawn.y, spawn.z)
		var cell_id: int = spawn.w
		
		data_set(spawn_pos, CellDataKeys.FACTION_SPAWN_ID, cell_id)
		

func data_set(coordinate: Vector3i, flag_key: CellDataKeys, data):
	var key: String = CellDataKeys.find_key(flag_key)
	cell_data[coordinate] = cell_data.get(coordinate, {})
	cell_data[coordinate][key] = data

	
func data_get(coordinate: Vector3i, flag_key: CellDataKeys, default = null):
	var key: String = CellDataKeys.find_key(flag_key)
	var value = cell_data.get(coordinate, {}).get(key, default)
	return value
	
	
func set_cell_item_node(cell: Vector3i, item_id: int):
	## Item deletion
	if item_id == INVALID_CELL_ITEM:
		var existing_item: Node = cell_object_dict.get(cell, null)
		if is_instance_valid(existing_item):
			existing_item.queue_free()
			
		cell_object_dict.erase(cell)
	
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	mesh_instance.mesh = mesh_library.get_item_mesh(item_id)
	
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	collision_shape.shape = mesh_library.get_item_shapes(item_id)[0]
	
	var item := StaticBody3D.new()
	var flags: Array[CellFlags] = data_get(cell, CellDataKeys.FLAGS, [])
	item.collision_layer = get_flag_collisions(flags)
	item.position = map_to_local(cell)
	item.add_child(mesh_instance)
	item.add_child(collision_shape)
	
	add_child(item)
	
	## If an object is present, delete it.
	var existing_item: Node = cell_object_dict.get(cell, null)
	if is_instance_valid(existing_item):
		existing_item.queue_free()
		
	cell_object_dict[cell] = item


func get_cell_item_node(cell: Vector3i) -> Node:
	return cell_object_dict.get(cell, null)
	

func get_flag_collision_bit(flag: CellFlags) -> int:
	return 1<<flag


func get_flag_collisions(flags: Array[CellFlags]) -> int:
	var output: int = 0
	for flag: CellFlags in flags:
		output = output | get_flag_collision_bit(flag)
	return output
	
	
func get_cell_flags(cell: Vector3i) -> Array[CellFlags]:
	return data_get(cell, CellDataKeys.FLAGS, [])
	

func get_cells_in_area(origin: Vector3i, type: AreaTypes, direction: Vector3i, size: int, height_tolerance: int = 0) -> Array[Vector3i]:
	assert(height_tolerance >= 0, "Tolerance cannot be negative.")
	assert(direction.length() <= 1, "Direction must be normalized.")
	var output: Array[Vector3i] = []
	
	match type:
		AreaTypes.STAR:
			for x: int in range(origin.x - size, origin.x + size):
				for y: int in range(origin.y - size, origin.y + size):
					for z: int in range(origin.z - size, origin.z + size):
						var coord: Vector3i = Vector3i(x, y, z)
						
						## Reduce Z coordinate to account for tolerance.
						var adjusted_coord: Vector3i = coord
						adjusted_coord.z = move_toward(adjusted_coord.z, 0, height_tolerance)
						
						if PositionGrid.get_manhattan_distance(adjusted_coord, origin) <= size:
							output.append(coord)
		
		AreaTypes.CONE:
			var expansion_origin: Vector3i = direction * size
			for x: int in range(origin.x + size + 1):
				for y: int in range(origin.y + size + 1 + height_tolerance):
					for z: int in range(origin.z + size + 1):
						var coord: Vector3i = Vector3i(x, y, z)
						
						## Reduce Z coordinate to account for tolerance.
						var adjusted_coord: Vector3i = coord
						adjusted_coord.z = move_toward(adjusted_coord.z, 0, height_tolerance)
						
						if PositionGrid.get_manhattan_distance(expansion_origin, origin) <= size:
							output.append(coord)
							
		AreaTypes.FLOOD:
			## Start from a cell
			var to_check: Array[Vector3i] = [origin]
			
			#While there are cells to check
			while not to_check.is_empty(): 
				var coord: Vector3i = to_check.pop_back()
				
				## Check that it is a valid spot
				if not is_cell_in_board(coord):
					continue
				if get_manhattan_distance(coord, origin) > size:
					continue
				if coord in output:
					continue
				
				output.append(coord)
				
				## For every adjacent coord 
				for adjacent: Vector3i in ADJACENT_CELLS:
				
					if adjacent in output:
						continue
				
					to_check.append(
						adjacent
					)
			
	for vector: Vector3i in output:
		assert(output.count(vector) == 1, "Duplicate vectors!")
	
	return output


## Uses a Raycast to check if a cell is visible from another cell.
func get_cells_in_line(origin: Vector3i, destination: Vector3i, penetration: int = 1, flags_blocking: Array[CellFlags] = [CellFlags.OPAQUE]) -> Array[Vector3i]:
	var output: Array[Vector3i] = []
	var origin_local: Vector3 = map_to_local(origin)
	var target_locals: Array[Vector3] = [map_to_local(destination)]
	var coll_mask: int = get_flag_collisions(flags_blocking)
	
	#TODO
	var mesh_1 := MeshInstance3D.new()
	mesh_1.mesh = BoxMesh.new()
	mesh_1.mesh.size = Vector3.ONE * 0.1
	mesh_1.global_position = origin_local
	add_child(mesh_1)
	
	var mesh_2 := MeshInstance3D.new()
	mesh_2.mesh = BoxMesh.new()
	mesh_2.mesh.size = Vector3.ONE * 0.1
	mesh_2.global_position = target_locals[0]
	add_child(mesh_2)
	
	for target: Vector3 in target_locals:
		var ray_params := PhysicsRayQueryParameters3D.create(origin_local, target)
		var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
		var exclusions: Array[RID] = []
		
		if not result.get("collider", null) is Object:
			return []
		
		var count: int = 0
		while result.get("collider", null) is Object and count < penetration:
			var cell_at_collision: Vector3i = local_to_map(result.position)
			assert(is_cell_in_board(cell_at_collision))
			
			if not cell_at_collision in output:
				output.append(cell_at_collision)
			
			
			
			exclusions.append(result.get("rid"))
			ray_params = PhysicsRayQueryParameters3D.create(origin_local, target)
			ray_params.exclude = exclusions
			
			result = get_world_3d().direct_space_state.intersect_ray(ray_params)
			count += 1
	
	return output

## Unfinished
#func get_edges_of_cell(cell: Vector3i) -> Array[Vector3]:
	#var cell_origin: Vector3 = map_to_local(cell)
	#var edges: Array[Vector3] = [
		#cell_origin
		##cell_origin + Vector3.UP * (cell_size * 0.45),
		##cell_origin + Vector3.DOWN * (cell_size * 0.45),
		##cell_origin + Vector3.LEFT * (cell_size * 0.45),
		##cell_origin + Vector3.RIGHT * (cell_size * 0.45),
	#]
	#return edges
		

func get_cells_flood_custom(origin: Vector3i, steps: int, filter_call: Callable) -> Array[Vector3i]:
	var output: Array[Vector3i]
	## Start from a cell
	var to_check: Array[Vector3i] = [origin]
	
	var curr_step: int = 0
	
	#While there are cells to check
	while not to_check.is_empty() and curr_step < steps: 
		var coord: Vector3i = to_check.pop_back()
		
		## Check that it is a valid spot
		if not is_cell_in_board(coord):
			continue
		#Probably redundant
		if PositionGrid.get_manhattan_distance(coord, origin, true, false, true) < steps + 1:
			continue
		if coord in output:
			continue
		if not filter_call.call(coord):
			continue
		
		output.append(coord)
		
		## For every adjacent coord 
		for adjacent: Vector3i in ADJACENT_CELLS:
		
			if adjacent in output:
				continue
		
			to_check.append(
				adjacent
			)
			
	for vector: Vector3i in output:
		assert(output.count(vector) == 1, "Duplicate vectors!")
		
	return output


func is_cell_in_board(coord: Vector3i) -> bool:
	return data_get(coord, CellDataKeys.EXISTS, false)
	
	
func is_flag_in_cell(cell: Vector3i, flag: CellFlags) -> bool:
	const EMPTY_ARRAY_INT: Array[int] = []
	var flags: Array[CellFlags] = data_get(cell, CellDataKeys.FLAGS, EMPTY_ARRAY_INT)
	return flag in flags


static func get_manhattan_distance(posA:Vector3i, posB:Vector3i, inc_x: bool = true, inc_y: bool = true, inc_z: bool = true)->int:
	var manhattanDistance:int = 0
	if inc_x: manhattanDistance += abs(posA.x - posB.x) 
	if inc_y: manhattanDistance += abs(posA.y - posB.y) 
	if inc_z: manhattanDistance += abs(posA.z - posB.z)
	return manhattanDistance


func printer(variant):
	print(variant)


func set_cells_from_array(cells:Array[Vector3i], item_id: int):#Sets all cells in the array to the chosen ID
	for pos in cells:
		set_cell_item_node(Vector3i(pos), item_id)


func align_to_grid(object:Object):
	var gridPos:Vector3i = local_to_map(object.position)
	object.translation = map_to_local(gridPos)
