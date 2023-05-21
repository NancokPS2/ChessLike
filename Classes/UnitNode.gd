extends Node3D
class_name Unit


@export var saveName:String
@export var attributes:CharAttributes = CharAttributes.new(): #UnitAttributes (stats)
	set(val):
		attributes = val
		if attributes is CharAttributes: attributes.user = self
			
var inventory:Inventory
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "stand"

var board:GameBoard = Ref.board

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

func get_current_cell()->Vector3i:
	return board.gridMap.local_to_map(position)
	
#Possible parameters user, flags
func targeted_with_action(parameters:Dictionary):
	emit_signal("acted_upon",parameters)
	pass

func start_turn():
	attributes.stats.turnDelay = attributes.stats.turnDelayMax
	attributes.stats.actions = attributes.stats.actionsMax
	attributes.stats.moves = attributes.stats.movesMax
	emit_signal("turn_started")

	
func end_turn():
	var UI = Ref.UITree
	emit_signal("turn_ended")


		
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
		return unit
		
#	static func generate_new(nickName:String,charRace:String,charClass:String,charFaction:String="DEFAULT"):
#		var charAttribs = CharAttributes.new()
#		return build_from_attributes(charAttribs)
