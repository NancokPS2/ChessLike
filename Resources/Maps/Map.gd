extends Resource
class_name Map

enum GenerationMode {
	None,
	Surface,
	Caves,
}
@export var background: Texture

@export_category("Cells")
@export var cell_terrain_resources: Array[TerrainCell]
@export var cell_positions: Array[Vector4i]
@export var cell_faction_spawn: Array[Vector4i]

@export_category("Meta")
@export var display_name: String  
@export var internal_name: StringName
@export var description: String
@export var icon: Texture = preload("res://UnusedStuff/assets/tiles/grass.png")

@export_category("Auto Generation")
@export var generation_mode: GenerationMode
@export var generation_size: Vector3i
@export var generation_height: int
@export var generation_seed: int
@export var generation_noise: FastNoiseLite


var mesh_library_cache: MeshLibrary

func update_mesh_library():
	var mesh_lib := MeshLibrary.new()
	for cell: TerrainCell in cell_terrain_resources:
		var index: int = 0
		
		mesh_lib.create_item( index )
		mesh_lib.set_item_name(index, cell.display_name)
		
		if not cell.mesh:
			var auto_mesh := BoxMesh.new()
			auto_mesh.size = Board.cell_size
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
		

