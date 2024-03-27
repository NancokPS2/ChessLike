extends Node3D
class_name Entity3D

func get_grid_pos() -> Vector3i:
	return Board.local_to_map(position)
