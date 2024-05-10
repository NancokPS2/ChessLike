extends Node3D
class_name WorldCompSky

const COMPONENT_NAME: StringName = "WORLD_SKY"

## Minutes in a day
const SunColors: Dictionary = {
	MORNING = Color8(255,221,64),
	DAY = Color8(252,255,181),
	NIGHT = Color8(194,197,204),
}
const SUN_COLOR_DAY := Color(1,1,0.671)
const SUN_COLOR_NOON := Color(1,0.612,0.275)


var sunlight_node := DirectionalLight3D.new()

var custom_sun_color := Color.TRANSPARENT

var sun_tilt: float = 0

func _ready() -> void:
	assert(get_parent() is WorldNode3D)
	
	add_child.call_deferred(sunlight_node)
	update_sun_position.call_deferred()
	print.call_deferred(sunlight_node.get_parent())


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
		var time_this_day: float = calendar_comp.get_time_frame(calendar_comp.Lengths.DAY)
		var offset: float = calendar_comp.Lengths.DAY_QUARTER
		var output: float = remap(time_this_day + offset,
			0 + offset,
			calendar_comp.Lengths.DAY + offset,
			0,
			calendar_comp.Lengths.DAY
			)
		return output


func update_sun_position(day_time: float = get_daytime()):
	var rise: float = remap(day_time, 0, WorldCompTime.Lengths.DAY, 0, TAU)
	var tilt: float = sun_tilt
	sunlight_node.rotation = Vector3(rise, 0, tilt)


func update_sun_color(day_time: float = get_daytime()):
	if custom_sun_color != Color.TRANSPARENT:
		sunlight_node.light_color = custom_sun_color
		return 
		
	var quarter: float = WorldCompTime.Lengths.DAY_QUARTER
	
	var starter_color: Color
	var final_color: Color
	
	var curr_quarter: int = floori(day_time / quarter)
	var prog_quarter: float = fmod(day_time, quarter)/360
	
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
	print_debug('''Start: {1}
	Final: {2}
	Output: {0}'''.format([str(color), str(starter_color), str(final_color)]))
	print(SunColors.NIGHT)
	sunlight_node.light_color = color
