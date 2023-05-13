extends AttributesBase
class_name CharAttributes

#Resources
@export var raceAttributes:RacialAttributes:
	set(val):
		if raceAttributes is RacialAttributes: attributeResources.erase(raceAttributes)
		attributeResources.append(val)
		info.raceName = raceAttributes.displayName
	get:
		for attrib in attributeResources:
			if attrib is RacialAttributes: return attrib
		return null
		
@export var classAttributes:ClassAttributes:
	set(val):
		if classAttributes is ClassAttributes: attributeResources.erase(classAttributes)
		attributeResources.append(val)
		info.className = classAttributes.displayName
	get:
		for attrib in attributeResources:
			if attrib is ClassAttributes: return attrib
		return null
		
@export var inventory:Inventory
@export var faction:Faction:
	set(val):
		faction = val
		info.factionName = faction.displayName

#var abilities:Array#Both passive and active abilities



#General
var owner


func basic_setup():#Adjusts all values to class and race
	update_stats_and_info()
	
	
func update_stats_and_info():#Replaces stats
	#CLASS
	for attribute in classAttributes.stats:
		stats[attribute] = (classAttributes.stats[attribute] + stats[attribute]) / 2

	for modifier in classAttributes.statModifiers:
		statModifiers[modifier] = (classAttributes.statModifiers[modifier] + statModifiers[modifier]) / 2

enum nameType {FIRST_AND_LAST,FIRST_ONLY,MR_LAST,LAST_ONLY}
func generate_name(type:int,firstNameList:Array=[],lastNameList:Array=[]):#Use nameType enum
	
	if firstNameList.is_empty():#Failsafe
		firstNameList.append("Tester")
	if lastNameList.is_empty():#Failsafe
		lastNameList.append("Testius")
	
	if type != nameType.FIRST_ONLY or type != nameType.FIRST_AND_LAST:#If it requires a first name...
		info.firstName = firstNameList[randi() % firstNameList.size()]#randi returns an int between 0 and the size-1
	
	if type != nameType.LAST_ONLY or type != nameType.FIRST_AND_LAST:#If it requires a last unitName...
		info.lastName += lastNameList[randi() % lastNameList.size()]#randi returns an int between 0 and the size-1

#Info
@export var info:Dictionary = {
	"firstName":"Unnamed",
	"nickName":"Nick",
	"lastName":"",
	"raceName":"no race?",
	"className":"Unemployed",
	"factionName":"",
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
	
