extends Control

func _ready() -> void:
	$UnitDisplay.margin_left = rect_size.x
	$UnitDisplay.margin_right = rect_size.x

func populate_list(units:Array):
	$List.clear()
	for x in units:
		$List.add_item(x.unitName)
		$List.set_item_metadata($List.et_item_count()-1,x)
		$UnitDisplay.get_node("Name").text = x.attributes.unitName
		$UnitDisplay.get_node("Delay").text = str(x.attributes.turnDelayRemaining) + "/" + str(x.attributes.turnDelayBase)
