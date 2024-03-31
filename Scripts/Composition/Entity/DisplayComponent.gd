extends Node3D
class_name ComponentDisplay

enum BodyParts {
	HEAD,
	UPP_ARM_L,
	UPP_ARM_R,
	LOW_ARM_L,
	LOW_ARM_R,
	HAND_L,
	HAND_R,
	UPP_LEG_L,
	UPP_LEG_R,
	LOW_LEG_L,
	LOW_LEG_R,
	FOOT_L,
	FOOT_R,
	}
## TODO
enum Animations {
	IDLE,
	HURT,
	WALKING,
}

const COMPONENT_NAME: StringName = "ENTITY_DISPLAY"

const DEFAULT_MODEL: PackedScene = preload("res://Assets/Meshes/Characters/Human.tscn")

var body_part_dict: Dictionary
var mesh_arr: Array[MeshInstance3D]
var temporary_nodes: Dictionary

var model_boundaries_cache: AABB

func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	## Default behaviour
	if get_children().is_empty():
		load_model(DEFAULT_MODEL)


func get_entity() -> Entity3D:
	return get_parent()


## TODO
func play_animation(anim: Animations):
	print_debug("Playing animation: " + Animations.find_key(anim))
	
	match anim:
		Animations.IDLE:
			pass


func load_model(scene: PackedScene):
	var instance: Node = scene.duplicate().instantiate()
	assert(instance is Node3D)
	add_child(instance)
	update_model()


func update_model():
	## Update body parts
	body_part_dict.clear()
	mesh_arr.clear()
	
	var all_children: Array[Node] = find_children("*", "Node3D", true, false)
	for node: Node in all_children:
		
		if node is MeshInstance3D:
			mesh_arr.append(node)
		## Check if it is a valid part.
		if BodyParts.get(node.name, null) is BodyParts:
			var index: int = BodyParts[node.name]
			body_part_dict[index] = node
	
	model_boundaries_cache = get_model_boundaries()
	adjust_position_to_cell_top()
	adjust_size_to_cell_size()


func adjust_position_to_cell_top():
	var model_bottom: Vector3 = (
		Vector3.DOWN * (model_boundaries_cache.end.y + (1 / get_child(0).scale.y)) 
		)
	position.y = (Board.cell_size.y / 2) + (model_bottom.y)


func adjust_size_to_cell_size():
	var longest_side: float = model_boundaries_cache.get_longest_axis_size()
	
	var model_to_cell_size_ratio: float = (
		longest_side / Board.cell_size.x
	)
	var adjusted_ratio: float = 1 / model_to_cell_size_ratio
	
	get_child(0).scale = Vector3.ONE * adjusted_ratio


func get_model_boundaries() -> AABB:
	var output: AABB
	for mesh_inst: MeshInstance3D in mesh_arr:
		for point: Vector3 in mesh_inst.mesh.get_faces():
			output = output.expand(point + mesh_inst.position)
			
	return output


func add_temporary_node(category: String, node: Node3D, node_pos: Vector3 = Vector3.ZERO):
	temporary_nodes[category] = temporary_nodes.get(category, []) + [node]
	
	node.top_level = true
	add_child(node)
	node.global_position = node_pos
	
	
func clear_temporary_nodes(category: String):
	for node: Node3D in temporary_nodes:
		temporary_nodes[category].erase(node)
		node.queue_free()
	

func get_temporary_nodes(category: String) -> Array[Node]:
	return temporary_nodes.get(category, [])


func add_visibility_meshes_in_cells(cells: Array[Vector3i], color: Color = Color.TRANSPARENT, texture: Texture = null):
	const CATEGORY: String = "VISIBLE_CELLS_MESHES"
	
	## Delete any existing meshes
	clear_temporary_nodes(CATEGORY)
	
	## If transparent, end after removing the old meshes, don't do anything else.
	if color == Color.TRANSPARENT:
		return
	
	## Create the material and mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.albedo_texture = texture
	
	var mesh := BoxMesh.new()
	mesh.size = Board.cell_size * 0.2 #Vector2(Board.cell_size.x, Board.cell_size.z) / 4
	mesh.material = material
	
	## Create the MultiMesh
	var multi_mesh := MultiMesh.new()
	multi_mesh.mesh = mesh
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.instance_count = cells.size()
		
	## Set the positions
	var index: int = 0
	for cell: Vector3i in cells:
		var offset: Vector3 = Vector3.ZERO #((Vector3.DOWN * Board.cell_size.y) / 3)
		var instance_pos: Vector3 = Board.map_to_local(cell) + offset
		print(instance_pos)
		multi_mesh.set_instance_transform(index, Transform3D.IDENTITY.translated(instance_pos))
		#multi_mesh.set_instance_color(index, color)
		index += 1
	
	## Create the node and add it
	var multi_mesh_inst := MultiMeshInstance3D.new()
	multi_mesh_inst.multimesh = multi_mesh
	multi_mesh_inst.top_level = true
	add_temporary_node(CATEGORY, multi_mesh_inst)
		
	
