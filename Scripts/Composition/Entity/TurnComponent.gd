extends Node
class_name ComponentTurn

const COMPONENT_NAME: StringName = "ENTITY_TURN"

static var turn_component_array: Array[ComponentTurn]

var delay_stack: int
var delay_current: int
var delay_base: int

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()
		
		
func add_to_static():
	if not turn_component_array:
		turn_component_array.append(self)
	else:
		push_warning("This turn component is already in the static array.")


func apply_delay(delay: int):
	delay_stack += delay
		
	
func get_current_turn_taker() -> ComponentTurn:
	sort_by_delay()
	assert(turn_component_array.size() < 2 or turn_component_array.front().delay_current < turn_component_array.back().delay_current)
	return turn_component_array.front()
	
		
func end_turn():
	#Confirm it is self
	if not get_current_turn_taker() == self:
		push_warning("Only the current turn taker is meant to be able to advance turns!")
		
	#Reset to base + stack.
	delay_current = delay_base + delay_stack
	
	#Reduce the delay for everyone else by the stack
	for turn_comp: ComponentTurn in turn_component_array:
		
		if turn_comp == self:
			continue
			
		advance_time(delay_stack)
	
	delay_stack = 0


static func sort_by_delay():
	turn_component_array.sort_custom( func(a:ComponentTurn, b:ComponentTurn): 
		return a.delay_current < b.delay_current 
		)
	
func advance_time(time: int):
	delay_current -= time



