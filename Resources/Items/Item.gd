extends Resource
class_name Item


#const equipmentTypes = Const.equipmentTypes

#@export (equipmentTypes) var type
@export var internalName:String
@export var resCategory:String
@export var displayName:String

@export var sprite:Texture
@export var model:PackedScene = load("res://Assets/CellMesh/Weapons/Dagger/Dagger.tscn")

func use():
	pass

func _init() -> void:
	setup()
	
func setup():
	pass
