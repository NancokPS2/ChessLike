extends Node3D
class_name WorldCompSky

const COMPONENT_NAME: StringName = "WORLD_SKY"

## Minutes in a day
const SUN_COLOR_DAY := Color(1,1,0.671)
const SUN_COLOR_NOON := Color(1,0.612,0.275)


var sunlight_node := DirectionalLight3D.new()

var light_color: Color

var sun_tilt: float = 0

func _ready() -> void:
	assert(get_parent() is WorldNode3D)
	
	add_child(sunlight_node)
	update_sun_rotation()


func _process(_delta):
	update_sun_rotation()


func get_world() -> WorldNode3D:
	return get_parent()


#func set_time(new_time: float):
	#time = clamp(new_time, 0, DAY_LENGTH)
	#update_sun_rotation()


#func get_time()->float:
	#return time


func get_daytime() -> float:
	var calendar_comp: WorldCompTime = get_world().get_component(WorldCompTime.COMPONENT_NAME)
	if not calendar_comp:
		return 0
	else:
		return calendar_comp.get_time_frame(calendar_comp.Lengths.DAY)


func update_sun_rotation():
	var rise: float = remap(get_daytime(), 0, WorldCompTime.Lengths.DAY, 0, TAU)
	var tilt: float = sun_tilt
	sunlight_node.rotation = Vector3(rise, 0, tilt)
