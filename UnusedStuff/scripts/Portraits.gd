extends Node
export(PackedScene) var portrait_scene
var preparedSprite


func _on_Field_create_portraits():
	for x in FieldVars.fieldedUnitList:
		var portrait = portrait_scene.instance()
		preparedSprite = x.stats["sprite"]
		portrait.get_child(0).set_texture(preparedSprite)
		add_child(portrait_scene)
