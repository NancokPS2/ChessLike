extends RefCounted
class_name ImageDataStorage

const BASE_INTERVAL_FLAG_PIXEL_ALPHA = 125

enum Flags {
	EVERY_4=1<<0,
	EVERY_6=1<<1,
	EVERY_8=1<<2,
	INT=1<<3,
	CHAR=1<<5,
}
const DEFAULT_FLAGS = Flags.EVERY_6 + Flags.CHAR

func set_flags(image:Image, flags:Flags, pixel:Vector2i):
	var flagPixel:Color = image.get_pixelv(pixel)
	flagPixel.a8 = BASE_INTERVAL_FLAG_PIXEL_ALPHA + flags
	image.set_pixelv(pixel, flagPixel)
	
	
func get_flags(image:Image,pixel:Vector2i)->int:
	return image.get_pixelv(pixel).a8 - BASE_INTERVAL_FLAG_PIXEL_ALPHA

func get_interval(flags:int)->int:
	if flags & Flags.EVERY_4: return 4
	elif flags & Flags.EVERY_6: return 6
	elif flags & Flags.EVERY_8: return 8
	else: return 4

func get_type(flags:int)->int:
	if flags & Flags.INT:
		return TYPE_INT
	elif flags & Flags.CHAR:
		return TYPE_STRING
	else: return TYPE_INT

func get_insertion_positions(image:Image, pixel:=Vector2i.ZERO)->Array[Vector2i]:
	var array:Array[Vector2i]
	var flags:int = get_flags(image,Vector2i.ZERO)
	var interval:int = get_interval(flags)
	
	if image.get_width() > image.get_height():
		var xPositions = range(1, image.get_width(), interval)
		var yPositions = range(1, image.get_height(), interval*3)
		
		for y in yPositions:
			for x in xPositions:
				array.append(Vector2i(x,y))
			
#	else:
#		var yPositions = range(1, image.get_height(), interval)
#		for y in yPositions:
#			array.append(Vector2i(0,y))
		
	return array

func read_data_on_image(image:Image)->Array:
	var positions:Array[Vector2i] = get_insertion_positions(image)
	var values:Array
	for pos in positions:
		var flags:int = get_flags(image, pos)
		var type:int = get_type(flags)
		var interval:int = get_interval(flags)
		var value:int = image.get_pixelv(pos+(Vector2i.DOWN*(interval*3))).a8
		match type:
			TYPE_INT:
				values.append( value )
			TYPE_STRING:
				values.append(char(value))
				
	return values
	
	

func insert_data_on_image(image:Image, posIndex:int, value:int, flags:int=DEFAULT_FLAGS):
	value = clamp(value,0,255)
	flags = clamp(flags,0,0b111111)
	var interval:int = get_interval(flags)
	var type:int = get_type(flags)
	var positions:Array[Vector2i] = get_insertion_positions(image)
	var insertionPos:Vector2i = positions[posIndex]
	
	set_flags(image, flags, insertionPos)
	
	var valuePixel:Color = image.get_pixelv(insertionPos+(Vector2i.DOWN*interval)); valuePixel.a = value
	image.set_pixelv(insertionPos+(Vector2i.DOWN*interval), valuePixel)
	
	
	
func insert_array_of_values(image:Image,array:Array[int], flags:int=DEFAULT_FLAGS):
	var counter:int = 0
	for val in array:
		insert_data_on_image(image, counter, val, flags)
		counter+=1
