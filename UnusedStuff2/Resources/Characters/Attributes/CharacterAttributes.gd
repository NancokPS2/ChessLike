extends AttributesBase
class_name CharAttributes

signal equipment_changed(newItem:Item)

enum EquipSlots {ARMOR, L_HAND, R_HAND, ACC1, ACC2, ACC3}

#Resources
@export var raceAttributes:RacialAttributes:
	get:
		for attrib in attributeResources:
			if attrib is RacialAttributes: return attrib
		return raceAttributes
		
@export var classAttributes:ClassAttributes:
	get:
		for attrib in attributeResources:
			if attrib is ClassAttributes: return attrib
		return classAttributes

#Equipment
@export var equipment:Dictionary = {
	"ARMOR":"",
	"L_HAND":"",
	"R_HAND":"",
	"ACC1":"",
	"ACC2":"",
	"ACC3":""
	}
	
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

func get_info(infoName:String):
	return info[infoName]

#12 bitsPersonality index r:energetic g:good b:lawful
@export var personalityNumber:Array[int]=[255,255,255]
var personalityColor:Color:
	get:
		if personalityNumber.size()!=3 or personalityNumber.max()>255: push_error("Corrupted personalityNumber!"); return Color.TRANSPARENT
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

		

func _init() -> void:
#	assert(not attributeResources.is_empty())
#	combine_attributes()
	equipment_changed.connect(equipment_update_abilities)
	
func randomize_names(firstNames:Array[String], nickNames:Array[String], lastNames:Array[String]):
	info["firstName"] = firstNames.pick_random() as String
	stats["nickName"] = nickNames.pick_random() as String if randi_range(0,5) > 4 else ""
	info["lastName"] = lastNames.pick_random() as String if randi_range(0,900) > 0 else ""
	
func randomize_personality(energyMin:int=0, energyMax:int=255, goodMin:int=0, goodMax:int=255, lawMin:int=0, lawMax:int=255):
	personalityNumber[0] = randi_range(energyMin,clamp(energyMax,1,255))
	personalityNumber[1] = randi_range(goodMin,clamp(goodMax,1,255))
	personalityNumber[2] = randi_range(lawMin,clamp(lawMax,1,255))
	
func apply_turn_delay(delay:float):
	
	#Reduce delay
	change_stat("turnDelay",-delay)
	
	#If it ended up below 0, apply the remaining amount to the max.
	if stats.turnDelay <= 0:
		stats.turnDelay = stats.turnDelayMax - abs(stats.turnDelay)

func set_equipment(what:Equipment, slot:EquipSlots):
	if not what is Equipment: push_error("Not Equipment"); return
	else: equipment[slot] = what
	
func get_equipment(slot:EquipSlots):
	var item:Equipment = equipment[slot]
	return item if item is Item else null
	
func equipment_update_abilities():
	#Get the attack ability for weapons or other on_use items
	for item in equipment.values():
		assert(item is Equipment)
		for ability in item.abilities:
			add_ability(ability)
		
	#Ensure it has no null values
	assert(abilities.find(null) == -1)

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

#class InventoryManager extends RefCounted:
#
#	var slots:Dictionary
#
#	var attributes:CharAttributes
#	var inventory:Inventory
#
#	func _init(_attributes:CharAttributes, _inventory:Inventory):
#		inventory = _inventory
#		attributes = _attributes
#
	
	
	
