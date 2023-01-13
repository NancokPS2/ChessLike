extends Spatial
class_name Unit


export (String) var saveName
export (Resource) var attributes = CharAttributes.new() #UnitAttributes (stats)
var inventory:Inventory
var facing:int = 0#Temp value
#var attributes:UnitAttributes
var requiredAnimationName:String = "stand"

var isUnit:bool = true

signal moving
signal moved

signal acting
signal acted

signal acted_upon

signal turn_started
signal turn_ended

var stats:Dictionary
var info:Dictionary
var faction

var abilities


var equipment:Dictionary

#const limbs:Dictionary = {
#	"HEAD":"Head",
#	"TORSO":"Torso",
#	"HAND_L":"HandL",
#	"HAND_R":"HandR",
#	"FOOT_L":"FootL",
#	"FOOT_R":"FootR",
#}
enum limbs {HEAD,TORSO,HAND_L,HAND_R,FOOT_L,FOOT_R}


func update_from_attributes():#Retrieves all info from it's attributes
	stats = attributes.stats#Load stats
	info = attributes.info#Load info
	abilities = attributes.abilities
	faction = attributes.faction

	for slot in attributes.equipment:#Load equipment
		if slot != "":#If the slot is not empty
			equipment[slot] = ResList.get_resource(attributes.equipment[slot],"equipment")
			
	for ability in abilities:
		ability.equip(self)
	
func change_stat(stat:String,amount:int,flags:int=0):
	match stat:
		"health":
				var defense:int = stats.defense
				var damage:int = amount
				if flags && Const.attackFlags.WEAK_VS_ARMOR:
					defense = defense*1.5
				elif flags && Const.attackFlags.HALF_ARMOR:
					defense = defense/2
				elif flags && Const.attackFlags.IGNORE_ARMOR:
					defense = 0
				stats.health += damage - defense
				get_node("StatusNumber").text = str(damage-defense)
				get_node("VFX").play("Took Damage")
				if stats.health <= 0:
					emit_signal("health_depleted")
		_:
				stats[stat] += amount

	
#Possible parameters user, flags
func targeted_with_action(parameters:Dictionary):
	emit_signal("acted_upon",parameters)
	pass

#func use_ability(abilityInUse:Ability):
#	var parametersUsed:Dictionary
#	var targets:Array	
##	if not passive:#Is active ability?
##		for x in attributes.activeAbilities:
##			if x.identifier == abilityIdentifier:
##				abilityInUse = x
##	else:#Is passive ability?
##		for x in attributes.passive:
##			if x.identifier == abilityIdentifier:
##				abilityInUse = x
##	abilityInUse._ready()
#
#	if abilityInUse.targetingMode == abilityInUse.TargetingMode.SINGLE:
#		pass
#
#	if abilityInUse.parameters && abilityInUse.ParametersReq.USED_WEAPON:#Lists weapons and waits for a choice
#		var weapons:Array
#		var UIController = CVars.refUITree.get_node("Controller")
#		var equippedGear:Array = inventory.equipped
#
#		for x in equippedGear:#Get all equipped weapons
#			if x != null and x.equipmentType == Const.equipmentTypes.WEAPON:
#				var weaponDict:Dictionary
#				weaponDict["name"] = "Weapon"
#				weaponDict["text"] = x.displayName
#				weaponDict["variant"] = x
#				weapons.append(weaponDict)
#
#		if weapons.empty():#If there are no weapons, cancel the attempt
#			push_error(attributes.unitName + " tried to show it's equipped weapons, but it didn't have any.")
#			return
#
#		CVars.controlState = CVars.controlStates.MENU_CHOICE#Signal that a choice is being expected
#		UIController.misc_update(weapons)
#
#		parametersUsed[abilityInUse.ParametersReq.USED_WEAPON] = yield(UIController,"button_with_variant_pressed")
#
#	if abilityInUse.parameters && abilityInUse.ParametersReq.TARGET_UNIT:#Awaits to choose a suitable tile to target
#		var field = CVars.refCombatField
#		var rangeUsed:int
#
#		if abilityInUse.parameters.has(Const.abilityParameters.CHOOSE_WEAPON):#Decide the range
#			rangeUsed = parametersUsed["CHOOSE_WEAPON"].weaponRange
#		else:
#			rangeUsed = abilityInUse.abilityRange
#
#		CVars.controlState = CVars.controlStates.TARGETING
#		field.mark_area(Const.areaShapes.STAR, field.get_coordinates_on_grid(self),1,rangeUsed)
#
#		parametersUsed["TARGET_UNIT"] = yield(CVars.refCombatField,"tile_selected")#Acquire a target
#		field.clear()#Target acquired, clean tiles
#
#		if abilityInUse.abilityFlags && Ability.AbilityFlags.HOSTILE:#Tell the target about the attack
#			parametersUsed["TARGET_UNIT"].emit_signal("before_attack", {"aggressor":null,"ability":abilityInUse})
#
#	yield(abilityInUse.use(parametersUsed),"ability_finalized")

func start_turn():
	stats.actions = stats.actionsMax
	stats.moves = stats.movesMax
	
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
		var unit = Const.UnitTemplate.instance()#Create an instance
		unit.attributes = attrib#Set it's attributes
		unit.attributes.basic_setup()#Perform loading and stat calculation of attributes
		unit.update_from_attributes()#Get the stats for unit from it's attributes
		assert(not unit.info.empty())
		return unit
		
	static func generate_new(nickName:String,charRace:String,charClass:String,charFaction:String="DEFAULT"):
		var charAttribs = CharAttributes.new()
		charAttribs.unitRace = charRace
		charAttribs.unitClass = charClass
		charAttribs.unitFaction = charFaction
		return build_from_attributes(charAttribs)
