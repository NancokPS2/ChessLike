extends Ability
class_name AbilityAuto

signal passive_ended(me:AbilityAuto)

##Types of use:
##	Passive: 
##Use _passive_proc to define an effect, usually should target the user. 
##It triggers periodically when the passiveTickSignal in the user is emitted

##	Reaction: 
##Use _reaction_proc to define an effect, triggers when was_targeted is emitted from the user. 
##The incoming ability that targets the user of this ability must have the tags defined in

@export_group("Passive Triggering")#Passives trigger at scheduled intervals
@export var passiveDurationTick:int = 1
@export var passiveDurationDelay:float = 200
@export var passiveTickSignal:StringName = "" #"turn_started" ##passiveDurationTick will advance whenever this is triggered and the passive will take effect

@export_group("Reaction Triggering")#Reactions trigger when targeted by specific types of abilities
@export var reactionTriggeringFlags:Array[AbilityFlags]#Flags which must be present to work
@export var reactionExcludingFlags:Array[AbilityFlags] = [AbilityFlags.IS_REACTION]#Flags which will prevent the proccing of this reaction
@export var procPriority:int = 0
@export var targetSelf:bool
@export var targetTargeter:bool = true
@export var targetCells:bool

func _init() -> void:
	assigned_user.connect(on_user_assigned)
	user = user

#REACTIONS
func reacts_to_ability(ability:Ability)->bool:
	var status:bool = false
	if reactionTriggeringFlags.any(func(flag): return flag in ability.abilityFlags): status = true
	if reactionExcludingFlags.any(func(flag): return flag in ability.abilityFlags): status = false		
	return status

func on_was_targeted(ability:Ability):
	if reacts_to_ability(ability):
		#Add targets
		var targetInfo:=AbilityTargetingInfo.new()
		if targetSelf: 
			targetInfo.unitsTargeted.append(user)
			if targetCells: 
				targetInfo.cellsTargeted.append(user.get_current_cell())
		if targetTargeter: 
			targetInfo.unitsTargeted.append(ability.user)
			if targetCells: 
				targetInfo.cellsTargeted.append(ability.user.get_current_cell())
		
		
		abilityHandler.queue_ability_call(self, targetInfo, ability, false)
#		abilityHandler.queue_ability_call(self, targets, ability, false)
	

#PASSIVES
func get_target_self()->AbilityTargetingInfo:
	var info:=AbilityTargetingInfo.new()
	info.use = user
	info.ability = self
	info.unitsTargeted.append(user)
	return info

func on_user_assigned(user:Unit):
	if not user: push_error("Null user!")
	user.was_targeted.connect(on_was_targeted)
	user.attributes.stat_changed.connect(on_stat_changed)
	user.turn_ended.connect( func(): 
		passiveDurationTick -= 1
		if passiveDurationTick <=0: passive_ended.emit()
		)
	pass

func on_stat_changed(stat:String, oldVal:float, newVal:float):
	if stat == user.attributes.StatNames.TURN_DELAY:
		passiveDurationDelay -= oldVal - newVal
		
		if passiveDurationDelay <= 0: passive_ended.emit(self)
		

