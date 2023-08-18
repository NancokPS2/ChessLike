extends MapScreen

#func _init() -> void:
#	super._init()
#	marker_added.connect(extra_marker_setup)

func extra_marker_setup(marker:MapScreenMarker):
	
	
	var toolTip = Tooltip.new()
	toolTip.text = marker
	pass
