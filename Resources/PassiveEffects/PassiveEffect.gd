extends Resource
class_name PassiveEffect

@export var triggeringSignals:Array[StringName]:
	set(val):
		triggeringSignals = val
		
@export var duration:int = 1

@export var tickSignal:StringName


var owner:Unit:
	set = setup
#	get: 
#		if unit is Unit: return unit
#		elif get_parent() is Unit: return get_parent()
#		else: return null


func setup(_owner:Unit):
	owner = _owner
	
	Signal(owner,tickSignal).connect(duration_tick)
	
	for signalName in triggeringSignals:
		Signal(owner, signalName).connect(trigger)
	
	
func duration_tick(amount:int = -1):
	duration += amount
	
func validate_signals()->bool:
	var success := triggeringSignals.all(func(signa): return owner.has_user_signal(signa))
	if success and owner.has_user_signal(tickSignal): return true
	else: push_error( "Invalid signal detected in: " + str(triggeringSignals) + " or " + str(tickSignal) ); return false

func trigger():
	print("Unimplemented passive trigger")
