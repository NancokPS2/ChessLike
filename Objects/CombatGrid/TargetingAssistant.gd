extends Node2D
onready var grid = get_parent()

var painting:bool = true

func await_location():
	return yield(grid,"tile_clicked")

func targeting_mode(mode:int)->Dictionary:
	var initialTile:Vector2 = await_location()
	var found:Dictionary
	
	
		
	match mode:
		Ability.TargetingModes.SINGLE:
			set_mask()
			
	
	return found
	
func paint_with_bitmap(map:BitMap):
	var center = map.get_size()/2
	
	
	
func set_mask():

	pass

func movement_mode(): 
	pass
