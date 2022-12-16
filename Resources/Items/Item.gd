extends Resource
class_name Item


#const equipmentTypes = Const.equipmentTypes

#export (equipmentTypes) var type
export (String) var internalName
export (String) var resCategory
export (String) var displayName

export (Texture) var sprite
export (PackedScene) var model = load("res://Assets/CellMesh/Weapons/Dagger/Dagger.tscn")

func use():
	pass

func _init() -> void:
	setup()
	
func setup():
	pass
