extends GridContainer


func _ready():  
	var i = 0
	var debugUnitImage = load("res://icon.png")

@export(PackedScene) var portrait_scene

func create_portraits():
	for x in get_tree().get_nodes_in_group("UNITS"):
		var portrait = portrait_scene.instance()
		portrait.ID = x.stats["ID"]
		portrait.get_node("Sprite").set_texture(x.stats["sprite"])
		add_child(portrait)

