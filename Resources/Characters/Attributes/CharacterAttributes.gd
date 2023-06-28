extends AttributesBase
class_name CharAttributes

#Resources
@export var raceAttributes:RacialAttributes:
	set(val):
		if raceAttributes is RacialAttributes: attributeResources.erase(raceAttributes)
		raceAttributes = val
		attributeResources.append(val)
		info.raceName = raceAttributes.displayName
#		assert(user)
#		assert(not user)
#		if classAttributes != null:
#			combine_attributes_base_stats()
	get:
		for attrib in attributeResources:
			if attrib is RacialAttributes: return attrib
		return raceAttributes
		
@export var classAttributes:ClassAttributes:
	set(val):
		if classAttributes is ClassAttributes: attributeResources.erase(classAttributes)
		classAttributes = val
		attributeResources.append(val)
		info.className = classAttributes.displayName
#		assert(user)
#		assert(not user)
#		if raceAttributes != null:
#			combine_attributes_base_stats()
	get:
		for attrib in attributeResources:
			if attrib is ClassAttributes: return attrib
		return classAttributes

		
@export var inventory:Inventory
@export var factionIdentifier:String:
	set(val):
		factionIdentifier = val


#var abilities:Array#Both passive and active abilities

#12 bitsPersonality index r:energetic g:good b:lawful
@export var personalityNumber:Array[int]=[255,255,255]

var personalityColor:Color:
	get:
		if personalityNumber.size()!=3 or personalityNumber.max()>255: push_error("Corrupted personalityNumber!"); return Color()
		var red:int = personalityNumber[0]
		var green:int = personalityNumber[1]
		var blue:int = personalityNumber[2]
		
		var color:=Color.BLACK
		color.r8 = red
		color.g8 = green
		color.b8 = blue
		return color

var favoriteColor:Color:
	get:
		return Color((stats.strength/999+100), (stats.agility/999+100), (stats.mind/999+100))

#General
var user:Unit:
	set(val):
		user = val
		for ability in abilities: ability.user = user
		if user is Unit:
			user.ready.connect(combine_attributes_base_stats,CONNECT_ONE_SHOT)
		
var passiveEffects:Array[PassiveEffect]

func _init() -> void:
#	assert(not attributeResources.is_empty())
#	combine_attributes()
	
	pass
	
	



#Info
@export var info:Dictionary = {
	"firstName":"Unnamed",
	"nickName":"Nick",
	"lastName":"",
	"raceName":"no race?",
	"className":"Unemployed",
	"factionIdentifier":"",
	"sex":"Unknown"
}

#Equipment
@export var equipment:Dictionary = {
	"ARMOR":"",
	"L_HAND":"",
	"R_HAND":"",
	"ACC1":"",
	"ACC2":"",
	"ACC3":""
	}
	
func equip(what:Equipment, slot:String):
	if not equipmentSlots.has(slot): push_error("Invalid slot"); return
	else: equipment[slot] = what
	
func randomize_names(firstNames:Array[String], nickNames:Array[String], lastNames:Array[String]):
	info["firstName"] = firstNames.pick_random() as String
	stats["nickName"] = firstNames.pick_random() as String if randi_range(0,2) == 0 else ""
	info["lastName"] = firstNames.pick_random() as String if randi_range(0,9000) == 0 else ""
	
func randomize_personality(energyMin:int=0, energyMax:int=255, goodMin:int=0, goodMax:int=255, lawMin:int=0, lawMax:int=255):
	personalityNumber[0] = randi_range(energyMin,clamp(energyMax,1,255))
	personalityNumber[1] = randi_range(goodMin,clamp(goodMax,1,255))
	personalityNumber[2] = randi_range(lawMin,clamp(lawMax,1,255))
	
func apply_turn_delay(delay:int):
	#Reduce delay
	stats.turnDelay -= delay
	
	#If it ended up below 0, apply the remaining amount to the max.
	if stats.turnDelay <= 0:
		stats.turnDelay = stats.turnDelayMax - abs(stats.turnDelay)
		
func add_passive_effect(passive:PassiveEffect):
	passiveEffects.append(passive)
	passive.setup(user)

func get_faction()->Faction:
	var faction:Faction = ResLoad.get_resource(factionIdentifier,"FACTION")
	return faction if faction is Faction else "Faction {0} not found!".format([factionIdentifier])

class Generator extends RefCounted:
	enum NameType {FIRST_AND_LAST,FIRST_ONLY,MR_LAST,LAST_ONLY}
	func generate_name(attrib:CharAttributes, type:NameType, firstNameList:Array=[],lastNameList:Array=[]):#Use nameType enum
	
		if firstNameList.is_empty():#Failsafe
			firstNameList.append("Tester")
		if lastNameList.is_empty():#Failsafe
			lastNameList.append("Testius")
		
		if type != NameType.FIRST_ONLY or type != NameType.FIRST_AND_LAST:#If it requires a first name...
			attrib.info.firstName = firstNameList[randi() % firstNameList.size()]#randi returns an int between 0 and the size-1
		
		if type != NameType.LAST_ONLY or type != NameType.FIRST_AND_LAST:#If it requires a last unitName...
			attrib.info.lastName += lastNameList[randi() % lastNameList.size()]#randi returns an int between 0 and the size-1
