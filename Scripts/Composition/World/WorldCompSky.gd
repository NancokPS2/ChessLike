extends Node3D
class_name WorldCompSky

const COMPONENT_NAME: StringName = "WORLD_SKY"

## Minutes in a day
const SunColors: Dictionary = {
	MORNING = Color(1,0.612,0.275),
	DAY = Color(1,1,0.671),
	NIGHT = Color(1,1,0.671),
}
const SUN_COLOR_DAY := Color(1,1,0.671)
const SUN_COLOR_NOON := Color(1,0.612,0.275)


var sunlight_node := DirectionalLight3D.new()

var sun_color: Color

var sun_tilt: float = 0

func _ready() -> void:
	assert(get_parent() is WorldNode3D)
	
	await get_tree().process_frame
	add_child(sunlight_node)
	update_sun_position()


func _process(_delta):
	var current_time: float = get_daytime()
	update_sun_position(current_time)
	update_sun_color(current_time)


func get_world() -> WorldNode3D:
	return get_parent()


#func set_time(new_time: float):
	#time = clamp(new_time, 0, DAY_LENGTH)
	#update_sun_position()


#func get_time()->float:
	#return time


func get_daytime() -> float:
	var calendar_comp: WorldCompTime = get_world().get_component(WorldCompTime.COMPONENT_NAME)
	if not calendar_comp:
		push_warning("Could not fetch current daytime.")
		return 0
	else:
		assert(calendar_comp.get_time_frame(calendar_comp.Lengths.DAY)<calendar_comp.Lengths.DAY)
		return calendar_comp.get_time_frame(calendar_comp.Lengths.DAY)


func update_sun_position(day_time: float = get_daytime()):
	var rise: float = remap(day_time, 0, WorldCompTime.Lengths.DAY, 0, TAU)
	var tilt: float = sun_tilt
	sunlight_node.rotation = Vector3(rise, 0, tilt)
	print_debug(sunlight_node.rotation)


func update_sun_color(day_time: float = get_daytime()):
	const QUARTER_DAY: float = WorldCompTime.Lengths.DAY_QUARTER
	
	var starter_color: Color
	var final_color: Color
	
	var curr_quarter: float = floor(day_time / QUARTER_DAY)
	var prog_quarter: float = fmod(day_time, QUARTER_DAY)
	
	match curr_quarter:
		0:
			starter_color = SunColors.NIGHT
			final_color = SunColors.MORNING
		1:
			starter_color = SunColors.MORNING
			final_color = SunColors.DAY
		2:
			starter_color = SunColors.DAY
			final_color = SunColors.MORNING
		3:
			starter_color = SunColors.MORNING
			final_color = SunColors.NIGHT
			
	var color: Color = starter_color.lerp(final_color, prog_quarter)
	
	sunlight_node.light_color = color
