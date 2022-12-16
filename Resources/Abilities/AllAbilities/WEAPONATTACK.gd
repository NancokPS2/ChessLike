extends Ability

var owner:Unit

func _init():
	displayedName = "ACTION_WEAPONATTACK_NAME"
	internalName = "WEAPONATTACK"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0

func _ready():
	abilityFlags = AbilityFlags.HOSTILE
	parametersReq = ParametersReq.USED_WEAPON + ParametersReq.TARGET_UNIT
	

func use(parametersMethod:Dictionary):
	var weaponHolder = parametersMethod[ParametersReq.USED_WEAPON]
	var targetHolder = parametersMethod[ParametersReq.TARGET_UNIT]
	
	targetHolder.attributes.damage_health(weaponHolder.damage,weaponHolder.attackFlagList)
	emit_signal("ability_finalized")#Must emit the signal or the game will soft-lock
