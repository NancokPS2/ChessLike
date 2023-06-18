extends Resource
class_name Faction

@export var displayName:String
@export var description:String
@export var internalName:String
@export var icon:Texture
@export var color:Color = Color.BROWN
@export var hostiles:Array[String]
@export var friendlies:Array[String]

@export var existingUnits:Array[CharAttributes]

func is_friendly_with(faction:Faction):
	if friendlies.has(faction.internalName): return true
	else: false

