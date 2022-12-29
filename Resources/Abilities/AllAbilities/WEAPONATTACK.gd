extends Ability

func _init():
	displayedName = "ACTION_WEAPONATTACK_NAME"
	internalName = "WEAPONATTACK"
	classRestrictions = []
	turnDelayCost += 0
	energyCost += 0

func _ready():
	abilityFlags = AbilityFlags.HOSTILE
	parametersReq = ParametersReq.USED_WEAPON + ParametersReq.TARGET_UNIT
	

func _use(params):
	var weaponHolder = user.equipment["R_HAND"]
	
	params["target"].change_stat("health",weaponHolder.damage)
	emit_signal("ability_finalized")#Must emit the signal or the game will soft-lock

func _check_availability():
	if user.equipment["R_HAND"] == null or user.equipment["L_HAND"] == null:
		return false
	else:
		return true

const parameters = {
	"target":null,
	"flags":null
}
