extends Node
class_name ComponentStack

const COMPONENT_NAME: StringName = "ENTITY_STACK"

static var call_stack_arr: Array[StackObject]

func _ready() -> void:
	assert(get_parent() is Entity3D)


func get_entity() -> Entity3D:
	return get_parent()

	
static func create_stack_object(function: Callable, priority: int = 0, delay: float = 0) -> StackObject:
	var new_obj := StackObject.new()
	new_obj.set_function(function).set_priority(priority).set_delay(delay)
	return new_obj
	
	
static func add_to_stack(stack_obj: StackObject):
	call_stack_arr.append(stack_obj)
	Event.ENTITY_STACK_ADDED.emit(stack_obj)

	
static func add_to_stack_at_index(stack_obj: StackObject, index: int):
	if not absi(index) < call_stack_arr.size():
		push_error("index out of bounds")
		return
		
	call_stack_arr.insert(index, stack_obj)
	Event.ENTITY_STACK_ADDED.emit(stack_obj)


static func sort_by_priority():
	call_stack_arr.sort_custom(
		func(a: StackObject, b: StackObject):
			return a.priority < b.priority
	)


static func get_all_from_source(source_object: Object) -> Array[StackObject]:
	var output: Array[StackObject]
	
	for stack_obj: StackObject in call_stack_arr:
		if get_source_object(stack_obj) == source_object:
			output.append(stack_obj)
			
	return output

static func get_source_object(stack_obj: StackObject) -> Object:
	return stack_obj.function.get_object()
	
	
static func get_object_index(stack_obj: StackObject) -> int:
	var output: int = call_stack_arr.find(stack_obj)
	if output == -1:
		push_error("Could not find the object in the array")
	return output

func execute_stack():
	Event.ENTITY_STACK_EXECUTING.emit(call_stack_arr)
	for obj: StackObject in call_stack_arr:
		obj.function.call()
		await get_tree().create_timer(obj.delay).timeout
		
	call_stack_arr.clear()


class StackObject extends RefCounted:
	var function: Callable
	var delay: float
	var priority: int
	var metadata: Dictionary

	func set_function(value: Callable) -> StackObject:
		function = value
		return self

	func set_delay(value: float) -> StackObject:
		delay = value
		return self
		
	func set_priority(value: int) -> StackObject:
		priority = value
		return self
		
	func set_metadata(key: String, value) -> StackObject:
		metadata[key] = value
		return self
	
	func get_metadata(key: String):
		return metadata.get(key, null)
