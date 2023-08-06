extends Resource
class_name AttributesBase

signal attributes_updated

signal stat_changed(stat:String)

enum MovementTypes {
	WALK, #Simple ground movement
	FLY, #Ignore most movement restrictions
	HOVER, #Ignore most movement costs except height 
	HEAVY_WALK, #Special kind of walk, meant for extra restrictions 
	SWIM, #Water only 
	AMPHIBIOUS, #Water and land
	TELEPORT, #Ignore all restrictions except for tiles it may not land on.
	}

const StatNames:Dictionary = {
	HEALTH = "health",
	ENERGY = "energy",
	TURN_DELAY = "turnDelay",
	ACTIONS = "actions",
	MOVES = "moves",
	#Primary
	HEALTH_MAX = "healthMax",
	ENERGY_MAX = "energyMax",
	STRENGTH = "strength",
	AGILITY = "agility",
	MIND = "mind",
	SPECIAL = "special",
	MOVE_DISTANCE = "moveDistance",
	DEFENSE = "defense",
	DODGE = "dodge",
	ACCURACY = "accuracy",
	#Secondary
	TURN_DELAY_MAX = "turnDelayMax",
	ACTIONS_MAX = "actionsMax",
	MOVES_MAX = "movesMax",
	MOVEMENT_TYPE ="movementType",
	}


@export var attributeResources:Array[AttributesBase]
@export var abilities:Array[Ability]
@export var equipmentSlots:Array[String] = ["ARMOR","L_HAND","R_HAND","ACC1","ACC2","ACC3"]

@export_group("Visuals")
@export var internalName:String
@export var displayName:String = "ERR_NONAME"
@export var model:PackedScene = load("res://Assets/Meshes/Characters/Human.tscn")


@export_group("Stats")
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
	"strength":100,
	"agility":100,
	"mind":100,
	"special":0,
	"moveDistance":10,
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


func set_stat(stat:String, newValue:int, base:bool = false):
#	if not (changeAmount is int or changeAmount is float): push_error("Invalid value type."); return
	if not stats.has(stat): push_error("Non existent stat."); return
	var statVarName = "baseStats" if base else "stats"
	
	match stat:
		StatNames.HEALTH:
			newValue = clamp(newValue, -999, stats[StatNames.HEALTH_MAX] )
			
		StatNames.ENERGY:
			newValue = clamp(newValue, -999, stats[StatNames.ENERGY_MAX] )

		StatNames.TURN_DELAY:
			newValue = clamp(newValue, -999, stats[StatNames.TURN_DELAY_MAX] )

		StatNames.ACTIONS:
			newValue = clamp(newValue, 0, stats[StatNames.ACTIONS_MAX] )

		StatNames.MOVES:
			newValue = clamp(newValue, 0, stats[StatNames.MOVES_MAX] )
			
		_:
			push_error("Cannot handle this stat from this method!")
			
	get(statVarName)[stat] = newValue
	stat_changed.emit(stat)

func change_stat(stat:String, amount:int, base:bool = false):
#	if not (changeAmount is int or changeAmount is float): push_error("Invalid value type."); return
	if not stats.has(stat): push_error("Non existent stat."); return
	
	set_stat(stat, get_stat(stat)+amount, base)

func get_stat(stat:String, base:bool = false):
	if not stats.has(stat): push_error("Non existent stat."); return
	var statVarName = "baseStats" if base else "stats"
	
	return get(statVarName)[stat]
	

#func combine_attributes(attribArray:Array[AttributesBase] = attributeResources):
#	#Add stats
#	for stat in stats:
#		var statSum:int = stats[stat]
#		#Sum from each attribute
#		for attrib in attribArray:
#			statSum += attrib.stats[stat] 
#
#		stats[stat] = statSum / ( max(attribArray.size(),1) )
#
#	#Equipment slots
#	for attrib in attribArray:
#		for slot in attrib.equipmentSlots:
#			if not equipmentSlots.has(slot): equipmentSlots.append(slot)
#
#	#Abilities
#	for attrib in attribArray:
#		for ability in attrib.abilities:
#			if not abilities.has(ability): abilities.append(ability)
#	attributes_updated.emit()

func combine_attributes_base_stats(attribArray:Array[AttributesBase] = attributeResources, includeSelf:bool=false):
	var _attribArray:Array[AttributesBase] = attribArray.duplicate()
	
	var raceRes = get("raceAttributes")
	var classRes = get("classAttributes")
	if raceRes is AttributesBase: _attribArray.append(raceRes) 
	if classRes is AttributesBase: _attribArray.append(classRes) 
	
	assert(not _attribArray.is_empty())
	#Add stats
	
	if includeSelf: _attribArray.append(self)
	for stat in baseStats:
		#Sum from each attribute to average
		var statAverage:int
		for attrib in _attribArray:
			statAverage += attrib.baseStats[stat] 
			
		statAverage = statAverage / ( max(_attribArray.size(),1) )
		baseStats[stat] = statAverage
		
	#Equipment slots
	for attrib in attribArray:
		for slot in attrib.equipmentSlots:
			if not equipmentSlots.has(slot): equipmentSlots.append(slot)
			
	#Abilities
	for attrib in attribArray:
		for ability in attrib.abilities:
			if not abilities.has(ability): abilities.append(ability)
	attributes_updated.emit()
