extends Resource
class_name Map

const USER_FOLDER: String = Global.FolderPaths.USER + "Maps/"
const RES_FOLDER: String = "res://Singletons/Board/Map/"

enum GenerationModes {
	NONE,
	SURFACE,
	CAVES,
}

@export var identifier: String
@export var background: Texture

@export_category("Cells")
@export var cell_terrain_resources: Array[TerrainCell]
@export var cell_positions: Array[Vector4i]
@export var cell_faction_spawn: Array[Vector4i]

@export_category("Meta")
@export var display_name: String  
@export var description: String
@export var icon: Texture = preload("res://Assets/Tiles2D/MovementMark.png")

@export_category("Auto Generation")
@export var generation_mode: GenerationModes = GenerationModes.NONE
@export var generation_size: Vector3i
@export_range(0, 1, 0.01) var generation_terrain_height_percentage: float
@export var generation_noise_override: FastNoiseLite
@export var generation_noise_type: FastNoiseLite.NoiseType
@export_range(0.1, 1, 0.02) var generation_noise_frequency: float
@export var generation_noise_seed: int

static var identifier_to_map_cache_dict: Dictionary

var mesh_library_cache: MeshLibrary

func update_mesh_library():
	var mesh_lib := MeshLibrary.new()
	assert(cell_terrain_resources.size() > 1)
	var index: int = 0
	for cell: TerrainCell in cell_terrain_resources:
		
		mesh_lib.create_item( index )
		mesh_lib.set_item_name(index, cell.display_name)
		
		if not cell.mesh:
			var auto_mesh := ImmediateMesh.new()
			mesh_lib.set_item_mesh(index, auto_mesh)
		else:
			mesh_lib.set_item_mesh(index, cell.mesh)
		
		if not cell.shape:
			var auto_shape := BoxShape3D.new()
			auto_shape.size = Board.cell_size * 0.95
			mesh_lib.set_item_shapes(index, [auto_shape, Transform3D.IDENTITY])
		else:
			mesh_lib.set_item_shapes(index, [cell.shape, Transform3D.IDENTITY])
		
		index += 1
		
	mesh_library_cache = mesh_lib


func generate():
	if generation_mode == GenerationModes.NONE:
		return
	
	## Try to use the override, otherwise create a new noise
	var used_gen_noise: FastNoiseLite = generation_noise_override
	if not used_gen_noise: 
		used_gen_noise = FastNoiseLite.new()
		used_gen_noise.frequency = generation_noise_frequency
		used_gen_noise.noise_type = generation_noise_type
		used_gen_noise.seed = generation_noise_seed
		
	## Get terrain for standing on
	var footing_terrain: Array[int]
	for index: int in cell_terrain_resources.size():
		var terrain_res: TerrainCell = cell_terrain_resources[index]
		if Board.CellFlags.FOOTING in terrain_res.flags:
			footing_terrain.append(index)
			
	## Make the last cell empty air
	var air_terrain_index: int

	var air_terrain := TerrainCell.new()
	air_terrain.display_name = "Air"
	air_terrain_index = cell_terrain_resources.size()
	cell_terrain_resources.append(air_terrain)
		
	match generation_mode:
		GenerationModes.SURFACE:
			var max_height: int = generation_size.y * generation_terrain_height_percentage
			for x: int in generation_size.x:
				
				for z: int in generation_size.z:
					var noise_value: float = used_gen_noise.get_noise_2d(x,z)
					assert(noise_value <= 1)
					var top_y: int = max_height * noise_value
					
					for y: int in generation_size.y:
						
						if y <= top_y or y == 0:
							cell_positions.append(Vector4i(x, y, z, footing_terrain[0]))
						else:
							cell_positions.append(Vector4i(x, y, z, air_terrain_index))
	pass


static func cache_all_map_paths():
	var found_resource_paths: Array[String] = []
	found_resource_paths.append_array(Utility.LoadFuncs.get_all_resource_paths_in_folder(RES_FOLDER)) 
	found_resource_paths.append_array(Utility.LoadFuncs.get_all_resource_paths_in_folder(USER_FOLDER)) 
	
	for res_path: String in found_resource_paths:
		var res: Resource = load(res_path)
		if res is Map:
			identifier_to_map_cache_dict[res.identifier] = res
	
	
static func get_map_resource_by_identifier(identifier: String) -> Map:
	if identifier_to_map_cache_dict.is_empty():
		cache_all_map_paths()
		
	var map_path: String = identifier_to_map_cache_dict.get(identifier, "")
	
	if map_path == "":
		push_warning("No path for map found with identifier '{0}'".format([identifier]))
		return
	
	var map_res: Map = load(map_path)
	return map_res
	

func get_all_cell_positions() -> Array[Vector3i]:
	var output: Array[Vector3i]
	for pos: Vector4i in cell_positions:
		output.append(Vector3i(pos.x, pos.y, pos.z))
	return output
	
	
func get_faction_ids() -> Array[int]:
	var present_ids: Dictionary
	for spawn: Vector4i in cell_faction_spawn:
		present_ids[spawn.w] = true
		
	var arr: Array[int]
	arr.assign(present_ids.keys())
	return arr
	

func get_faction_capacity() -> int:
	return get_faction_ids().size()
	

func get_terrain_cell_at_pos(pos: Vector3i) -> TerrainCell:
	var terrain_cell_index: int
	
	for vector: Vector4i in cell_positions:
		if vector.x == pos.x and vector.y == pos.y and vector.z == pos.z:
			return cell_terrain_resources[vector.w]
	
	return null
				

func is_faction_spawns_valid() -> bool:	
	var cell_pos_arr: Array[Vector3i] = get_all_cell_positions()
	for spawn: Vector4i in cell_faction_spawn:
		var position: Vector3i = Vector3i(spawn.x, spawn.y, spawn.z)
		#var spawn_id: int = spawn.z
		
		if not position in cell_pos_arr:
			push_error("Spawn mismatch at position " + str(position))
			return false
	return true
		

func save_map():
	pass
