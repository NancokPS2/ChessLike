extends AttributesBase
class_name CharAttributes

#Resources
var raceAttributes:RacialAttributes
var classAttributes:ClassAttributes
var inventory:Inventory
var faction:Faction

var abilities:Array#Both passive and active abilities



#General
var owner
@export var unitRace:String
@export var unitClass:String
@export var unitFaction:String


func basic_setup():#Adjusts all values to class and race
	load_race_attributes(unitRace)
	load_class_attributes(unitClass)
	load_faction(unitFaction)
	update_stats_and_info()
	load_abilities()
#	apply_bonuses_from_equipment()
	

func load_race_attributes(raceIdentifier:String):#Skips raceID if there is a racePath
	raceAttributes = ResList.get_resource(raceIdentifier,"races")
	assert(raceAttributes is RacialAttributes)

func load_class_attributes(classIdentifier:String):
	classAttributes = ResList.get_resource(classIdentifier,"classes")
	assert(classAttributes is ClassAttributes)

func load_faction(factionIdentifier:String):
	faction = ResList.get_resource(factionIdentifier,"factions")
	assert(faction is Faction)
	
	
func update_stats_and_info():#Replaces stats
	#RACE
	for attribute in raceAttributes.stats:#Flat bonuses
		stats[attribute] = raceAttributes.stats[attribute]#Modifiers

	for modifier in raceAttributes.statModifiers:
		statModifiers[modifier] = raceAttributes.statModifiers[modifier]
		
	info.raceName = raceAttributes.displayName
		
	#CLASS
	for attribute in classAttributes.stats:
		stats[attribute] = (classAttributes.stats[attribute] + stats[attribute]) / 2

	for modifier in classAttributes.statModifiers:
		statModifiers[modifier] = (classAttributes.statModifiers[modifier] + statModifiers[modifier]) / 2
	
	#Info
	info.className = classAttributes.displayName
	info.factionName = faction.displayName


func apply_bonuses_from_equipment():
	#apply_bonuses_without_stacking(inventory.get_bonus_attributes_from_equipment())
	pass

func load_abilities():
	abilities.clear()#Prepare everything for loading
	var abilityHolder
	
	for ability in raceAttributes.abilityList:
		abilityHolder = ResList.get_resource(ability,"abilities")
		abilities.append(abilityHolder)
	
	for ability in classAttributes.abilityList:
		abilityHolder = ResList.get_resource(ability,"abilities")
		abilities.append(abilityHolder)
	

enum nameType {FIRST_AND_LAST,FIRST_ONLY,MR_LAST,LAST_ONLY}
func generate_name(type:int,firstNameList:Array=[],lastNameList:Array=[]):#Use nameType enum
	
	if firstNameList.empty():#Failsafe
		firstNameList.append("Tester")
	if lastNameList.empty():#Failsafe
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
	"sex":0
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
	
var combatStatus

		#Temporary Bonuses
var temporaryBonuses:Dictionary

#func apply_bonuses_without_stacking(temporaryBonusDict:Dictionary,sourceID:int=-1):#Needs a dictionary with keys that have the same name as existing attributes
#	if sourceID!=-1 and temporaryBonusProviders.has(sourceID):#If we already have a bonus from this source...
#		print_debug(unitName + " already has bonuses applied from source with RID " + sourceID)
#		return
#	else:
#		apply_bonuses_from_dict(temporaryBonusDict)
#
#func apply_bonuses_from_dict(dictWithBonuses):
#		for x  in dictWithBonuses.keys():
#			if self.get(x) != null: #If there is a stat with the same name as the key...
#				set(x,dictWithBonuses[x])
#				pass
