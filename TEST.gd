extends Control

var imageStorageTest:=ImageDataStorage.new()



func _input(event: InputEvent) -> void:
	if event.is_action("camera_up"):
		$FancyLabel.floating_animation(false)


func _ready() -> void:
	var image=Image.create(64,64,true,Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	var charArray:Array[int] = [] #[89,101,115]
	for f in range(0,64*64):
		charArray.append(randi_range(1,400))

	imageStorageTest.insert_data_on_image(image, charArray)
#	print(imageStorageTest.read_data_on_image(image))
	image.save_png("user://test.png")

func update_rect():
	var pn:int=randi_range(0,765)
	var red:float
	var green:float
	var blue:float
	while(pn>0):
		for counter in range(1,8):
			red += pn%(counter*counter)
			pn=pn/(counter*counter)
		for counter in range(1,8):
			green += pn%(counter*counter)
			pn=pn/(counter*counter)
		for counter in range(1,8):
			blue += pn%(counter*counter)
			pn=pn/(counter*counter)
	var color:=Color(red/255,green/255,blue/255,1.0)

	$ColorRect.color = color
