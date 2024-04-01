extends Resource
class_name ComponentActionResourceEffect

@export var type: ComponentAction.EffectTypes
@export var parameters: Array = ["",1,1,1]

func start():
	pass

func step_cell(cell: Vector3i):
	pass

func step_entity(cell: Vector3i):
	pass

func finish(all_cells: Array[Vector3i]):
	pass
