extends UnitDisplay

func _ready() -> void:
	unitRef = Unit.Generator.build_from_attributes(load("res://Resources/Characters/UniqueCharacters/Misha.tres"))#TEMP
	super._ready()

func refresh_ui(useBaseStats:bool=false):
	for child in get_children():
		if child is DecoratedList:
			child.update_from_entries(unitRef)
	
	super.refresh_ui()
