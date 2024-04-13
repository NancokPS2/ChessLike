extends Node

const COMPONENT_NAME: StringName = "ENTITY_TURN"

static var turn_component_array: Array[ComponentTurn]

var delay_stack: int
var delay_current: int

func _ready() -> void:
	assert(get_parent() is Entity3D)
	
	if not self in turn_component_array:
		turn_component_array.append(self)
	else:
		push_warning("This turn component is already in the static array.")


func get_entity() -> Entity3D:
	return get_parent()
	

func add_delay_to_stack(delay: int):
	delay_stack += delay
		
		
func get_base_delay() -> int:
	var stat_comp: ComponentStatus = get_entity().get_component(ComponentStatus.COMPONENT_NAME)
	var output: int = stat_comp.get_stat(ComponentStatus.StatKeys.TURN_DELAY_BASE)
	return output
		
	
func get_current_turn_taker() -> ComponentTurn:
	ComponentTurn.sort_by_delay()
	assert(turn_component_array.size() < 2 or turn_component_array.front().delay_current < turn_component_array.back().delay_current)
	return turn_component_array.front()
	
		
func end_turn():
	#Confirm it is self
	if not get_current_turn_taker() == self:
		push_warning("Only the current turn taker is meant to be able to end their turn!")
		
	#Reset to base + stack.
	delay_current = get_base_delay() + delay_stack
	
	#Reduce the delay for everyone else by the stack
	for turn_comp: ComponentTurn in turn_component_array:
		
		if turn_comp == self:
			continue
			
		delay_current -= delay_stack
	
	delay_stack = 0
	
	Event.ENTITY_TURN_ENDED.emit( get_entity() )
	Event.ENTITY_TURN_STARTED.emit( get_current_turn_taker().get_entity() )
	


static func sort_by_delay():
	turn_component_array.sort_custom( func(a:ComponentTurn, b:ComponentTurn): 
		return a.delay_current < b.delay_current 
		)
	
func advance_time(time: int):
	delay_current -= time



