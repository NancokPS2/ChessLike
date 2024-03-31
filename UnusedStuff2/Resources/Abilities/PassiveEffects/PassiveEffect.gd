extends Resource
class_name PassiveEffect

#@export var triggeringSignals:Array[StringName]:
#	set(val):
#		triggeringSignals = val
		
@export var durationTick:int
@export var durationDelay:float
@export var tickSignal:StringName ##durationTick will advance whenever this is triggered

func passive_connect_to_unit(unit:Unit):
	if not unit.has_signal(tickSignal): push_error("{0} is not a valid signal.".format([tickSignal]))
	
	Signal(unit,tickSignal).connect(passive_duration_tick)
	
	unit.attributes.stat_changed.connect(passive_duration_delay)

	
func passive_duration_tick(amount:int = -1):
	durationTick -= amount

func passive_duration_delay(statName:String, oldVal:float, newVal:float):
	if statName == "turnDelay":
		pass
	

func passive_trigger():
	print("Unimplemented passive trigger")
