extends Unit
const defaultModel = preload("res://Assets/CellMesh/Characters/Human.tscn")

func _ready():#Has temps
	add_to_group("UNIT")
	misc_visuals()
	create_body(attributes.raceAttributes.model)#Adds the base model for the unit
	create_equipment(attributes.equipment)#Adds any equipment models on top

var body:Model.Body
func create_body(withModel:PackedScene=defaultModel):
	body = Model.Body.new(withModel)#Assign it to the controller
	add_child(body)
	
func create_equipment(equipDict:Dictionary):
	for equipRes in attributes.equipment.values():#Check every equipped item
		if equipRes is Equipment:
			var meshNodes:Array = Model.get_mesh_nodes_in_scene(equipRes.model)#Get it's model nodes
		
			body.attach_nodes_from_array(meshNodes)
				
		

	
func misc_visuals():
	$NickName.text = attributes.info["nickName"]
	var charSprites:SpriteFrames = ResourceLoader.load(attributes.raceAttributes.spriteFolder + "default.tres")

