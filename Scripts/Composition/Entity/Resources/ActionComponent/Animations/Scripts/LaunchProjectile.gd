extends ComponentActionResourceAnim

enum AimModes {
	PER_ENTITY,
	PER_CELL,
}

@export var projectile_mesh: Mesh
@export var move_speed: float = 1
@export var aim_mode: AimModes = AimModes.PER_CELL

var mesh_instances: Array[MeshInstance3D]
var scene_root_ref: Node

func _start():
	scene_root_ref = action_log_cache.entity_source.get_tree().current_scene
	var target_positions: Array[Vector3] = []
	match aim_mode:
		AimModes.PER_ENTITY:
			for entity: Entity3D in action_log_cache.targeted_entities:
				target_positions.append(
					action_log_cache.targeted_entities.front().global_position
					)
					
		AimModes.PER_CELL:
			for cell: Vector3i in action_log_cache.targeted_cells:
				target_positions.append(
					Board.map_to_local(cell)
				)
	
	for target: Vector3 in target_positions:
		var instance = MeshInstance3D.new()
		instance.mesh = projectile_mesh
		mesh_instances.append(instance)
		scene_root_ref.add_child(instance)
		
		instance.global_position = action_log_cache.entity_source.global_position
		
		var tween: Tween = instance.create_tween()
		tween.tween_property(
			instance,
			"global_position",
			target, 
			1/move_speed)
		tween.tween_callback(instance.queue_free)
		tween.play()

func _finish():
	mesh_instances.clear()
	scene_root_ref = null
