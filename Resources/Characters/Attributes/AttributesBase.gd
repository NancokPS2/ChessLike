extends Resource
class_name AttributesBase

signal attributes_updated

@export var internalName:String
@export var displayName:String = "ERR_NONAME"

@export var model:PackedScene = load("res://Assets/Meshes/Characters/Human.tscn")

@export var attributeResources:Array[AttributesBase]

@export var abilities:Array[Ability]

@export var equipmentSlots:Array[String] = ["ARMOR","L_HAND","R_HAND","ACC1","ACC2","ACC3"]

@export var baseStats:Dictionary ={
	#Combat only
	"health":100,
	"energy":30,
	"turnDelay":0,
	"actions":1,
	"moves":1,
	#Primary
	"healthMax":100,
	"energyMax":30,
	"strength":0,
	"agility":0,
	"mind":0,
	"special":0,
	"moveDistance":0,
	"defense":0,
	"dodge":0,
	"accuracy":0,
	#Secondary
	"turnDelayMax":100,
	"actionsMax":1,
	"movesMax":1,
	"movementType":0
}

var stats:Dictionary = baseStats

@export var statModifiers:Dictionary ={
	"maxHealth":1.0,
	"maxEnergy":1.0,
	"strength":1.0,
	"agility":1.0,
	"mind":1.0,
	"special":1.0,
	"moveDistance":1.0,
	"defense":1.0,
	"dodge":1.0,
	"accuracy":1.0,
	"turnDelayMax":1.0,
}

func combine_attributes(attribArray:Array[AttributesBase] = attributeResources):
	#Add stats
	for stat in stats:
		var statSum:int = stats[stat]
		#Sum from each attribute
		for attrib in attribArray:
			statSum += attrib.stats[stat] 
			
		stats[stat] = statSum / (attribArray.size()+1)
		
	#Equipment slots
	for attrib in attribArray:
		for slot in attrib.equipmentSlots:
			if not equipmentSlots.has(slot): equipmentSlots.append(slot)
			
	#Abilities
	for attrib in attribArray:
		for ability in attrib.abilities:
			if not abilities.has(ability): abilities.append(ability)
	emit_signal("attributes_updated")
