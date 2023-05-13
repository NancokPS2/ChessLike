extends Node3D
class_name Unit


@export var saveName:String
@export var attributes:CharAttributes = CharAttributes.new() #UnitAttributes (stats)
var inventory:Inventory
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "stand"

var isUnit:bool = true

signal moving
signal moved(where:Vector3i)

signal acting
signal acted

#signal acted_upon
signal was_targeted(withWhat:Ability)
signal targeting(what:Vector3i, withWhat:Ability)

signal turn_started
signal turn_ended

#const limbs:Dictionary = {
#	"HEAD":"Head",
#	"TORSO":"Torso",
#	"HAND_L":"HandL",
#	"HAND_R":"HandR",
#	"FOOT_L":"FootL",
#	"FOOT_R":"FootR",
#}
enum limbs {HEAD,TORSO,HAND_L,HAND_R,FOOT_L,FOOT_R}

	
#Possible parameters user, flags
func targeted_with_action(parameters:Dictionary):
	emit_signal("acted_upon",parameters)
	pass

func start_turn():
	attributes.stats.actions = attributes.stats.actionsMax
	attributes.stats.moves = attributes.stats.movesMax
	
func end_turn():
	var UI = Ref.UITree
	emit_signal("turn_ended")
	
	for x in CVars.unitsInPlay:#Adjust delays
		x.attributes.lower_turn_delay_remaining(attributes.turnDelayRemaining)
	attributes.reset_turn_delay()
	
	CVars.refUnitInAction = UI.get_node("TurnManager").get_participant_with_lowest_delay(CVars.unitsInPlay)#Set unit with lowest delay as new turn owner
	CVars.refCombatField.align_to_grid(CVars.refUnitInAction)
	
	if CVars.refUnitInAction.attributes.faction.identifier == CVars.playerFaction:#Enable/Disable controls
		UI.get_node("Controller").visible = true
	else:
		UI.get_node("Controller").visible = false
	UI.get_node("TurnManager").populate_list(CVars.unitsInPlay)
	CVars.refUnitInAction.emit_signal("turn_started")
	CVars.refUnitInAction.canUndo = true #Let it Undo their movement
		
#func weapon_attack(hand:int,target:Unit):
#	if inventory.equipped[hand] is Weapon:
#		var weaponUsed = inventory.equipped[hand]
#		weaponUsed.attack(target)
#	else:
#		push_error(attributes.name + " tried to attack with " + inventory.equipped[hand].get_class())
	



class Generator:

	
	static func build_from_attributes(attrib:Resource):
		var unit = Const.UnitTemplate.instantiate()#Create an instance
		unit.attributes = attrib#Set it's attributes
		unit.attributes.basic_setup()#Perform loading and stat calculation of attributes
		unit.update_from_attributes()#Get the stats for unit from it's attributes
		assert(not unit.info.is_empty())
		return unit
		
	static func generate_new(nickName:String,charRace:String,charClass:String,charFaction:String="DEFAULT"):
		var charAttribs = CharAttributes.new()
		charAttribs.unitRace = charRace
		charAttribs.unitClass = charClass
		charAttribs.unitFaction = charFaction
		return build_from_attributes(charAttribs)
