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

@export var inventoryContents:Array[Item]

func inventory_add_item(item:Item):
	inventoryContents.append(item)

func inventory_remove_item(item:Item):
	inventoryContents.erase(item)

func is_friendly_with(faction:Faction):
	if friendlies.has(faction.internalName): return true
	else: false

