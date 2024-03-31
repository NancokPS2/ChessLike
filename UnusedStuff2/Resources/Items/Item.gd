extends Resource
class_name Item

#const equipmentTypes = Const.equipmentTypes

#@export (equipmentTypes) var type
enum ItemTypes {WEAPON, CONSUMABLE, ARMOR, ACCESSORY, OTHER}
@export var itemType:ItemTypes
@export var internalName:String
#@export var resCategory:String
@export var displayName:String
@export var abilityList:Array[Ability]

## Items will generally reduce their amount before being outright removed
@export var uses:int


@export var texture:Texture
@export var model:PackedScene = load("res://Assets/Meshes/Weapons/Dagger/Dagger.tscn")
@export var wornModel:PackedScene
@export var useAbilityScript:Script


func _init() -> void:
	pass

func get_model()->Node3D:
	return model.instantiate()

func get_body_model()->Node3D:
	return wornModel.instantiate()
	
func use():
	pass
	
func get_abilities(character:CharAttributes)->Array[Ability]:	
	var abilArr:Array[Ability] = abilityList
	var useAbility := get_item_use_ability(character)
	abilArr.append(useAbility)
	return abilArr
	
func get_item_use_ability(character:CharAttributes)->Ability:
	if not useAbilityScript is Script: push_error("No valid useAbilityScript has been assigned to this Item."); return null
	var ability:=Ability.new()
	ability.set_script(useAbilityScript)
	ability.set("weapon", self)
	if not ability.get("weapon") == self: push_error("Could not set the weapon property in the script, it may not have such property."); return null
	ability.user = character.user
	return ability
	
