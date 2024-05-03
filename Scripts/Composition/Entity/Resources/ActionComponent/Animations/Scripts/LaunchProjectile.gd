extends ComponentActionResourceAnim

@export var projectile_mesh: Mesh

var mesh_instance := MeshInstance3D.new()
var scene_root_ref: Node

func _start():
	scene_root_ref = action_log_cache.entity_source.get_tree().current_scene
	scene_root_ref.add_child(mesh_instance)
	mesh_instance.global_position = action_log_cache.entity_source.global_position

func _run():
	pass

func _finish():
	scene_root_ref = null
