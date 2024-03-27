extends Node3D
class_name Entity3D

enum EntityFlags {
	HEAVY,
	LIGHT,
}

var flags: Array[String]


func has_flag(flag: String) -> bool:
	return flag in flags
	
func set_flag(flag: String):
	pass

func get_grid_pos() -> Vector3i:
	return Board.local_to_map(position)
