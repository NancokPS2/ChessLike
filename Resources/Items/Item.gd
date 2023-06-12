extends Resource
class_name Item


#const equipmentTypes = Const.equipmentTypes

#@export (equipmentTypes) var type
@export var internalName:String
@export var resCategory:String
@export var displayName:String

## Items will generally reduce their amount before being outright removed
@export var amount:int 

@export var sprite:Texture
@export var model:PackedScene = load("res://Assets/Meshes/Weapons/Dagger/Dagger.tscn")

func use():
	pass

func _init() -> void:
	setup()
	
func setup():
	pass
