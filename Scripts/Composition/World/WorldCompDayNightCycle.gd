extends Node3D
class_name WorldCompDayCycle

const COMPONENT_NAME: StringName = "WORLD_DAY_CYCLE"

## Minutes in a day
const DAY_LENGTH: float = 60 * 24
const SUNRISE_TIME: float = 60 * 6

var sunlight_node := DirectionalLight3D.new()

var time: float

var sun_tilt: float = 0

func _ready() -> void:
	assert(get_parent() is WorldNode3D)
	
	add_child(sunlight_node)
	update_sun_rotation()


func get_world() -> WorldNode3D:
	return get_parent()


func set_time(new_time: float):
	time = clamp(new_time, 0, DAY_LENGTH)
	update_sun_rotation()
	

func get_time()->float:
	return time


func update_sun_rotation():
	var rise: float = remap(time, 0, DAY_LENGTH, 0, TAU)
	var tilt: float = sun_tilt
	sunlight_node.rotation = Vector3(rise, 0, tilt)
