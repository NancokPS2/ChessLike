extends Node
class_name WorldCompTime

enum DaySections {
	MORNING,
	EVENING,
	NOON,
	NIGHT,
}

const COMPONENT_NAME: StringName = "WORLD_TIME"

const PERSISTENT_PROPERTIES: Array[String] = ["time_passed"]

const Lengths: Dictionary = {
	MINUTE = 1 as float,
	HOUR = 60 as float,
	DAY_QUARTER = 60 * 6,
	DAY = 60 * 24 as float,
	WEEK = 60 * 24 * 5 as float,
	MONTH = 60 * 24 * 20 as float,
	YEAR = 60 * 24 * 20 * 8 as float,
}

var time_passed: float

const SUNRISE_TIME: float = Lengths.HOUR * 6

func _ready() -> void:
	assert(get_parent() is WorldNode3D)


func get_world() -> WorldNode3D:
	return get_parent()


func get_time_frame(delimiter: float) -> float:
	var framed: float = fmod(time_passed, delimiter)
	return framed
	

func get_day_section() -> DaySections:
	var time_progress: float = get_time_frame(Lengths.DAY)
	time_progress = time_progress - floorf(time_progress)
	return clampi(int(DaySections.size() * time_progress), 0, DaySections.size() - 1)
